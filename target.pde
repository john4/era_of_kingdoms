interface ITarget {
  void increment();
  void decrement();
  String getName();
}

abstract class ATarget implements ITarget {
  String name;

  ATarget(String name) {
    this.name = name;
  }

  String getName() {
    return this.name;
  }
}

class LumberjackTarget extends ATarget implements ITarget {
  LumberjackTarget() {
    super("Lumberjack");
  }

  void increment() {
    state.humanPlayer.addLumberjack();
  }

  void decrement() {
    state.humanPlayer.removeLumberjack();
  }
}

class FarmerTarget extends ATarget implements ITarget {
  FarmerTarget(){
    super("Farmer");
  }

  void increment() {
    state.humanPlayer.addFarmer();
  }

  void decrement() {
    state.humanPlayer.removeFarmer();
  }
}

class PopulationTarget extends ATarget implements ITarget {
  PopulationTarget() {
    super("Population");
  }

  void increment() {
    // increase population
  }

  void decrement() {
    // decrease population
  }
}

class SoldierTarget extends ATarget implements ITarget {
  SoldierTarget() {
    super("Soldiers");
  }

  void increment() {
    state.humanPlayer.addSoldier();
  }

  void decrement() {
    state.humanPlayer.removeSoldier();
  }
}

class MinerTarget extends ATarget implements ITarget {
    MinerTarget() {
      super("Miners");
    }

    void increment() {
      state.humanPlayer.addMiner();
    }

    void decrement() {
      state.humanPlayer.removeMiner();
    }
}
