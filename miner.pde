class Miner extends Citizen {

  Miner(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);
    this.type = HumanCode.MINER;
    this.c = new int[]{255, 105, 180};

    Task[] gatherSelector = new Task[2];
    gatherSelector[0] = new Gather(this.blackboard, 1);
    gatherSelector[1] = new Move(this.blackboard);
    Selector gatherSelectors = new Selector(this.blackboard, gatherSelector);

    Task[] processSelector = new Task[2];
    processSelector[0] = new Process(this.blackboard);
    processSelector[1] = new Move(this.blackboard);
    Selector processSelectors = new Selector(this.blackboard, processSelector);

    Task[] dropoffSelector = new Task[2];
    dropoffSelector[0] = new DropOff(this.blackboard, "Metal");
    dropoffSelector[1] = new Move(this.blackboard);
    Selector dropoffSelectors = new Selector(this.blackboard, dropoffSelector);

    Task[] gatherSequenceItems = new Task[3];
    gatherSequenceItems[0] = gatherSelectors;
    gatherSequenceItems[1] = processSelectors;
    gatherSequenceItems[2] = dropoffSelectors;

    this.btree = new Sequence(this.blackboard, gatherSequenceItems);
  }
}
