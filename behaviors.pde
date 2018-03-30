class Wander extends Task {
  Wander(Blackboard bb) {
    this.blackboard = bb;
  }

  int execute() {
    Human h = (Human) this.blackboard.get("Human");
    h.pos.x -= 1;
    return SUCCESS;
  }
}