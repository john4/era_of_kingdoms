class Farm extends Building {
  PImage img;

  Farm(Cell initialLocation) {
    super(initialLocation, "Farm");
    this.assignmentLimit = 2;
    this.impassable = true;
    this.img = loadImage("farm.png");
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}

class Crop extends Building {
  PImage img;
  Farmer farmer;

  Crop(Cell initialLocation) {
    super(initialLocation, "Crop");
    this.img = loadImage("carrot.png");
    this.farmer = null;
    this.impassable = false;
  }

  void draw() {
    image(this.img, this.loc.x + 1, this.loc.y + 1);
  }
}
