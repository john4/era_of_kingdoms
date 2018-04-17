class UserInterface {
  MessageQueue messageQueue;
  ArrayList<Panel> panels;

  UserInterface() {
    messageQueue = new MessageQueue();
    panels = new ArrayList<Panel>();

    ArrayList<ATarget> targets = new ArrayList<ATarget>();
    targets.add(new AddFarmerTarget());
    targets.add(new RemoveFarmerTarget());
    targets.add(new AddLumberjackTarget());
    targets.add(new RemoveLumberjackTarget());
    targets.add(new AddMinerTarget());
    targets.add(new RemoveMinerTarget());
    targets.add(new AddSoldierTarget());
    targets.add(new RemoveSoldierTarget());
    targets.add(new SetSoldierOffensiveTarget());
    targets.add(new SetSoldierDefensiveTarget());

    ArrayList<ATarget> buildTargets = new ArrayList<ATarget>();
    buildTargets.add(new BuildFarmTarget());
    buildTargets.add(new BuildHovelTarget());
    buildTargets.add(new BuildSawmillTarget());
    buildTargets.add(new BuildStockpileTarget());
    buildTargets.add(new BuildBarracksTarget());
    buildTargets.add(new BuildFoundryTarget());

    PImage people = loadImage("stickfigure.png");
    people.resize(16, 16);
    PImage buildings = loadImage("hovel.png");
    buildings.resize(16, 16);
    panels.add(new Panel(200, boardMap.numCols*boardMap.gridsize-200,boardMap.numRows*boardMap.gridsize-400, targets, 0, 0, 255, people));
    panels.add(new Panel(400, boardMap.numCols * boardMap.gridsize - 200, boardMap.numRows * boardMap.gridsize - 400, buildTargets, 255, 0, 0, buildings));
  }

  void draw(PlayerState state) {
    textSize(14);
    int cellSize = boardMap.gridsize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;
    float zoom = boardMap.zoom;

    if (boardMap.zoom != 1) {
      scale(0.5);
    }

    float actualMouseX = (mouseX - boardMap.xo) / zoom;
    float actualMouseY = (mouseY - boardMap.yo) / zoom;

    String terrain = "";

    Cell hoveredCell = boardMap.getHoveredCell();

    if (hoveredCell.i >= 0 && hoveredCell.i < rows && hoveredCell.j >= 0 && hoveredCell.j < cols) {
      terrain = hoveredCell.getTerrainName();
    }

    for (Building building : state.getBuildings()) {
      if (building.loc.isIn(actualMouseX, actualMouseY)) {
        terrain += ", " + building.getName();
      }
    }

    String cursor = "(" + hoveredCell.i + ", " + hoveredCell.j + "), " + terrain;

    int lumberjackCount = 0;
    int farmerCount = 0;
    int minerCount = 0;
    int freeCitizenCount = 0;
    int allHumanCount = state.getCitizens().size() + state.getSoldiers().size();

    for (Human c : state.getCitizens()) {
      if (c instanceof Lumberjack) {
        lumberjackCount++;
      } else if (c instanceof Farmer) {
        farmerCount++;
      } else if (c instanceof Miner) {
        minerCount++;
      } else if (c instanceof FreeCitizen) {
        freeCitizenCount++;
      }
    }

    String resources = "Food: " + state.foodSupply + "  Lumber: " + state.resourceSupply.get(ResourceCode.LUMBER) +
      "  Metal: " + state.resourceSupply.get(ResourceCode.METAL) + "  Population: " + allHumanCount + " / " + state.populationCapacity +
      "  Free Citizens: " + freeCitizenCount + "  Farmers: " + farmerCount + "  Lumberjacks: " + lumberjackCount +
      "  Miners: " + minerCount + "  Soldiers: " + state.getSoldiers().size();

    fill(255);
    rect(-boardMap.xo, -boardMap.yo, rows * cellSize, 20);
    rect(mouseX + 10 - boardMap.xo, mouseY - 10 - boardMap.yo, cursor.length() * 8,20);

    // control panel
    for (Panel panel : panels) {
      panel.draw();
    }

    fill(0);
    text(cursor, mouseX + 10 - boardMap.xo, mouseY + 2.5 - boardMap.yo);
    text(resources, 20 - boardMap.xo, 15 - boardMap.yo);

    // Messages
    String messageStr = "";
    for (Message message : messageQueue.messages) {
      messageStr += message.message + "\n\n";
    }

    PFont font = loadFont("AmericanTypewriter-Bold-14.vlw");
    textFont(font);
    text(messageStr, 20 - boardMap.xo, 40 - boardMap.yo, 200, 1000);

    if (state.placingBuilding != BuildingCode.NONE) {
      fill(255, 255, 255);
      if (!boardMap.validBuildingSpot(hoveredCell)) {
        fill(255, 0, 0);
      }

      rect(hoveredCell.x * zoom , hoveredCell.y * zoom, 8 * zoom, 8 * zoom);

    }
  }
}