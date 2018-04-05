class UserInterface {
  ArrayList<Message> messages;
  ArrayList<Panel> panels;

  UserInterface() {
    messages = new ArrayList<Message>();
    panels = new ArrayList<Panel>();

    messages.add(new Message("Welcome to <insert name here>", 20));
    messages.add(new Message("Need additional Pylons", 20));

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

    panels.add(new Panel(200, boardMap.numCols*boardMap.gridsize-200,boardMap.numRows*boardMap.gridsize-400, targets, 0, 0, 255));
    panels.add(new Panel(400, boardMap.numCols * boardMap.gridsize - 200, boardMap.numRows * boardMap.gridsize - 400, buildTargets, 255, 0, 0));
  }

  void draw(PlayerState state) {
    textSize(14);
    String terrain = "";
    int cellSize = boardMap.gridsize;
    int x = mouseX/cellSize;
    int y = mouseY/cellSize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;
    Cell hoveredCell = boardMap.cells[x][y];
    if(x >= 0 && x < rows && y >= 0 && y < cols) {
      terrain = hoveredCell.getTerrainName();
    }
    for(Building building : state.getBuildings()) {
      if (building.loc.isIn(mouseX-boardMap.xo,mouseY-boardMap.yo)) {
        terrain += ", " + building.getName();
      }
    }
    String cursor = "(" + (mouseX- boardMap.xo) + ", " + (mouseY- boardMap.yo) + "), " + terrain;

    int lumberjackCount = 0;
    int farmerCount = 0;
    int minerCount = 0;
    int freeCitizenCount = 0;

    for (Citizen c : state.citizens) {
      if (c instanceof Lumberjack) {
        lumberjackCount++;
      } else if (c instanceof Farmer) {
        farmerCount++;
      } else if (c instanceof Miner) {
        minerCount++;
      } else if (c.isFree()) {
        freeCitizenCount++;
      }
    }

    String resources = "Food: " + state.foodSupply + "  Lumber: " + state.lumberSupply +
      "  Metal: " + state.metalSupply + "  Population Capacity: " + state.populationCapacity +
      "  Free Citizens: " + freeCitizenCount + "  Farmers: " + farmerCount + "  Lumberjacks: " + lumberjackCount +
      "  Miners: " + minerCount + "  Soldiers: " + state.soldiers.size();

    fill(255);
    rect(-boardMap.xo,-boardMap.yo, rows*cellSize,20);
    rect(mouseX + 10- boardMap.xo, mouseY-10- boardMap.yo, cursor.length() * 8,20);
    rect(rows*cellSize-200-boardMap.xo,40-boardMap.yo,200,max(messages.size()*60, 40));

    // control panel
    for(Panel panel : panels) {
      panel.draw();
    }

    fill(0);
    text(cursor, mouseX + 10- boardMap.xo, mouseY + 2.5- boardMap.yo);
    text(resources, 20 - boardMap.xo,15 - boardMap.yo);
    String messageStr = "";
    for(Message message: messages) {
      messageStr += message.message + "\n\n";
    }

    text(messageStr, rows*cellSize-190-boardMap.xo, 40 - boardMap.yo, 200, 1000);

    if (state.placingBuilding != BuildingCode.NONE) {
      fill(255, 255, 255);
      if (!boardMap.validBuildingSpot(hoveredCell)) {
        fill(255, 0, 0);
      }

      rect(hoveredCell.x + 1, hoveredCell.y + 1, 8, 8);
    }
  }
}