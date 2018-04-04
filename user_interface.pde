class UserInterface {
  ArrayList<Message> messages;
  ArrayList<Panel> panels;

  UserInterface() {
    messages = new ArrayList<Message>();
    panels = new ArrayList<Panel>();

    messages.add(new Message("Welcome to <insert name here>", 20));
    messages.add(new Message("Need additional Pylons", 20));

    ArrayList<ITarget> targets = new ArrayList<ITarget>();
    targets.add(new FarmerTarget());
    targets.add(new LumberjackTarget());
    targets.add(new MinerTarget());
    targets.add(new PopulationTarget());
    targets.add(new SoldierTarget());

    panels.add(new Panel(200, boardMap.numCols*boardMap.gridsize-200,boardMap.numRows*boardMap.gridsize-400, targets));
  }

  void draw(PlayerState state) {
    textSize(14);
    String terrain = "";
    int cellSize = boardMap.gridsize;
    int x = mouseX/cellSize;
    int y = mouseY/cellSize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;
    if(x >= 0 && x < rows && y >= 0 && y < cols) {
      terrain = boardMap.cells[x][y].getTerrainName();
    }
    for(Building building : state.buildings) {
      if (building.loc.isIn(mouseX-boardMap.xo,mouseY-boardMap.yo)) {
        terrain += ", " + building.getName();
      }
    }
    String cursor = "(" + (mouseX- boardMap.xo) + ", " + (mouseY- boardMap.yo) + "), " + terrain;

    int lumberjackCount = 0;
    int farmerCount = 0;
    int minerCount = 0;

    for (Citizen c : state.citizens) {
      if (c instanceof Lumberjack) {
        lumberjackCount++;
      } else if (c instanceof Farmer) {
        farmerCount++;
      } else if (c instanceof Miner) {
        minerCount++;
      }
    }

    String resources = "Food: " + state.foodSupply + "  Lumber: " + state.lumberSupply +
      "  Ore: " + state.oreSupply + "  Population: " + (state.citizens.size() +
      state.soldiers.size()) + "  Farmers: " + farmerCount + "  Lumberjacks: " + lumberjackCount +
      "  Miners: " + minerCount + "  Soldiers: " + state.soldiers.size();

    fill(255);
    rect(-boardMap.xo,-boardMap.yo, rows*cellSize,20);
    rect(mouseX + 10- boardMap.xo, mouseY-10- boardMap.yo, cursor.length() * 8,20);
    rect(rows*cellSize-200-boardMap.xo,40-boardMap.yo,200,max(messages.size()*60, 40));
    // control panel
    for(Panel panel : panels) {
      panel.draw();
    }

    fill(0,255,255);
    rect(200-boardMap.xo, cols*cellSize-20-boardMap.yo,20,20);

    fill(0);
    text(cursor, mouseX + 10- boardMap.xo, mouseY + 2.5- boardMap.yo);
    text(resources, 20 - boardMap.xo,15 - boardMap.yo);
    String messageStr = "";
    for(Message message: messages) {
      messageStr += message.message + "\n\n";
    }

    text(messageStr, rows*cellSize-190-boardMap.xo, 40 - boardMap.yo, 200, 1000);
  }
}