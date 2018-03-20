abstract class WorldlyObject {
  Cell loc;
  PVector pos;
  PVector vel;
  PVector lastNonZeroVel;
  float width, height;
  boolean impassable;
  
  abstract void draw();
  
  WorldlyObject(Cell initialLocation) {
    loc = initialLocation;
    pos = new PVector(initialLocation.x + initialLocation.i/2, initialLocation.y + initialLocation.j/2);
    vel = new PVector(0,0);
    lastNonZeroVel = null;
    width = initialLocation.i;
    height = initialLocation.j;
    impassable = true;
  }
  
  float distanceTo(Cell c) {
    return (float) (Math.sqrt(Math.pow(c.x - loc.x, 2) + Math.pow(c.y - loc.y, 2)));
  };
}