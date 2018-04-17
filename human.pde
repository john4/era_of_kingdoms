abstract class Human extends WorldlyObject {
  HumanCode type;
  float TARGET_RADIUS = 2;
  float SLOW_RADIUS = 5;
  float MAX_ACCELERATION = 0.01;
  float MAX_HEALTH = 250;
  float STARVE_DAMAGE = 25;
  int collisions = 0;

  int[] c = new int[3];
  float health;
  PlayerState ownerState;
  Building assignedBuilding;
  Blackboard blackboard;
  Task btree;
  float moveSpeed;

  Human(Cell initialLocation, Building buildingAssignment, PlayerState ownerState) {
    super(initialLocation);
    this.w = this.h = 4;
    this.c = new int[]{20, 20, 20};
    this.health = MAX_HEALTH;
    this.moveSpeed = 0.1;
    this.assignedBuilding = buildingAssignment;
    buildingAssignment.addAssignee(this);
    this.ownerState = ownerState;

    this.blackboard = new Blackboard();
    this.blackboard.put("Human", this);

    Task[] wanderSequence = new Task[2];
    wanderSequence[0] = new Wander(this.blackboard, 25);
    wanderSequence[1] = new Move(this.blackboard);

    this.btree = new Sequence(this.blackboard, wanderSequence);
  }

  void unassignFromBuilding() {
    this.assignedBuilding.removeAssignee(this);
    this.assignedBuilding = null;
  }

  void assignToNewBuilding(Building newAssignment) {
    this.assignedBuilding.removeAssignee(this);
    this.assignedBuilding = newAssignment;
    newAssignment.addAssignee(this);
  }

  void draw() {
    this.btree.execute();

    noStroke();
    fill(c[0], c[1], c[2]);
    ellipse(this.pos.x, this.pos.y, this.w, this.w);

    if (this.health < MAX_HEALTH) {
      fill(255, 0, 0);
      rect(this.pos.x - 4, this.pos.y - 4, 8, 2);
      fill(0, 255, 0);
      rect(this.pos.x - 4, this.pos.y - 4, 8 * (this.health / MAX_HEALTH), 2);
    }
  }

  void behave() {
    this.btree.execute();
  }

  void moveTo(float x, float y, boolean withAvoidance) {
    // Get the direction and distance to the target
    PVector target = new PVector(x, y);
    PVector direction = target.sub(pos);
    float distance = direction.mag();

    if (!withAvoidance) { // force human to go to passable node
      this.vel.rotate(PVector.angleBetween(target, this.vel));
      this.vel.setMag(.25);
    }

    // Check if we are there, no steering
    if (distance < TARGET_RADIUS) {
      return;
    }

    // If we are outside SLOW_RADIUS, go max speed
    float targetSpeed = 0;
    if (distance > SLOW_RADIUS) {
      targetSpeed = this.moveSpeed;
    } else {  // calculate a scaled speed
      targetSpeed = this.moveSpeed * distance / SLOW_RADIUS;
    }

    // Velocity combines speed and direction
    PVector targetVelocity = direction;
    targetVelocity.normalize();
    targetVelocity.mult(targetSpeed);

    // Acceleration tries to get to the target velocity
    PVector acceleration = targetVelocity.sub(this.vel);

    // Check if the acceleration is too fast
    if (acceleration.mag() > MAX_ACCELERATION) {
      acceleration.normalize();
      acceleration.mult(MAX_ACCELERATION);
    }

    // Calculate new character velocity
    this.vel.add(acceleration);
    // Calculate new position
    PVector pos = this.pos.copy();
    PVector ray = this.vel.copy();
    pos.add(ray);
    Cell c = boardMap.cellAtPos(pos);

    if(withAvoidance && c.hasImpass(assignedBuilding)){
      this.collisions++;
      // avoid will temporarily treat the closest passable cell as the target
      avoid(x, y);
    } else {
      // Move the character
      this.pos.add(this.vel);
      // Update this character's cell location
      this.loc = boardMap.cellAtPos(this.pos);
    }
  }

  void avoid(float x, float y) {
    ArrayList<Cell> passableCells = this.loc.getCardinalNeighbors();

    Cell closestCell = null;
    float closestDistance = 9999f;
    for (Cell c : passableCells) {
      if (!c.hasImpass(assignedBuilding)) {
        float dist = c.euclideanDistanceTo(x, y);
        if (dist < closestDistance) {
          closestDistance = dist;
          closestCell = c;
        }
      }
    }

    if (closestCell != null) { // move to closest passable cell
      moveTo(closestCell.pos.x, closestCell.pos.y, false);
    }
    // otherwise don't move since you are trapped!
  }

  void starve() {
    this.health -= this.STARVE_DAMAGE;
  }
}

enum HumanCode {
  FARMER, LUMBERJACK, MINER, SOLDIER, FREE;

  @Override
  public String toString() {
      return name().toLowerCase();
  }
}
