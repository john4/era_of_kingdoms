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
  drawInterface();
}

void drawInterface() {
  textSize(14);
  String terrain = "";
  int x = mouseX/map.gridsize;
  int y = mouseY/map.gridsize;
  if(x < map.numRows && y < map.numCols) {
    terrain = map.cells[x][y].getTerrainName();
  }
  for(Building building : state.buildings) {
    if (building.loc.isIn(mouseX, mouseY)) {
      terrain += ", " + building.getName();
    }
  }
  String s = "(" + mouseX + ", " + mouseY + "), " + terrain;
  text(s, mouseX + 10, mouseY-10);
}