class Foundry extends Building {
  PImage img;

  Foundry(Cell initialLocation) {
    super(initialLocation, "Sawmill");
    this.img = loadImage("pick.png");
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}
