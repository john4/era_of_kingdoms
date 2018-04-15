class PlayerState {
  final int STEP_FOOD_DEPLETION = 1000;
  final int STEP_BIRTH = 2000;
  final int HOVEL_CAPACITY = 2;
  // int STEP_BIRTH = 100;  // for testing purposes

  HashMap<BuildingCode, HashMap<ResourceCode, Integer>> BUILDING_COSTS = new BuildingCosts().costs;
  HashMap<BuildingCode, ArrayList<Building>> buildings;
  HashMap<HumanCode, ArrayList<Human>> humans;

  double foodDepletionIndex;
  double birthIndex;

  int foodSupply;
  int populationCapacity;
  HashMap<ResourceCode, Integer> resourceSupply;

  BuildingCode placingBuilding;
  CombatMode combatMode;

  PlayerState(int[] rgb) {
    // Assumes map has been generated
    // Place town square, add initial Humans and supplies
    buildings = new HashMap<BuildingCode, ArrayList<Building>>();
    for (BuildingCode code : BuildingCode.values()) {
      buildings.put(code, new ArrayList<Building>());
    }

    humans = new HashMap<HumanCode, ArrayList<Human>>();
    for (HumanCode code : HumanCode.values()) {
      humans.put(code, new ArrayList<Human>());
    }

    foodDepletionIndex = STEP_FOOD_DEPLETION;
    birthIndex = 0;

    // Add town center to random grass cell
    while (true) {
      int townRow = int(random(boardMap.numRows));
      int townCol = int(random(boardMap.numCols));
      if (boardMap.cells[townRow][townCol].terraintype == 0) {
        buildings.get(BuildingCode.TOWNSQUARE).add(new TownSquare(boardMap.cells[townRow][townCol], rgb));
        break;
      }
    }

    foodSupply = 12;
    resourceSupply = new HashMap<ResourceCode, Integer>();
    resourceSupply.put(ResourceCode.LUMBER, 36);
    resourceSupply.put(ResourceCode.METAL, 6);

    updatePopulationCapacity();
    placingBuilding = BuildingCode.NONE;
    combatMode = CombatMode.DEFENSIVE;

    int cellSize = boardMap.gridsize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;
  }
// int c = 0;
  void step(double gameStateIndex) {
    // Iterate states of all Humans, update game stats (food levels, etc.)

    // Food depletion
    if (gameStateIndex >= foodDepletionIndex) {
      int foodEaten = getCitizens().size() + (humans.get(HumanCode.SOLDIER).size() * 2);
      foodSupply -= foodEaten;
      foodDepletionIndex += STEP_FOOD_DEPLETION;
    }

    // Births
    if (
      getCitizens().size() + humans.get(HumanCode.SOLDIER).size() < populationCapacity &&  // population isn't at capacity
      gameStateIndex >= birthIndex &&  // enough time has elapsed for a birth
      buildings.get(BuildingCode.HOVEL).size() > 0  // there is an existing hovel to spawn from
    ) {
      Hovel targetHovel = (Hovel) buildings.get(BuildingCode.HOVEL).get(rng.nextInt(buildings.get(BuildingCode.HOVEL).size()));
      humans.get(HumanCode.FREE).add(new FreeCitizen(targetHovel.loc, this.getTownSquare(), this));
      birthIndex += STEP_BIRTH;
      // c++;
    }

    this.handleHealth();

    gameStateIndex += 1;
  }

  void draw() {
    for (Building building : getBuildings()) {
      building.draw();
    }
    for (Human citizen : getCitizens()) {
      citizen.draw();
    }
    for (Human soldier : getSoldiers()) {
      soldier.draw();
    }
  }

  void adjustResource(ResourceCode resource, int value) {
    resourceSupply.put(resource, resourceSupply.get(resource) + value);
  }

  boolean requestPlacingBuilding(BuildingCode buildingCode) {
    HashMap<ResourceCode, Integer> cost = BUILDING_COSTS.get(buildingCode);

    for (ResourceCode c : ResourceCode.values()) {
      if (resourceSupply.get(c) < cost.get(c)) {
        userInterface.messageQueue.add(new Message("Not enough " + c.toString() + " to build a " + buildingCode.toString(), state.gameStateIndex+FRAME_RATE*5));
        return false;
      }
    }

    for (ResourceCode c : ResourceCode.values()) {
      adjustResource(c, -cost.get(c));
    }
    this.placingBuilding = buildingCode;
    return true;
  }

  void setCombatMode(CombatMode cm) {
    this.combatMode = cm;
  }

  /**
   *  If any of our people are in the same cell as an enemy soldier, take damage.
   *  If any of our people reach health 0, they die.
   */
  void handleHealth() {
    ArrayList<Cell> enemySoldierLocs = new ArrayList<Cell>();

    for (Human soldier : state.getSoldiers()) {
      if (!this.getSoldiers().contains(soldier)) {
        enemySoldierLocs.add(soldier.loc);
      }
    }

    ArrayList<Human> deadCitizens = new ArrayList<Human>();
    ArrayList<Human> deadSoldiers = new ArrayList<Human>();

    for (Human citizen : this.getCitizens()) {
      if (enemySoldierLocs.contains(citizen.loc)) {
        citizen.health -= 0.5;
      }

      if (citizen.health <= 0) {
        deadCitizens.add(citizen);
      }
    }

    for (Human soldier : this.getSoldiers()) {
      if (enemySoldierLocs.contains(soldier.loc)) {
        soldier.health -= 0.5;
      }

      if (soldier.health <= 0) {
        deadSoldiers.add(soldier);
      }
    }

    for (Human c : deadCitizens) {
      this.humans.get(c.type).remove(c);
    }

    for (Human s : deadSoldiers) {
      this.humans.get(HumanCode.SOLDIER).remove(s);
    }
  }

  void placeBuilding(Cell loc) {
    this.placeBuilding(loc, this.placingBuilding);
    this.placingBuilding = BuildingCode.NONE;
  }

  void placeBuilding(Cell loc, BuildingCode buildingType) {
    this.addBuilding(buildingType, loc);
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
        newBuilding = new TownSquare(loc, new int[] { 255, 255, 255 });
        break;
      case CROP:
        newBuilding = new Crop(loc);
        break;
      case FOUNDRY:
        newBuilding = new Foundry(loc);
        break;
      case BARRACKS:
        newBuilding = new Barracks(loc);
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

  ArrayList<Human> getCitizens() {
    ArrayList<Human> result = new ArrayList<Human>();
    for (HumanCode code : HumanCode.values()) {
      if (code != HumanCode.SOLDIER) {
        result.addAll(humans.get(code));
      }
    }
    return result;
  }

  ArrayList<Human> getSoldiers() {
    return humans.get(HumanCode.SOLDIER);
  }

  // Get the first unoccupied citizen, else null
  Citizen getFreeCitizen() {
    if (humans.get(HumanCode.FREE).size() > 0) {
      return (Citizen) humans.get(HumanCode.FREE).get(0);
    }
    return null;
  }

  void addLumberjack() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.SAWMILL).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Need a sawmill!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Sawmill targetSawmill = (Sawmill) buildings.get(BuildingCode.SAWMILL).get(rng.nextInt(buildings.get(BuildingCode.SAWMILL).size()));
      humans.get(HumanCode.LUMBERJACK).add(new Lumberjack(freeCitizen.loc, targetSawmill, this));
      humans.get(HumanCode.FREE).remove(freeCitizen);
    }
  }

  void removeLumberjack() {
    if (humans.get(HumanCode.LUMBERJACK).size() > 0) {
      Human lumberJackToRemove = humans.get(HumanCode.LUMBERJACK).remove(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(lumberJackToRemove.loc, getTownSquare(), this));
    }
  }

  void addFarmer() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.FARM).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Need a farm!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Farm targetFarm = (Farm) buildings.get(BuildingCode.FARM).get(rng.nextInt(buildings.get(BuildingCode.FARM).size()));
      humans.get(HumanCode.FARMER).add(new Farmer(freeCitizen.loc, targetFarm, this));
      humans.get(HumanCode.FREE).remove(freeCitizen);
    }
  }

  void removeFarmer() {
    if (humans.get(HumanCode.FARMER).size() > 0) {
      Human farmerToRemove = humans.get(HumanCode.FARMER).remove(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(farmerToRemove.loc, getTownSquare(), this));
    }
  }

  void addSoldier() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a soldier: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.BARRACKS).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a soldier: Need a barracks!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Barracks targetBarracks = (Barracks) buildings.get(BuildingCode.BARRACKS).get(rng.nextInt(buildings.get(BuildingCode.BARRACKS).size()));
      humans.get(HumanCode.SOLDIER).add(new Soldier(freeCitizen.loc, targetBarracks, this));
      humans.get(HumanCode.FREE).remove(freeCitizen);
    }
  }

  void removeSoldier() {
    Human soldierToRemove = humans.get(HumanCode.SOLDIER).remove(0);
    humans.get(HumanCode.FREE).add(new FreeCitizen(soldierToRemove.loc, getTownSquare(), this));
  }

  void addMiner() {
    Citizen freeCitizen = getFreeCitizen();
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.FOUNDRY).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Need a foundry!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Foundry targetFoundry = (Foundry) buildings.get(BuildingCode.FOUNDRY).get(rng.nextInt(buildings.get(BuildingCode.FOUNDRY).size()));
      humans.get(HumanCode.MINER).add(new Miner(freeCitizen.loc, targetFoundry, this));
      humans.get(HumanCode.FREE).remove(freeCitizen);
    }
  }

  void removeMiner() {
    if (humans.get(HumanCode.MINER).size() > 0) {
      Human minerToRemove = humans.get(HumanCode.MINER).remove(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(minerToRemove.loc, getTownSquare(), this));
    }
  }

  void updatePopulationCapacity() {
    populationCapacity = HOVEL_CAPACITY * buildings.get(BuildingCode.HOVEL).size();
  }
}
