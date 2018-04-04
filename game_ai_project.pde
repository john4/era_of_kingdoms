// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler
//

BoardMap boardMap;
GameState state;
UserInterface userInterface;
boolean showControlPanel = true;
final int CELL_SIZE = 10;

// temp
PotentialPathNode path;

void setup() {
  size(960, 540);
  boardMap = new BoardMap(960, 540, CELL_SIZE);
  boardMap.generate();
  state = new GameState();
  userInterface = new UserInterface();

  // path = boardMap.findPath(state.getBuildings().get(0).loc, state.getBuildings().get(2).loc);
}

void draw() {
  boardMap.draw();
  state.draw();
  state.step();
  userInterface.draw(state.humanPlayer);
  // path.draw();
}

void mouseClicked() {
  int cellSize = boardMap.gridsize;
  int x = mouseX/cellSize;
  int y = mouseY/cellSize;
  int rows = boardMap.numRows;
  int cols = boardMap.numCols;
  if(200 < mouseX && mouseX < 220 && cols*cellSize-20 < mouseY && mouseY < cols*cellSize) {
    userInterface.panels.get(0).isVisible = !userInterface.panels.get(0).isVisible;
  }

  for(Panel panel: userInterface.panels) {
    panel.click();
  }
}
