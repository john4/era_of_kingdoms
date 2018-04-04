
abstract class ATarget {
  String name;

  ATarget(String name) {
    this.name = name;
  }

  abstract void clicked();

  String getName() {
    return this.name;
  }
}

/************************************************************************
 * Citizen Panel Targets                                                *
 ************************************************************************/

class AddLumberjackTarget extends ATarget {
  AddLumberjackTarget() {
    super("+ Lumberjack");
  }

  void clicked() {
    state.humanPlayer.addLumberjack();
  }
}

class RemoveLumberjackTarget extends ATarget {
  RemoveLumberjackTarget() {
    super("- Lumberjack");
  }

  void clicked() {
    state.humanPlayer.removeLumberjack();
  }
}

class AddFarmerTarget extends ATarget {
  AddFarmerTarget(){
    super("+ Farmer");
  }

  void clicked() {
    state.humanPlayer.addFarmer();
  }
}

class RemoveFarmerTarget extends ATarget {
  RemoveFarmerTarget() {
    super("- Farmer");
  }

  void clicked() {
    state.humanPlayer.removeFarmer();
  }
}

class AddSoldierTarget extends ATarget {
  AddSoldierTarget() {
    super("+ Soldier");
  }

  void clicked() {
    state.humanPlayer.addSoldier();
  }
}

class RemoveSoldierTarget extends ATarget {
  RemoveSoldierTarget() {
    super("- Soldier");
  }

  void clicked() {
    state.humanPlayer.removeSoldier();
  }
}

class AddMinerTarget extends ATarget {
    AddMinerTarget() {
      super("+ Miner");
    }

    void clicked() {
      state.humanPlayer.addMiner();
    }

    void decrement() {
      state.humanPlayer.removeMiner();
    }
}

class RemoveMinerTarget extends ATarget {
    RemoveMinerTarget() {
      super("- Miner");
    }

    void clicked() {
      state.humanPlayer.removeMiner();
    }
}

class SetSoldierOffensiveTarget extends ATarget {
  SetSoldierOffensiveTarget() {
    super("Offensive Mode");
  }

  void clicked() {
    state.humanPlayer.setCombatMode(CombatMode.OFFENSIVE);
  }
}

class SetSoldierDefensiveTarget extends ATarget {
  SetSoldierDefensiveTarget() {
    super("Defensive Mode");
  }

  void clicked() {
    state.humanPlayer.setCombatMode(CombatMode.DEFENSIVE);
  }
}

/************************************************************************
 * Build Panel Targets                                                  *
 ************************************************************************/

class BuildFarmTarget extends ATarget {
  BuildFarmTarget() {
    super("+ Farm");
  }

  void clicked() {
    state.humanPlayer.placingBuilding = BuildingCode.FARM;
  }
}

class BuildHovelTarget extends ATarget {
  BuildHovelTarget() {
    super("+ Hovel");
  }

  void clicked() {
    state.humanPlayer.placingBuilding = BuildingCode.HOVEL;
  }
}

class BuildSawmillTarget extends ATarget {
  BuildSawmillTarget() {
    super("+ Sawmill");
  }

  void clicked() {
    state.humanPlayer.placingBuilding = BuildingCode.SAWMILL;
  }
}

class BuildStockpileTarget extends ATarget {
  BuildStockpileTarget() {
    super("+ Stockpile");
  }

  void clicked() {
    state.humanPlayer.placingBuilding = BuildingCode.STOCKPILE;
  }
}
