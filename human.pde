class Human extends WorldlyObject {
  int[] color;
  
  Human(Cell initialLocation) {
    super(initialLocation);
    this.width = this.height = 5;
    color = new int[]{20, 20, 20};
  }
  
  void draw() {
    ellipse(this.pos.x, this.pos.y, this.width, this.width);
  }
}