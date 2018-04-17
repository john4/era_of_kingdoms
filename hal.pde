import java.util.Arrays;

class Hal {
  static final int ACTION_COOLDOWN = 30;
  double cooldownIndex;

  GameState gameState;
  PlayerState computerState;
  PlayerState humanState;
  Building townSquare;
  ArrayList<Cell> grassCellsNearbyTownSquare;
  ArrayList<Cell> grassCellsNearForest;
  ArrayList<Cell> grassCellsNearStone;
  ArrayList<Cell> grassCellsNearStockpiles;
  CallbackMarker newStockpileBuilt = new CallbackMarker();
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
    HashSet<Cell> grassCellsNearbyTownSquareSet = townSquare.loc.getNearbyGrassCells(100);
    grassCellsNearbyTownSquare = new ArrayList<Cell>(Arrays.asList(grassCellsNearbyTownSquareSet.toArray(new Cell[grassCellsNearbyTownSquareSet.size()])));
    grassCellsNearStockpiles = new ArrayList<Cell>();
    grassCellsNearForest = new ArrayList<Cell>();
    grassCellsNearStone = new ArrayList<Cell>();

    PotentialCells potentialGeneralCells = new PotentialCells(grassCellsNearbyTownSquare);
    PotentialCells potentialFarmCells = new PotentialCells(grassCellsNearStockpiles, grassCellsNearbyTownSquare);
    PotentialCells potentialSawmillCells = new PotentialCells(grassCellsNearForest, grassCellsNearbyTownSquare);
    PotentialCells potentialFoundryCells = new PotentialCells(grassCellsNearStone, grassCellsNearbyTownSquare);

    for (Cell cell : grassCellsNearbyTownSquare) {
      if (cell.isNearCellOfType(1, 3)) {
        grassCellsNearStone.add(cell);
      }
      if (cell.isNearCellOfType(2, 3)) {
        grassCellsNearForest.add(cell);
      }
    }

    HalTask[] increasePopulationItems = new HalTask[2];
    increasePopulationItems[0] = new NeedMoreCitizens(computerState);
    increasePopulationItems[1] = new PlaceX(BuildingCode.HOVEL, computerState, potentialGeneralCells);
    HalTask increasePopulationSequence = new HalSequence(increasePopulationItems);

    HalTask[] placeFarmSelectorItems = new HalTask[2];
    placeFarmSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.FARM);
    placeFarmSelectorItems[1] = new PlaceX(BuildingCode.FARM, computerState, potentialFarmCells);
    HalTask placeFarmSelector = new HalSelector(placeFarmSelectorItems);

    HalTask[] placeSawmillSelectorItems = new HalTask[2];
    placeSawmillSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.SAWMILL);
    placeSawmillSelectorItems[1] = new PlaceX(BuildingCode.SAWMILL, computerState, potentialSawmillCells);
    HalTask placeSawmillSelector = new HalSelector(placeSawmillSelectorItems);

    HalTask[] placeFoundrySelectorItems = new HalTask[2];
    placeFoundrySelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.FOUNDRY);
    placeFoundrySelectorItems[1] = new PlaceX(BuildingCode.FOUNDRY, computerState, potentialFoundryCells);
    HalTask placeFoundarySelector = new HalSelector(placeFoundrySelectorItems);

    HalTask[] placeBarracksSelectorItems = new HalTask[2];
    placeBarracksSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.BARRACKS);
    placeBarracksSelectorItems[1] = new PlaceX(BuildingCode.BARRACKS, computerState, potentialGeneralCells);
    HalTask placeBarracksSelector = new HalSelector(placeBarracksSelectorItems);

    HalTask[] placeStockpileSelectorItems = new HalTask[2];
    placeStockpileSelectorItems[0] = new CheckHaveBuilding(computerState, BuildingCode.STOCKPILE);
    placeStockpileSelectorItems[1] = new PlaceX(BuildingCode.STOCKPILE, computerState, potentialGeneralCells, newStockpileBuilt);
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

  void recalculateNearbyStockpileCells() {
    ArrayList<Building> stockpiles = this.computerState.buildings.get(BuildingCode.STOCKPILE);
    HashSet<Cell> newCellsNearStockpiles = new HashSet<Cell>();

    for (Building stockpile : stockpiles) {
      newCellsNearStockpiles = stockpile.loc.getNearbyGrassCells(40, newCellsNearStockpiles);
    }

    this.grassCellsNearStockpiles.clear();
    this.grassCellsNearStockpiles.addAll(new ArrayList<Cell>(Arrays.asList(newCellsNearStockpiles.toArray(new Cell[newCellsNearStockpiles.size()]))));
  }

  void behave() {
    if (this.newStockpileBuilt.state) {
      this.recalculateNearbyStockpileCells();
      this.newStockpileBuilt.state = false;
    }

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

class PlaceX extends HalTask {
  BuildingCode buildingType;
  PlayerState state;
  PotentialCells potentialCells;
  CallbackMarker callbackMarker;

  PlaceX(BuildingCode buildingType, PlayerState state, PotentialCells potentialCells) {
    this.buildingType = buildingType;
    this.state = state;
    this.potentialCells = potentialCells;
  }

  PlaceX(BuildingCode buildingType, PlayerState state, PotentialCells potentialCells, CallbackMarker callbackMarker) {
    this(buildingType, state, potentialCells);
    this.callbackMarker = callbackMarker;
  }

  boolean execute() {
    Cell potentialCell = potentialCells.get();

    if (potentialCell != null) {
      state.placeBuilding(potentialCell, buildingType);
      if (this.callbackMarker != null) {
        this.callbackMarker.state = true;
      }
      return true;
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

class CallbackMarker {
  boolean state;
  CallbackMarker() {
    this.state = false;
  }
}

class PotentialCells {
  ArrayList<Cell> primary;
  ArrayList<Cell> secondary;

  PotentialCells(ArrayList<Cell> primary, ArrayList<Cell> secondary) {
    this.primary = primary;
    this.secondary = secondary;
  }

  PotentialCells(ArrayList<Cell> primary) {
    this.primary = primary;
  }

  Cell get() {
    int attempts = 0;

    while(attempts < primary.size()) {
      attempts++;
      Cell potentialCell = primary.get(rng.nextInt(primary.size()));
      if (!potentialCell.hasBuilding()) {
        return potentialCell;
      }
    }

    if (secondary != null) {
      while(attempts < secondary.size()) {
        attempts++;
        Cell potentialCell = secondary.get(rng.nextInt(secondary.size()));
        if (!potentialCell.hasBuilding()) {
          return potentialCell;
        }
      }
    }

    return null;
  }
}