abstract class Building extends WorldlyObject {
  int[] c = new int[3];

  Building(Cell initialLocation) {
    super(initialLocation);
    this.c = new int[]{20, 20, 20};
  }

  void draw() {
    stroke(c[0], c[1], c[2]);
    rect(this.pos.x, this.pos.y, this.pos.x + w, this.pos.y + h);
  }
}