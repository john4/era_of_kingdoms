class Human extends WorldlyObject {
  int[] c = new int[3];
  
  Human(Cell initialLocation) {
    super(initialLocation);
    this.w = this.h = 5;
    this.c = new int[]{20, 20, 20};
  }
  
  void draw() {
    ellipse(this.pos.x, this.pos.y, this.w, this.w);
  }
}