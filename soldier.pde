class Soldier extends Human {
  final HumanCode type = HumanCode.SOLDIER;

  Soldier(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation, buildingAssignment, ownerState);


    Task[] seekItems = new Task[2];
    seekItems[0] = new TargetEnemy(this.blackboard, 50);
    seekItems[1] = new AttackEnemy(this.blackboard);
    Task seekSequence = new Sequence(this.blackboard, seekItems);

    Task wander = new Wander(this.blackboard, 50);

    Task[] patrolItems = new Task[2];
    patrolItems[0] = seekSequence;
    patrolItems[1] = wander;

    this.btree = new Selector(this.blackboard, patrolItems);
  }
}

enum CombatMode {
  OFFENSIVE, DEFENSIVE;
}