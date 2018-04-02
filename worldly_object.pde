abstract class WorldlyObject {
  Cell loc;
  PVector pos;
  PVector vel;
  PVector lastNonZeroVel;
  float w, h;
  boolean impassable;

  abstract void draw();

  WorldlyObject(Cell initialLocation) {
    loc = initialLocation;
    pos = new PVector(initialLocation.x + initialLocation.gridsize/2, initialLocation.y + initialLocation.gridsize/2);
    vel = new PVector(0,0);
    lastNonZeroVel = null;
    w = h = initialLocation.gridsize - 2;
    impassable = true;
  }

  float distanceTo(Cell c) {
    return (float) (Math.sqrt(Math.pow(c.x - loc.x, 2) + Math.pow(c.y - loc.y, 2)));
  }

  void maybeUpdateCell() {

  }
}