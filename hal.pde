class Hal {
  GameState gameState;
  PlayerState computerState;
  PlayerState humanState;
  Building townSquare;
  Cell[] cellsNearbyTownSquare;

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

class RiskOfStarving extends HalTask {
  PlayerState state;

  RiskOfStarving(PlayerState state) {
    this.state = state;
  }

  boolean execute() {
    int foodNeed = state.citizens.size() + (state.soldiers.size() * 2);
    if (foodNeed == 0) {
      return FAIL;
    }
    int projection = state.foodSupply / foodNeed;
    return projection < 2 ? SUCCESS : FAIL;
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
        return SUCCESS;
      }
    }
    return FAIL;
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
        return SUCCESS;
      }
    }
    return FAIL;
  }
}
