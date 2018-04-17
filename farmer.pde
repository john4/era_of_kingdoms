class Farmer extends Citizen {
  Crop crop;
  final HumanCode type = HumanCode.FARMER;

  Farmer(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{176,56,30};
    this.crop = null;

    Task[] farmerSelectorPlant = new Task[2];
    farmerSelectorPlant[0] = new Plant(this.blackboard);
    farmerSelectorPlant[1] = new Move(this.blackboard);
    Selector farmerSelectorPlants = new Selector(this.blackboard, farmerSelectorPlant);

    Task[] farmerSelectorHarvest = new Task[2];
    farmerSelectorHarvest[0] = new Harvest(this.blackboard);
    farmerSelectorHarvest[1] = new Move(this.blackboard);
    Selector farmerSelectorHarvests = new Selector(this.blackboard, farmerSelectorHarvest);

    Task[] farmerSelectorProcess = new Task[2];
    farmerSelectorProcess[0] = new Process(this.blackboard);
    farmerSelectorProcess[1] = new Move(this.blackboard);
    Selector farmerSelectorProcesses = new Selector(this.blackboard, farmerSelectorProcess);

    Task[] farmerSelectorDropOff = new Task[2];
    farmerSelectorDropOff[0] = new DropOff(this.blackboard, "Food");
    farmerSelectorDropOff[1] = new Move(this.blackboard);
    Selector farmerSelectorDropOffs = new Selector(this.blackboard, farmerSelectorDropOff);

    Task[] farmerSequenceItem = new Task[4];
    farmerSequenceItem[0] = farmerSelectorPlants;
    farmerSequenceItem[1] = farmerSelectorHarvests;
    farmerSequenceItem[2] = farmerSelectorProcesses;
    farmerSequenceItem[3] = farmerSelectorDropOffs;

    this.btree = new Sequence(this.blackboard, farmerSequenceItem);
  }
}
