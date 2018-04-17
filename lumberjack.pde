class Lumberjack extends Citizen {

  Lumberjack(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.type = HumanCode.LUMBERJACK;
    this.c = new int[]{69,44,0};

    Task[] gatherSequenceItems = new Task[3];
    gatherSequenceItems[0] = new Gather(this.blackboard, 2);
    gatherSequenceItems[1] = new Process(this.blackboard);
    gatherSequenceItems[2] = new DropOff(this.blackboard, "Lumber");

    this.btree = new Sequence(this.blackboard, gatherSequenceItems);
  }
}
