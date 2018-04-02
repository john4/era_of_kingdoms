

abstract class Human extends WorldlyObject {
  float TARGET_RADIUS = 5;
  float SLOW_RADIUS = 10;
  float MAX_SPEED = 0.1;
  float MAX_ACCELERATION = 0.01;

  int[] c = new int[3];
  int health;
  Building assignedBuilding;
  Blackboard blackboard;
  Task btree;

  Human(Cell initialLocation, Building buildingAssignment) {
    super(initialLocation);
    this.w = this.h = 4;
    this.c = new int[]{20, 20, 20};
    this.health = 100;
    this.assignedBuilding = buildingAssignment;

    this.blackboard = new Blackboard();
    this.blackboard.put("Human", this);
    this.btree = new Wander(this.blackboard, 50);
  }

  void draw() {
    this.btree.execute();
    noStroke();
    fill(c[0], c[1], c[2]);
    ellipse(this.pos.x, this.pos.y, this.w, this.w);
  }

  void behave() {
    this.btree.execute();
  }

  void moveTo(float x, float y) {
    // Get the direction and distance to the target
    PVector target = new PVector(x, y);
    PVector direction = target.sub(pos);
    float distance = direction.mag();

    // Check if we are there, no steering
    if (distance < TARGET_RADIUS) {
      return;
    }

    // If we are outside SLOW_RADIUS, go max speed
    float targetSpeed = 0;
    if (distance > SLOW_RADIUS) {
      targetSpeed = MAX_SPEED;
    } else {  // calculate a scaled speed
      targetSpeed = MAX_SPEED * distance / SLOW_RADIUS;
    }

    // Velocity combines speed and direction
    PVector targetVelocity = direction;
    targetVelocity.normalize();
    targetVelocity.mult(targetSpeed);

    // Acceleration tries to get to the target velocity
    PVector acceleration = targetVelocity.sub(this.vel);

    // Steer away from obstacles
    // float dist = 0;
    // float s = 0;
    // for (int i = 0; i < obstacles.size(); i++) {
    //   Obstacle o = obstacles.get(i);
    //   dist = PVector.dist(pos, o.pos);
    //   s = o.separationConstant / (dist * dist);
    //   acceleration.sub(s, s);
    // }

    // Check if the acceleration is too fast
    if (acceleration.mag() > MAX_ACCELERATION) {
      acceleration.normalize();
      acceleration.mult(MAX_ACCELERATION);
    }

    // Calculate new character velocity
    this.vel.add(acceleration);

    // Move the character
    this.pos.add(this.vel);

    // Update this character's cell location
    this.loc = boardMap.cellAtPos(this.pos);
  }
}
