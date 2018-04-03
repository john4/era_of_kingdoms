class Lumberjack extends Citizen {
  Lumberjack(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.c = new int[]{69,44,0};

    Task[] gatherSequenceItems = new Task[2];
    gatherSequenceItems[0] = new Gather(this.blackboard, 2);
    gatherSequenceItems[1] = new DropOff(this.blackboard, "Lumber");
    this.btree = new Sequence(this.blackboard, gatherSequenceItems);
  }

  void draw() {
    super.draw();
    fill(255);
    textSize(2);
    text(str(this.carryWeight), this.pos.x - 1, this.pos.y + 1);
  }
}
