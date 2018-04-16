class Barracks extends Building {
  PImage img;

  Barracks(Cell initialLocation) {
    super(initialLocation, "Sawmill");
    this.assignmentLimit = 6;
    this.img = loadImage("sword.png");
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}
