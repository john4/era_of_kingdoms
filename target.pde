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

class FoodTarget extends ATarget implements ITarget {
  FoodTarget() {
    super("Food");
  }

  void increment() {
    state.foodSupply++;
  }

  void decrement() {
    state.foodSupply--;
  }
}

class LumberTarget extends ATarget implements ITarget {
  LumberTarget(){
    super("Lumber");
  }

  void increment() {
    state.lumberSupply++;
  }

  void decrement() {
    state.lumberSupply--;
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
