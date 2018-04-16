class Sawmill extends Building {
  PImage img;

  Sawmill(Cell initialLocation) {
    super(initialLocation, "Sawmill");
    this.assignmentLimit = 1;
    this.impassable = true;
    this.img = loadImage("sawblade.png");
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}
