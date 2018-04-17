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

    HalTask[] placeFarmSelectorItems = new HalTask[3];
    placeFarmSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.FARM);
    placeFarmSelectorItems[1] = new CanPlaceX(BuildingCode.FARM, computerState);
    placeFarmSelectorItems[2] = new PlaceX(BuildingCode.FARM, computerState, cellsNearbyTownSquare);
    HalTask placeFarmSelector = new HalSelector(placeFarmSelectorItems);

    HalTask[] placeSawmillSelectorItems = new HalTask[3];
    placeSawmillSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.SAWMILL);
    placeSawmillSelectorItems[1] = new CanPlaceX(BuildingCode.SAWMILL, computerState);
    placeSawmillSelectorItems[2] = new PlaceX(BuildingCode.SAWMILL, computerState, cellsNearbyTownSquare);
    HalTask placeSawmillSelector = new HalSelector(placeSawmillSelectorItems);

    HalTask[] placeFoundrySelectorItems = new HalTask[3];
    placeFoundrySelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.FOUNDRY);
    placeFoundrySelectorItems[1] = new CanPlaceX(BuildingCode.FOUNDRY, computerState);
    placeFoundrySelectorItems[2] = new PlaceX(BuildingCode.FOUNDRY, computerState, cellsNearbyTownSquare);
    HalTask placeFoundarySelector = new HalSelector(placeFoundrySelectorItems);

    HalTask[] placeBarracksSelectorItems = new HalTask[3];
    placeBarracksSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.BARRACKS);
    placeBarracksSelectorItems[1] = new CanPlaceX(BuildingCode.BARRACKS, computerState);
    placeBarracksSelectorItems[2] = new PlaceX(BuildingCode.BARRACKS, computerState, cellsNearbyTownSquare);
    HalTask placeBarracksSelector = new HalSelector(placeBarracksSelectorItems);

    HalTask[] placeStockpileSelectorItems = new HalTask[3];
    placeStockpileSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.STOCKPILE);
    placeStockpileSelectorItems[1] = new CanPlaceX(BuildingCode.STOCKPILE, computerState);
    placeStockpileSelectorItems[2] = new PlaceX(BuildingCode.STOCKPILE, computerState, cellsNearbyTownSquare);
    HalTask placeStockpileSelector = new HalSelector(placeStockpileSelectorItems);

    HalTask[] assignFarmerSequenceItems = new HalTask[3];
    assignFarmerSequenceItems[0] = new CheckBelowGoldenRatio(computerState, HumanCode.FARMER, this.goldenRatio);
    assignFarmerSequenceItems[1] = placeFarmSelector;
    assignFarmerSequenceItems[2] = new AssignCitizen(computerState, HumanCode.FARMER);
    HalTask assignFarmerSequence = new HalSequence(assignFarmerSequenceItems);

    HalTask[] assignLumberjackSequenceItems = new HalTask[3];
    assignLumberjackSequenceItems[0] = new CheckBelowGoldenRatio(computerState, HumanCode.LUMBERJACK, this.goldenRatio);
    assignLumberjackSequenceItems[1] = placeSawmillSelector;
    assignLumberjackSequenceItems[2] = new AssignCitizen(computerState, HumanCode.LUMBERJACK);
    HalTask assignLumberjackSequence = new HalSequence(assignLumberjackSequenceItems);

    HalTask[] assignMinerSelectorItems = new HalTask[3];
    assignMinerSelectorItems[0] = new CheckBelowGoldenRatio(computerState, HumanCode.MINER, this.goldenRatio);
    assignMinerSelectorItems[1] = placeFoundarySelector;
    assignMinerSelectorItems[2] = new AssignCitizen(computerState, HumanCode.MINER);
    HalTask assignMinerSequence = new HalSequence(assignMinerSelectorItems);

    HalTask[] assignSoldierSelectorItems = new HalTask[3];
    assignSoldierSelectorItems[0] = new CheckBelowGoldenRatio(computerState, HumanCode.SOLDIER, this.goldenRatio);
    assignSoldierSelectorItems[1] = placeBarracksSelector;
    assignSoldierSelectorItems[2] = new AssignCitizen(computerState, HumanCode.SOLDIER);
    HalTask assignSoldierSequence = new HalSequence(assignSoldierSelectorItems);

    HalTask[] oracleAssignSelectorItems = new HalTask[4];
    oracleAssignSelectorItems[0] = assignFarmerSequence;
    oracleAssignSelectorItems[1] = assignLumberjackSequence;
    oracleAssignSelectorItems[2] = assignMinerSequence;
    oracleAssignSelectorItems[3] = assignSoldierSequence;
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
    System.out.println("---------- Hal Stats ----------");
    System.out.println("Food: " + this.computerState.foodSupply);
    System.out.println("Lumber: " + this.computerState.resourceSupply.get(ResourceCode.LUMBER));
    System.out.println("Metal: " + this.computerState.resourceSupply.get(ResourceCode.METAL));
    System.out.println("-------------------------------");

    // CHEAT: HAL CAN NEVER RUN OUT OF FOOD
    this.computerState.foodSupply = 999;

    if (gameState.gameStateIndex > cooldownIndex) {
      if (behaviorTree.execute()) {
        cooldownIndex = gameState.gameStateIndex + ACTION_COOLDOWN;
      }
    }
  }
}


abstract class HalTask {
  abstract boolean execute();
  boolean verbose = true;
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
  BuildingCode type;

  CheckHaveBuilding(PlayerState state, BuildingCode type) {
    this.state = state;
    this.type = type;
  }

  boolean execute() {
    Building targetBuilding = this.state.getLeastAssigned(this.type);
    if (targetBuilding == null || targetBuilding.numFreeAssignments() == 0) {
      return false;
    }
    return true;
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
    Human oldFreeCitizen = this.state.getFreeCitizen();
    if (oldFreeCitizen == null) {
      return false;
    }
    Building targetBuilding = null;
    Human newCitizen = null;

    switch (this.type) {
      case FARMER:
        targetBuilding = this.state.getLeastAssigned(BuildingCode.FARM);
        newCitizen = new Farmer(oldFreeCitizen.loc, targetBuilding, state);
        break;
      case LUMBERJACK:
        targetBuilding = this.state.getLeastAssigned(BuildingCode.SAWMILL);
        newCitizen = new Lumberjack(oldFreeCitizen.loc, targetBuilding, state);
        break;
      case MINER:
        targetBuilding = this.state.getLeastAssigned(BuildingCode.FOUNDRY);
        newCitizen = new Miner(oldFreeCitizen.loc, targetBuilding, state);
        break;
    }

    if (newCitizen == null) {
      return false;
    }

    this.state.removeHuman(oldFreeCitizen);
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

class CanPlaceX extends HalTask {
  BuildingCode buildingType;
  PlayerState state;

  CanPlaceX(BuildingCode buildingType, PlayerState state) {
    this.buildingType = buildingType;
    this.state = state;
  }

  boolean execute() {
    HashMap<BuildingCode, HashMap<ResourceCode, Integer>> allCosts = this.state.BUILDING_COSTS;
    HashMap<ResourceCode, Integer> buildingCost = allCosts.get(this.buildingType);

    return state.resourceSupply.get(ResourceCode.LUMBER) < buildingCost.get(ResourceCode.LUMBER) ||
      state.resourceSupply.get(ResourceCode.METAL) < buildingCost.get(ResourceCode.METAL);
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