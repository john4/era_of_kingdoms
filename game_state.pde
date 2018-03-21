class GameState {
  ArrayList<Building> buildings;
  ArrayList<Citizen> citizens;
  ArrayList<Soldier> soldiers;
  ArrayList<Message> messages;
  ArrayList<Panel> panels;

  int foodSupply;
  int lumberSupply;

  GameState() {
    // Assumes map has been generated
    // Place town square, add initial Humans and supplies
    buildings = new ArrayList<Building>();
    citizens = new ArrayList<Citizen>();
    soldiers = new ArrayList<Soldier>();
    messages = new ArrayList<Message>();
    panels = new ArrayList<Panel>();

    // Add town center to random grass cell
    while (true) {
      int townRow = int(random(map.numRows));
      int townCol = int(random(map.numCols));
      if (map.cells[townRow][townCol].terraintype == 0) {
        buildings.add(new TownSquare(map.cells[townRow][townCol]));
        break;
      }
    }

    foodSupply = 12;
    lumberSupply = 12;

    messages.add(new Message("Welcome to <insert name here>", 20));
    messages.add(new Message("Need additional Pylons", 20));

    int cellSize = map.gridsize;
    int rows = map.numRows;
    int cols = map.numCols;

    ArrayList<ITarget> targets = new ArrayList<ITarget>();
    targets.add(new FoodTarget());
    targets.add(new LumberTarget());
    targets.add(new PopulationTarget());
    targets.add(new SoldierTarget());

    panels.add(new Panel(200-map.xo, cols*cellSize-200-map.yo,rows*cellSize-400, targets));
  }

  void step() {
    // Iterate states of all Humans, update game stats (food levels, etc.)
  }

  void draw() {
    for (Building building : buildings) {
      building.draw();
    }
    for (Citizen citizen : citizens) {
      citizen.draw();
    }
    for (Soldier soldier : soldiers) {
      soldier.draw();
    }
    drawInterfaces();
  }

  void drawInterfaces() {
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
    // control panel
    for(Panel panel : state.panels) {
      panel.draw();
    }

    fill(0,255,255);
    rect(200-map.xo, cols*cellSize-20-map.yo,20,20);



    fill(0);
    text(cursor, mouseX + 10- map.xo, mouseY + 2.5- map.yo);
    text(resources, 20 - map.xo,15 - map.yo);
    String messages = "";
    for(Message message: state.messages) {
      messages += message.message + "\n\n";
    }

    text(messages, rows*cellSize-190-map.xo, 40 - map.yo, 200, 1000);
  }
}
