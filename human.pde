abstract class Human extends WorldlyObject {
  int[] c = new int[3];
  int health;
  Building assignedBuilding;
  
  Human(Cell initialLocation, Building buildingAssignment) {
    super(initialLocation);
    this.w = this.h = 5;
    this.c = new int[]{20, 20, 20};
    this.health = 100;
    this.assignedBuilding = buildingAssignment;
  }
  
  void draw() {
    stroke(c[0], c[1], c[2]);
    ellipse(this.pos.x, this.pos.y, this.w, this.w);
  }
  
  void behave() {};
}