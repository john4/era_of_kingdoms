// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler


import java.util.Random;
import processing.sound.*;

BoardMap boardMap;
GameState state;
UserInterface userInterface;
boolean showControlPanel = true;
final int CELL_SIZE = 10;
SoundFile bgmFile;

Random rng = new Random();

// temp
PotentialPathNode path;

void setup() {
  size(960, 540);
  noSmooth();
  boardMap = new BoardMap(960, 540, CELL_SIZE);
  boardMap.generate();
  state = new GameState();
  userInterface = new UserInterface();
  bgmFile = new SoundFile(this, "bgm-drizzle.mp3");
  bgmFile.loop();


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
  if (mouseButton == LEFT) {
    System.out.println("Left Click");

    int cellSize = boardMap.gridsize;
    int x = mouseX/cellSize;
    int y = mouseY/cellSize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;

    if (state.humanPlayer.placingBuilding != BuildingCode.NONE) {
      Cell hoveredCell = boardMap.cellAtPos(new PVector(mouseX, mouseY));
      if (boardMap.validBuildingSpot(hoveredCell)) {
        state.humanPlayer.placeBuilding(hoveredCell);
      }
    }

    for (Panel panel : userInterface.panels) {
      if (panel.inPanelToggle(mouseX, mouseY)) {
        panel.toggleVisible();
      }

      panel.click();
    }
  } else {
    System.out.println("Right Click");
    state.humanPlayer.placingBuilding = BuildingCode.NONE;
  }

}