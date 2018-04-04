class Farmer extends Citizen {
  Crop crop;

  Farmer(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{176,56,30};
    this.crop = null;

    Task[] farmerSequenceItems = new Task[3];
    farmerSequenceItems[0] = new Plant(this.blackboard);
    farmerSequenceItems[1] = new Harvest(this.blackboard);
    farmerSequenceItems[2] = new DropOff(this.blackboard, "Food");
    this.btree = new Sequence(this.blackboard, farmerSequenceItems);
  }

  void draw() {
    super.draw();
    fill(255);
    textSize(2);
    text(str(this.carryWeight), this.pos.x - 1, this.pos.y + 1);
  }
}
