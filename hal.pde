class Hal {
  static final int ACTION_COOLDOWN = 30;
  double cooldownIndex;

  GameState gameState;
  PlayerState computerState;
  PlayerState humanState;
  Building townSquare;
  Cell[] cellsNearbyTownSquare;
  HashMap<HumanCode, Float> goldenRatio;

  HalTask behaviorTree;

  Hal(GameState gameState, PlayerState computerState, PlayerState humanState) {
    this.gameState = gameState;
    this.computerState = computerState;
    this.humanState = humanState;

    this.goldenRatio = new HashMap<HumanCode, Float>();
    this.goldenRatio.put(HumanCode.FARMER, 14.0 / 32.0);
    this.goldenRatio.put(HumanCode.LUMBERJACK, 4.0 / 32.0);
    this.goldenRatio.put(HumanCode.MINER, 4.0 / 32.0);
    this.goldenRatio.put(HumanCode.SOLDIER, 10.0 / 32.0);

    cooldownIndex = gameState.gameStateIndex;

    townSquare = computerState.buildings.get(BuildingCode.TOWNSQUARE).get(0);
    HashSet<Cell> cellsNearbyTownSquareSet = townSquare.loc.getNearbyGrassCells(100);
    cellsNearbyTownSquare = cellsNearbyTownSquareSet.toArray(new Cell[cellsNearbyTownSquareSet.size()]);

    HalTask[] increasePopulationItems = new HalTask[2];
    increasePopulationItems[0] = new NeedMoreCitizens(computerState);
    increasePopulationItems[1] = new PlaceX(BuildingCode.HOVEL, computerState, cellsNearbyTownSquare);
    HalTask increasePopulationSequence = new HalSequence(increasePopulationItems);

    HalTask[] placeFarmSelectorItems = new HalTask[2];
    placeFarmSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.FARM);
    placeFarmSelectorItems[1] = new PlaceX(BuildingCode.FARM, computerState, cellsNearbyTownSquare);
    HalTask placeFarmSelector = new HalSelector(placeFarmSelectorItems);

    HalTask[] placeStockpileSelectorItems = new HalTask[2];
    placeStockpileSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.STOCKPILE);
    placeStockpileSelectorItems[1] = new PlaceX(BuildingCode.STOCKPILE, computerState, cellsNearbyTownSquare);
    HalTask placeStockpileSelector = new HalSelector(placeStockpileSelectorItems);

    HalTask[] assignFarmerSequenceItems = new HalTask[3];
    assignFarmerSequenceItems[0] = new CheckBelowGoldenRatio(computerState, HumanCode.FARMER, this.goldenRatio);
    assignFarmerSequenceItems[1] = placeFarmSelector;
    assignFarmerSequenceItems[2] = new AssignCitizen(computerState, HumanCode.FARMER);
    HalTask assignFarmerSequence = new HalSequence(assignFarmerSequenceItems);

    HalTask[] oracleAssignSelectorItems = new HalTask[1];
    oracleAssignSelectorItems[0] = assignFarmerSequence;
    HalTask oracleAssignSelector = new HalSelector(oracleAssignSelectorItems);

    HalTask[] oracleAssignSequenceItems = new HalTask[3];
    oracleAssignSequenceItems[0] = new HaveFreeCitizen(computerState);
    oracleAssignSequenceItems[1] = placeStockpileSelector;
    oracleAssignSequenceItems[2] = oracleAssignSelector;
    HalTask oracleAssignSequence = new HalSequence(oracleAssignSequenceItems);

    HalTask[] oracleItems = new HalTask[2];
    oracleItems[0] = increasePopulationSequence;
    oracleItems[1] = oracleAssignSequence;

    behaviorTree = new HalSelector(oracleItems);
  }

  void behave() {
    if (gameState.gameStateIndex > cooldownIndex) {
      if (behaviorTree.execute()) {
        cooldownIndex = gameState.gameStateIndex + ACTION_COOLDOWN;
      }
    }
  }
}


abstract class HalTask {
  abstract boolean execute();
}

class NeedMoreCitizens extends HalTask {
  PlayerState state;

  NeedMoreCitizens(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    return this.state.getAllHumans().size() >= this.state.populationCapacity;
  }
}

class HaveFreeCitizen extends HalTask {
  PlayerState state;

  HaveFreeCitizen(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    return this.state.humans.get(HumanCode.FREE).size() > 0;
  }
}

class CheckBelowGoldenRatio extends HalTask {
  PlayerState state;
  HumanCode type;
  HashMap<HumanCode, Float> goldenRatio;

  CheckBelowGoldenRatio(PlayerState state, HumanCode type, HashMap<HumanCode, Float> goldenRatio) {
    this.state = state;
    this.type = type;
    this.goldenRatio = goldenRatio;
  }

  boolean execute() {
    float goal = this.goldenRatio.get(this.type);
    float current = (float) this.state.humans.get(this.type).size() / (float) this.state.getAllHumans().size();
    return current < goal;
  }
}

class CheckHaveBuilding extends HalTask {
  PlayerState state;
  BuildingCode building;

  CheckHaveBuilding(PlayerState state, BuildingCode building) {
    this.state = state;
    this.building = building;
  }

  boolean execute() {
    return state.buildings.get(this.building).size() > 0;
  }
}

class AssignCitizen extends HalTask {
  PlayerState state;
  HumanCode type;

  AssignCitizen(PlayerState state, HumanCode type) {
    this.state = state;
    this.type = type;
  }

  boolean execute() {
    ArrayList<Human> freeCitizens = this.state.humans.get(HumanCode.FREE);
    Human oldFreeCitizen = freeCitizens.get(0);
    Building targetBuilding = null;
    Human newCitizen = null;

    switch (this.type) {
      case FARMER:
        targetBuilding = this.state.buildings.get(BuildingCode.FARM).get(rng.nextInt(this.state.buildings.get(BuildingCode.FARM).size()));
        newCitizen = new Farmer(oldFreeCitizen.loc, targetBuilding, state);
        break;
    }

    this.state.humans.get(HumanCode.FREE).remove(oldFreeCitizen);
    this.state.humans.get(this.type).add(newCitizen);
    return true;
  }
}

class RiskOfStarving extends HalTask {
  PlayerState state;

  RiskOfStarving(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    int foodNeed = state.getCitizens().size() + (state.getSoldiers().size() * 2);
    if (foodNeed == 0) {
      return false;
    }
    int projection = state.foodSupply / foodNeed;
    return projection < 2;
  }
}

class EnemyTroopsNearby extends HalTask {
  Cell townSquare;
  PlayerState humanState;

  EnemyTroopsNearby(Cell townSquare, PlayerState humanState) {
    this.townSquare = townSquare;
    this.humanState = humanState;
  }

  boolean execute() {
    for (Human soldier : humanState.getSoldiers()) {
      if (soldier.distanceTo(townSquare) < 250) {
        return true;
      }
    }
    return false;
  }
}

class PlaceX extends HalTask {
  BuildingCode buildingType;
  PlayerState state;
  Cell[] potentialCells;

  PlaceX(BuildingCode buildingType, PlayerState state, Cell[] potentialCells) {
    this.buildingType = buildingType;
    this.state = state;
    this.potentialCells = potentialCells;
  }

  boolean execute() {
    int attempts = 0;
    while(attempts < potentialCells.length) {
      attempts++;
      Cell potentialCell = potentialCells[rng.nextInt(potentialCells.length)];
      if (!potentialCell.hasBuilding()) {
        state.placeBuilding(potentialCell, buildingType);
        return true;
      }
    }
    return false;
  }
}

// class BuildMostNeededBuildingOrAssignMostNeededHuman extends HalTask {
//   PlayerState state;
//
//   BuildMostNeededBuildingOrAssignMostNeededHuman(PlayerState state) {
//
//   }
// }
//
// class AssignMostNeededHuman extends HalTask {
//   PlayerState state;
// }
//
// class AssignHuman extends HalTask {
//   PlayerState state;
//
//   AssignHuman()
// }


/** Tries children in order until one returns success (return “fail” if all fail) */
class HalSelector extends HalTask {
  HalTask[] children;

  HalSelector(HalTask[] children) {
    this.children = children;
  }

  boolean execute() {
    for (int i = 0; i < children.length; i++) {
      boolean s = children[i].execute();
      if (s) {
        return true;
      }
    }

    return false;
  }
}

/** Tries all its children in turn, returns failure if any fail (or success if all succeed) */
class HalSequence extends HalTask {
  HalTask[] children;

  HalSequence(HalTask[] children) {
    this.children = children;
  }

  boolean execute() {
    for (int i = 0; i < children.length; i++) {
      boolean s = children[i].execute();
      if (!s) {
        return false;
      }
    }
    return true;
  }
}