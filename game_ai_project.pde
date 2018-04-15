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
final int FRAME_RATE = 60;
SoundFile bgmFile;

Random rng = new Random();

// temp
PotentialPathNode path;

void setup() {
  size(960, 540);
  noSmooth();
  frameRate(FRAME_RATE);
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
    System.out.println("Left Click at (" + mouseX + ", " + mouseY + ")");
    BuildingCode pB = state.humanPlayer.placingBuilding;

    float zoom = boardMap.zoom;
    float actualMouseX = (mouseX - boardMap.xo) / zoom;
    float actualMouseY = (mouseY - boardMap.yo) / zoom;
    int cellX = (int) (actualMouseX / boardMap.gridsize);
    int cellY = (int) (actualMouseY / boardMap.gridsize);

    if (cellX < 0) {
      cellX = 0;
    }

    if (cellY < 0) {
      cellY = 0;
    }

    if (cellX >= boardMap.numRows) {
      cellX = boardMap.numRows - 1;
    }

    if (cellY >= boardMap.numCols) {
      cellY = boardMap.numCols - 1;
    }


    if (pB != BuildingCode.NONE) {
      Cell hoveredCell = boardMap.cells[cellX][cellY];
      if (boardMap.validBuildingSpot(hoveredCell)) {
        state.humanPlayer.placeBuilding(hoveredCell);
      } else {
        userInterface.messageQueue.add(new Message("Cannot place " + pB.toString() + " there!", state.gameStateIndex+FRAME_RATE*5));
      }
    }

    for (Panel panel : userInterface.panels) {
      if (panel.inPanelToggle(mouseX, mouseY)) {
        panel.toggleVisible();
      }

      panel.click();
    }
  } else {
    System.out.println("Right Click at (" + mouseX + ", " + mouseY + ")");
    state.humanPlayer.placingBuilding = BuildingCode.NONE;
  }

}
