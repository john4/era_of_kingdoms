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
    state.addLumberjack();
  }

  void decrement() {
    state.removeLumberjack();
  }
}

class FarmerTarget extends ATarget implements ITarget {
  FarmerTarget(){
    super("Farmer");
  }

  void increment() {
    state.addFarmer();
  }

  void decrement() {
    state.removeFarmer();
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
    // increase soldiers
  }

  void decrement() {
    // decrease soldiers
  }
}
