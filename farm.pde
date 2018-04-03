class Farm extends Building {
  Farm(Cell initialLocation) {
    super(initialLocation, "Farm");
  }

  void draw() {
    super.draw();
    fill(255, 255, 255);
    textSize(4);
    text("F", this.pos.x, this.pos.y);
  }
}

class Crop extends Building {
  PImage img;
  Farmer farmer;

  Crop(Cell initialLocation) {
    super(initialLocation, "Crop");
    this.img = loadImage("carrot.png");
    this.farmer = null;
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}