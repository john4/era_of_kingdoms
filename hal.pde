class Hal {
  GameState gameState;
  PlayerState computerState;
  PlayerState humanState;
  Building townSquare;
  Cell[] cellsNearbyTownSquare;

  // TODO when we have human types: hashmap human type -> golden ratio / 32
  float goldenFarmers = 14 / 32;
  float goldenLumberjacks = 4 / 32;
  float goldenMiners = 4 / 32;
  float goldenSoldiers = 10 / 32;

  HalTask behaviorTree;

  Hal(GameState gameState, PlayerState computerState, PlayerState humanState) {
    this.gameState = gameState;
    this.computerState = computerState;
    this.humanState = humanState;

    townSquare = computerState.buildings.get(BuildingCode.TOWNSQUARE).get(0);
    HashSet<Cell> cellsNearbyTownSquareSet = townSquare.loc.getNearbyCells(100);
    cellsNearbyTownSquare = cellsNearbyTownSquareSet.toArray(new Cell[cellsNearbyTownSquareSet.size()]);

    behaviorTree = new PlaceFarm(computerState, cellsNearbyTownSquare);
  }

  boolean behave() {
    return behaviorTree.execute();
  }
}


abstract class HalTask {
  abstract boolean execute();  // returns FAIL = 0, SUCCESS = 1
  static final int BUILDING_PLACEMENT_COOLDOWN = 5;
  static final int HUMAN_ASSIGN_COOLDOWN = 5;
}

class AssignNextHuman extends HalTask {
  PlayerState state;

  AssignNextHuman(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    // if I have no free citizens, fail
    // calculate my ratios
    // find largest disparity
    // assign next human, success
  }
}

class RiskOfStarving extends HalTask {
  PlayerState state;

  RiskOfStarving(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    int foodNeed = state.citizens.size() + (state.soldiers.size() * 2);
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
    for (Soldier soldier : humanState.soldiers) {
      if (soldier.distanceTo(townSquare) < 250) {
        return true;
      }
    }
    return false;
  }
}

class PlaceFarm extends HalTask {
  PlayerState state;
  Cell[] potentialCells;

  PlaceFarm(PlayerState state, Cell[] potentialCells) {
    this.state = state;
    this.potentialCells = potentialCells;
  }

  boolean execute() {
    int attempts = 0;
    while(attempts < potentialCells.length) {
      attempts++;
      Cell potentialCell = potentialCells[rng.nextInt(potentialCells.length)];
      if (!potentialCell.hasBuilding()) {
        state.placeBuilding(potentialCell, BuildingCode.FARM);
        return true;
      }
    }
    return false;
  }
}
