class Hovel extends Building {
  PImage img;

  Hovel(Cell initialLocation) {
    super(initialLocation, "Hovel");
    this.img = loadImage("hovel.png");
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}