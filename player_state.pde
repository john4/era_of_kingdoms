class PlayerState {
  final int STEP_FOOD_DEPLETION = 1000;
  final int STEP_BIRTH = 2000;
  final int HOVEL_CAPACITY = 2;

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

  PlayerState(int[] rgb, boolean humanLeft) {
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
    Cell townCenterCell = null;

    while (true) {
      int townRow = int(random(5, 20));
      int townCol = int(random(5, boardMap.numCols - 5));
      if (humanLeft) {
        townRow = int(random(boardMap.numRows - 20, boardMap.numRows - 5));
      }
      if (boardMap.cells[townRow][townCol].terraintype == 0) {
        buildings.get(BuildingCode.TOWNSQUARE).add(new TownSquare(boardMap.cells[townRow][townCol], rgb));
        townCenterCell = boardMap.cells[townRow][townCol];
        break;
      }
    }

    foodSupply = 12;
    resourceSupply = new HashMap<ResourceCode, Integer>();
    resourceSupply.put(ResourceCode.LUMBER, 64);
    resourceSupply.put(ResourceCode.METAL, 12);

    updatePopulationCapacity();
    placingBuilding = BuildingCode.NONE;
    combatMode = CombatMode.DEFENSIVE;

    int cellSize = boardMap.gridsize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;

    humans.get(HumanCode.FREE).add(new FreeCitizen(townCenterCell, getTownSquare(), this));
    humans.get(HumanCode.FREE).add(new FreeCitizen(townCenterCell, getTownSquare(), this));
  }

  void step(double gameStateIndex) {
    // Iterate states of all Humans, update game stats (food levels, etc.)

    // Food depletion
    if (gameStateIndex >= foodDepletionIndex) {
      int foodEaten = getCitizens().size() + (humans.get(HumanCode.SOLDIER).size() * 2);
      foodSupply -= foodEaten;
      foodDepletionIndex += STEP_FOOD_DEPLETION;
      this.handleStarvation();
    }

    // Births
    if (
      getCitizens().size() + humans.get(HumanCode.SOLDIER).size() < populationCapacity &&  // population isn't at capacity
      gameStateIndex >= birthIndex &&  // enough time has elapsed for a birth
      buildings.get(BuildingCode.HOVEL).size() > 0 &&  // there is an existing hovel to spawn from
      foodSupply > 0
    ) {
      Hovel targetHovel = (Hovel) buildings.get(BuildingCode.HOVEL).get(rng.nextInt(buildings.get(BuildingCode.HOVEL).size()));
      humans.get(HumanCode.FREE).add(new FreeCitizen(targetHovel.loc, this.getTownSquare(), this));
      birthIndex += STEP_BIRTH;
    }

    this.handleBattleDamage();

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
  void handleBattleDamage() {
    ArrayList<Cell> enemySoldierLocs = new ArrayList<Cell>();

    for (Human soldier : state.getSoldiers()) {
      if (!this.getSoldiers().contains(soldier)) {
        enemySoldierLocs.add(soldier.loc);
      }
    }

    ArrayList<Human> deadHumans = new ArrayList<Human>();
    int occurrences = 0;

    for (Human h : this.getAllHumans()) {
      occurrences = Collections.frequency(enemySoldierLocs, h.loc);
      h.health -= 0.5 * occurrences;

      if (h.health <= 0) {
        deadHumans.add(h);
      }
    }

    for (Human h : deadHumans) {
      this.removeHuman(h);
    }
  }

  /**
   *  Starves your population based on how negative your food supply is
   */
  void handleStarvation() {
    if (foodSupply < 0) {
      int mealsMissed = -foodSupply;

      int citizenCount = getCitizens().size();
      int soldierCount = getSoldiers().size();

      while (mealsMissed > 0) {
        if (citizenCount < 1) {
          this.starveSoldier();
          mealsMissed -= 2;
          continue;
        }

        if (soldierCount < 1 || mealsMissed < 2) {
          this.starveCitizen();
          mealsMissed -= 1;
          continue;
        }

        float citizenOrSoldier = rng.nextFloat();
        if (citizenOrSoldier > 0.5) {
          this.starveCitizen();
          mealsMissed -= 1;
        } else {
          this.starveSoldier();
          mealsMissed -= 2;
        }
      }
    }
  }

  void removeHuman(Human h) {
    if (h.assignedBuilding instanceof Farm) {
      Crop cropToRemove = null;
      for (Building b : buildings.get(BuildingCode.CROP)) {
        Crop crop = (Crop) b;
        if (crop.farmer == h) {
          cropToRemove = crop;
          break;
        }
      }
      if (cropToRemove != null) {
        buildings.get(BuildingCode.CROP).remove(cropToRemove);
      }
    }

    h.unassignFromBuilding();
    this.humans.get(h.type).remove(h);
  }

  /**
   *  Starves a random citizen
   */
  void starveCitizen() {
    int whichCitizen = rng.nextInt(getCitizens().size());
    getCitizens().get(whichCitizen).starve();
  }

  /**
   *  Starves a random soldier
   */
  void starveSoldier() {
    int whichSoldier = rng.nextInt(getSoldiers().size());
    getSoldiers().get(whichSoldier).starve();
  }

  void placeBuilding(Cell loc) {
    this.placeBuilding(loc, this.placingBuilding);
    this.placingBuilding = BuildingCode.NONE;
  }

  void placeBuilding(Cell loc, BuildingCode buildingType) {
    HashMap<ResourceCode, Integer> cost = BUILDING_COSTS.get(buildingType);

    for (ResourceCode c : ResourceCode.values()) {
      adjustResource(c, -cost.get(c));
    }

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

  ArrayList<Human> getAllHumans() {
    ArrayList<Human> result = new ArrayList<Human>();
    for (HumanCode code : HumanCode.values()) {
      result.addAll(humans.get(code));
    }
    return result;
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

  Building getLeastAssigned(BuildingCode type) {
    if (buildings.get(type).size() == 0) {
      return null;
    }
    Collections.sort(buildings.get(type));
    return buildings.get(type).get(0);
  }

  void addLumberjack() {
    Citizen freeCitizen = getFreeCitizen();
    Building targetSawmill = getLeastAssigned(BuildingCode.SAWMILL);

    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetSawmill == null) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Need a sawmill!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetSawmill.numFreeAssignments() == 0) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: No free sawmills!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      humans.get(HumanCode.LUMBERJACK).add(new Lumberjack(freeCitizen.loc, targetSawmill, this));
      this.removeHuman(freeCitizen);
    }
  }

  void removeLumberjack() {
    if (humans.get(HumanCode.LUMBERJACK).size() > 0) {
      Human lumberJackToRemove = humans.get(HumanCode.LUMBERJACK).get(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(lumberJackToRemove.loc, getTownSquare(), this));
      this.removeHuman(lumberJackToRemove);
    }
  }

  void addFarmer() {
    Citizen freeCitizen = getFreeCitizen();
    Building targetFarm = getLeastAssigned(BuildingCode.FARM);

    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetFarm == null) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Need a farm!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetFarm.numFreeAssignments() == 0) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: No free farms!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      humans.get(HumanCode.FARMER).add(new Farmer(freeCitizen.loc, targetFarm, this));
      this.removeHuman(freeCitizen);
    }
  }

  void removeFarmer() {
    if (humans.get(HumanCode.FARMER).size() > 0) {
      Human farmerToRemove = humans.get(HumanCode.FARMER).get(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(farmerToRemove.loc, getTownSquare(), this));
      this.removeHuman(farmerToRemove);
    }
  }

  void addSoldier() {
    Citizen freeCitizen = getFreeCitizen();
    Building targetBarracks = getLeastAssigned(BuildingCode.BARRACKS);

    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a soldier: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetBarracks == null) {
      userInterface.messageQueue.add(new Message("Can't add a soldier: Need a barracks!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetBarracks.numFreeAssignments() == 0) {
      userInterface.messageQueue.add(new Message("Can't add a soldier: No free barracks!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      humans.get(HumanCode.SOLDIER).add(new Soldier(freeCitizen.loc, targetBarracks, this));
      this.removeHuman(freeCitizen);
    }
  }

  void removeSoldier() {
    Human soldierToRemove = humans.get(HumanCode.SOLDIER).get(0);
    humans.get(HumanCode.FREE).add(new FreeCitizen(soldierToRemove.loc, getTownSquare(), this));
    this.removeHuman(soldierToRemove);
  }

  void addMiner() {
    Citizen freeCitizen = getFreeCitizen();
    Building targetFoundry = getLeastAssigned(BuildingCode.FOUNDRY);

    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetFoundry == null) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Need a foundry!", state.gameStateIndex+FRAME_RATE*5));
    } else if (targetFoundry.numFreeAssignments() == 0) {
      userInterface.messageQueue.add(new Message("Can't add a miner: No free foundries!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      humans.get(HumanCode.MINER).add(new Miner(freeCitizen.loc, targetFoundry, this));
      this.removeHuman(freeCitizen);
    }
  }

  void removeMiner() {
    if (humans.get(HumanCode.MINER).size() > 0) {
      Human minerToRemove = humans.get(HumanCode.MINER).get(0);
      humans.get(HumanCode.FREE).add(new FreeCitizen(minerToRemove.loc, getTownSquare(), this));
      this.removeHuman(minerToRemove);
    }
  }

  void updatePopulationCapacity() {
    populationCapacity = HOVEL_CAPACITY * buildings.get(BuildingCode.HOVEL).size() + 2;
  }
}
