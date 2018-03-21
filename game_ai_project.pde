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
  int cellSize = map.gridsize;
  int x = mouseX/cellSize;
  int y = mouseY/cellSize;
  int rows = map.numRows;
  int cols = map.numCols;
  if(x >= 0 && x < rows && y >= 0 && y < cols) {
    terrain = map.cells[x][y].getTerrainName();
  }
  for(Building building : state.buildings) {
    if (building.loc.isIn(mouseX-map.xo,mouseY-map.yo)) {
      terrain += ", " + building.getName();
    }
  }
  String cursor = "(" + (mouseX- map.xo) + ", " + (mouseY- map.yo) + "), " + terrain;
  String resources = "Food: " + state.foodSupply + "  Lumber: " + state.lumberSupply + "  Population: " + state.citizens.size() + "  Soldiers: " + state.soldiers.size();
  fill(255);
  rect(-map.xo,-map.yo, rows*cellSize,20);
  rect(mouseX + 10- map.xo, mouseY-10- map.yo, cursor.length() * 8,20);
  rect(rows*cellSize-200-map.xo,40-map.yo,200,max(state.messages.size()*60, 40));

  fill(0);
  text(cursor, mouseX + 10- map.xo, mouseY + 2.5- map.yo);
  text(resources, 20 - map.xo,15 - map.yo);
  String messages = "";
  for(Message message: state.messages) {
    messages += message.message + "\n\n";
  }

  text(messages, rows*cellSize-190-map.xo, 40 - map.yo, 200, 1000);
}
