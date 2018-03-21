// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler
//

Map map;
GameState state;
boolean showControlPanel = true;

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

void mouseClicked() {
  int cellSize = map.gridsize;
  int x = mouseX/cellSize;
  int y = mouseY/cellSize;
  int rows = map.numRows;
  int cols = map.numCols;
  if(200 < mouseX && mouseX < 220 && cols*cellSize-20 < mouseY && mouseY < cols*cellSize) {
    state.panels.get(0).isVisible = !state.panels.get(0).isVisible;
  }
  
  for(Panel panel: state.panels) {
    panel.click();
  }
}
