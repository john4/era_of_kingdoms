abstract class Building extends WorldlyObject {
  int[] c = new int[3];
  String name;

  Building(Cell initialLocation, String name) {
    super(initialLocation);
    this.c = new int[]{20, 20, 20};
    this.name = name;
  }

  void draw() {
    fill(c[0], c[1], c[2]);
    rect(this.loc.x + 1, this.loc.y + 1, this.w, this.h);
  }

  String getName() {
    return this.name;
  }
}
