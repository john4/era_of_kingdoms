class Hal {
  static final int ACTION_COOLDOWN = 30;
  double cooldownIndex;

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

    cooldownIndex = gameState.gameStateIndex;

    townSquare = computerState.buildings.get(BuildingCode.TOWNSQUARE).get(0);
    HashSet<Cell> cellsNearbyTownSquareSet = townSquare.loc.getNearbyGrassCells(100);
    cellsNearbyTownSquare = cellsNearbyTownSquareSet.toArray(new Cell[cellsNearbyTownSquareSet.size()]);

    behaviorTree = new PlaceX(BuildingCode.FARM, computerState, cellsNearbyTownSquare);
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
    return false;
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
