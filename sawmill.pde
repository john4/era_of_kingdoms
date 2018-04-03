class Sawmill extends Building {
  Sawmill(Cell initialLocation) {
    super(initialLocation, "Sawmill");
    this.impassable = true;
  }
}
