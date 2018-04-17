class Soldier extends Human {
  final HumanCode type = HumanCode.SOLDIER;

  Soldier(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);

    this.moveSpeed = 0.15;

    Task[] seekItems = new Task[2];
    seekItems[0] = new TargetEnemy(this.blackboard, 50);
    seekItems[1] = new AttackEnemy(this.blackboard);
    seekItems[2] = new Move(this.blackboard);
    Task seekSequence = new Sequence(this.blackboard, seekItems);

    Task[] wanderSequence = new Task[2];
    wanderSequence[0] = new Wander(this.blackboard, 50);
    wanderSequence[1] = new Move(this.blackboard);
    Sequence wander = new Sequence(this.blackboard, wanderSequence);

    Task[] patrolItems = new Task[2];
    patrolItems[0] = seekSequence;
    patrolItems[1] = wander;

    this.btree = new Selector(this.blackboard, patrolItems);
  }
}

enum CombatMode {
  OFFENSIVE, DEFENSIVE;
}
