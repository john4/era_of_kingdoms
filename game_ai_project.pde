// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler
//

Map map;
GameState state;

void setup() {
  size(960, 540);
  map = new Map(960, 540, 10);
  map.generate();
  state = new GameState();
}

void draw() {
  map.draw();
  state.draw();
}