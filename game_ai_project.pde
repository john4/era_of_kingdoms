// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler
//

Map map;

void setup() {
  size(960, 540);
  map = new Map(960, 540, 10);
  map.generate();
}

void draw() {
  map.draw();
}