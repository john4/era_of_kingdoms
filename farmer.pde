class Farmer extends Citizen {
  Crop crop;
  final HumanCode type = HumanCode.FARMER;

  Farmer(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{176,56,30};
    this.crop = null;

    Task[] farmerSequenceItems = new Task[4];
    farmerSequenceItems[0] = new Plant(this.blackboard);
    farmerSequenceItems[1] = new Harvest(this.blackboard);
    farmerSequenceItems[2] = new Process(this.blackboard);
    farmerSequenceItems[3] = new DropOff(this.blackboard, "Food");
    this.btree = new Sequence(this.blackboard, farmerSequenceItems);
  }
}
