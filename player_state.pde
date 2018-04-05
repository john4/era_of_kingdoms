class PlayerState {
  int STEP_FOOD_DEPLETION = 1000;
  int STEP_BIRTH = 2000;
  int HOVEL_CAPACITY = 3;
  // int STEP_BIRTH = 100;  // for testing purposes

  HashMap<BuildingCode, ArrayList<Building>> buildings;
  ArrayList<Citizen> citizens;
  ArrayList<Soldier> soldiers;

  double foodDepletionIndex;
  double birthIndex;

  int foodSupply;
  int lumberSupply;
  int populationCapacity;
  int oreSupply;

  BuildingCode placingBuilding;

  PlayerState() {
    // Assumes map has been generated
    // Place town square, add initial Humans and supplies
    buildings = new HashMap<BuildingCode, ArrayList<Building>>();
    for (BuildingCode code : BuildingCode.values()) {
      buildings.put(code, new ArrayList<Building>());
    }
    citizens = new ArrayList<Citizen>();
    soldiers = new ArrayList<Soldier>();

    foodDepletionIndex = STEP_FOOD_DEPLETION;
    birthIndex = 0;

    // Add town center to random grass cell
    while (true) {
      int townRow = int(random(boardMap.numRows));
      int townCol = int(random(boardMap.numCols));
      if (boardMap.cells[townRow][townCol].terraintype == 0) {
        buildings.get(BuildingCode.TOWNSQUARE).add(new TownSquare(boardMap.cells[townRow][townCol]));
        // buildings.add(new Farm(boardMap.cells[townRow - 2][townCol - 2]));
        break;
      }
    }

    foodSupply = 12;
    lumberSupply = 12;
    updatePopulationCapacity();
    placingBuilding = BuildingCode.NONE;

    int cellSize = boardMap.gridsize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;
  }
// int c = 0;
  void step(double gameStateIndex) {
    // Iterate states of all Humans, update game stats (food levels, etc.)

    // Food depletion
    if (gameStateIndex >= foodDepletionIndex) {
      int foodEaten = citizens.size() + (soldiers.size() * 2);
      foodSupply -= foodEaten;
      foodDepletionIndex += STEP_FOOD_DEPLETION;
    }

    // Births
    if (
      citizens.size() + soldiers.size() < populationCapacity &&  // population isn't at capacity
      gameStateIndex >= birthIndex &&  // enough time has elapsed for a birth
      buildings.get(BuildingCode.HOVEL).size() > 0  // there is an existing hovel to spawn from
    ) {
      Hovel targetHovel = (Hovel) buildings.get(BuildingCode.HOVEL).get(rng.nextInt(buildings.get(BuildingCode.HOVEL).size()));
      citizens.add(new FreeCitizen(targetHovel.loc, this.getTownSquare(), this));
      birthIndex += STEP_BIRTH;
      // c++;
    }

    gameStateIndex += 1;
  }

  void draw() {
    for (Building building : getBuildings()) {
      building.draw();
    }
    for (Citizen citizen : citizens) {
      citizen.draw();
    }
    for (Soldier soldier : soldiers) {
      soldier.draw();
    }
  }

  void placeBuilding(Cell loc) {
    this.addBuilding(this.placingBuilding, loc);
    this.placingBuilding = BuildingCode.NONE;
  }

  Building addBuilding(BuildingCode b, Cell loc) {
    Building newBuilding;

    switch (b) {
      case FARM:
        newBuilding = new Farm(loc);
        break;
      case HOVEL:
        newBuilding = new Hovel(loc);
        break;
      case SAWMILL:
        newBuilding = new Sawmill(loc);
        break;
      case STOCKPILE:
        newBuilding = new Stockpile(loc);
        break;
      case TOWNSQUARE:
        newBuilding = new TownSquare(loc);
        break;
      case CROP:
        newBuilding = new Crop(loc);
        break;
      default:
        return null;
    }

    this.buildings.get(b).add(newBuilding);
    updatePopulationCapacity();

    return newBuilding;
  }

  ArrayList<Building> getBuildings() {
    ArrayList<Building> result = new ArrayList<Building>();
    for (BuildingCode code : BuildingCode.values()) {
      result.addAll(buildings.get(code));
    }
    return result;
  }

  Building getTownSquare() {
    return buildings.get(BuildingCode.TOWNSQUARE).get(0);
  }

  // Get the first unoccupied citizen, else null
  Citizen getFreeCitizen() {
    for (Citizen citizen : citizens) {
      if (citizen.isFree()) {
        return citizen;
      }
    }
    return null;
  }

  void addLumberjack() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen != null && buildings.get(BuildingCode.SAWMILL).size() > 0) {
      Sawmill targetSawmill = (Sawmill) buildings.get(BuildingCode.SAWMILL).get(rng.nextInt(buildings.get(BuildingCode.SAWMILL).size()));
      citizens.add(new Lumberjack(freeCitizen.loc, targetSawmill, this));
      citizens.remove(freeCitizen);
    }
  }

  void removeLumberjack() {
    for (Citizen citizen : citizens) {
      if (citizen instanceof Lumberjack) {
        citizens.add(new FreeCitizen(citizen.loc, getTownSquare(), this));
        citizens.remove(citizen);
        break;
      }
    }
  }

  void addFarmer() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen != null && buildings.get(BuildingCode.FARM).size() > 0) {
      Farm targetFarm = (Farm) buildings.get(BuildingCode.FARM).get(rng.nextInt(buildings.get(BuildingCode.FARM).size()));
      citizens.add(new Farmer(freeCitizen.loc, targetFarm, this));
      citizens.remove(freeCitizen);
    }
  }

  void removeFarmer() {
    for (Citizen citizen : citizens) {
      if (citizen instanceof Farmer) {
        citizens.add(new FreeCitizen(citizen.loc, getTownSquare(), this));
        citizens.remove(citizen);
        break;
      }
    }
  }

  void addSoldier() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen != null) {
      soldiers.add(new Soldier(freeCitizen.loc, getTownSquare(), this));
      citizens.remove(freeCitizen);
    }
  }

  void removeSoldier() {
    Soldier s = soldiers.get(0);
    citizens.add(new FreeCitizen(s.loc, getTownSquare(), this));
    soldiers.remove(s);
  }

  void addMiner() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen != null) {
      citizens.add(new Miner(freeCitizen.loc, getTownSquare(), this));
      citizens.remove(freeCitizen);
    }
  }

  void removeMiner() {
    for (Citizen citizen : citizens) {
      if (citizen instanceof Miner) {
        citizens.add(new FreeCitizen(citizen.loc, getTownSquare(), this));
        citizens.remove(citizen);
        break;
      }
    }
  }
<<<<<<< HEAD
=======

  void updatePopulationCapacity() {
    populationCapacity = HOVEL_CAPACITY * buildings.get(BuildingCode.HOVEL).size() + 2;
  }
>>>>>>> master
}
