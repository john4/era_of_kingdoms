class Miner extends Citizen {
  Miner(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{255, 105, 180};

    Task[] gatherSequenceItems = new Task[3];
    gatherSequenceItems[0] = new Gather(this.blackboard, 1);
    gatherSequenceItems[1] = new Process(this.blackboard);
    gatherSequenceItems[2] = new DropOff(this.blackboard, "Metal");
    this.btree = new Sequence(this.blackboard, gatherSequenceItems);
  }

  void draw() {
    super.draw();
    fill(255);
    textSize(2);
    text(str(this.carryWeight), this.pos.x - 1, this.pos.y + 1);
  }
}
