class GameState {
  ArrayList<Building> buildings;
  ArrayList<Citizen> citizens;
  ArrayList<Soldier> soldiers;

  int foodSupply;
  int lumberSupply;

  GameState() {
    // Assumes map has been generated
    // Place town square, add initial Humans and supplies
    buildings = new ArrayList<Building>();
    citizens = new ArrayList<Citizen>();
    soldiers = new ArrayList<Soldier>();

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
  }
}
