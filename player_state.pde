class PlayerState {
  final int STEP_FOOD_DEPLETION = 1000;
  final int STEP_BIRTH = 2000;
  final int HOVEL_CAPACITY = 2;

  HashMap<BuildingCode, HashMap<ResourceCode, Integer>> BUILDING_COSTS = new BuildingCosts().costs;
  HashMap<BuildingCode, ArrayList<Building>> buildings;
  ArrayList<Citizen> citizens;
  ArrayList<Soldier> soldiers;

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
    citizens = new ArrayList<Citizen>();
    soldiers = new ArrayList<Soldier>();

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
    resourceSupply.put(ResourceCode.LUMBER, 36);
    resourceSupply.put(ResourceCode.METAL, 6);

    updatePopulationCapacity();
    placingBuilding = BuildingCode.NONE;
    combatMode = CombatMode.DEFENSIVE;

    int cellSize = boardMap.gridsize;
    int rows = boardMap.numRows;
    int cols = boardMap.numCols;

    citizens.add(new FreeCitizen(townCenterCell, getTownSquare(), this));
    citizens.add(new FreeCitizen(townCenterCell, getTownSquare(), this));
  }

  void step(double gameStateIndex) {
    // Iterate states of all Humans, update game stats (food levels, etc.)

    // Food depletion
    if (gameStateIndex >= foodDepletionIndex) {
      int foodEaten = citizens.size() + (soldiers.size() * 2);
      foodSupply -= foodEaten;
      foodDepletionIndex += STEP_FOOD_DEPLETION;
      this.handleStarvation();
    }


    // Births
    if (
      citizens.size() + soldiers.size() < populationCapacity &&  // population isn't at capacity
      gameStateIndex >= birthIndex &&  // enough time has elapsed for a birth
      buildings.get(BuildingCode.HOVEL).size() > 0 &&  // there is an existing hovel to spawn from
      foodSupply > 0
    ) {
      Hovel targetHovel = (Hovel) buildings.get(BuildingCode.HOVEL).get(rng.nextInt(buildings.get(BuildingCode.HOVEL).size()));
      citizens.add(new FreeCitizen(targetHovel.loc, this.getTownSquare(), this));
      birthIndex += STEP_BIRTH;
    }

    this.handleBattleDamage();

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
  void handleBattleDamage() {
    ArrayList<Cell> enemySoldierLocs = new ArrayList<Cell>();

    for (Soldier soldier : state.getSoldiers()) {
      if (!this.soldiers.contains(soldier)) {
        enemySoldierLocs.add(soldier.loc);
      }
    }

    ArrayList<Citizen> deadCitizens = new ArrayList<Citizen>();
    ArrayList<Soldier> deadSoldiers = new ArrayList<Soldier>();
    int occurrences = 0;

    for (Citizen citizen : this.citizens) {
      occurrences = Collections.frequency(enemySoldierLocs, citizen.loc);
      citizen.health -= 0.5 * occurrences;

      if (citizen.health <= 0) {
        deadCitizens.add(citizen);
      }
    }

    for (Soldier soldier : this.soldiers) {
      occurrences = Collections.frequency(enemySoldierLocs, soldier.loc);
      soldier.health -= 0.5 * occurrences;

      if (soldier.health <= 0) {
        deadSoldiers.add(soldier);
      }
    }

    for (Citizen c : deadCitizens) {
      if (c.assignedBuilding instanceof Crop) {
        Crop crop = (Crop) c.assignedBuilding;
        crop.farmer = null;
      }

      this.citizens.remove(c);
    }

    for (Soldier s : deadSoldiers) {
      this.soldiers.remove(s);
    }
  }

  /**
   *  Starves your population based on how negative your food supply is
   */
  void handleStarvation() {
    if (foodSupply < 0) {
      int mealsMissed = -foodSupply;

      int citizenCount = citizens.size();
      int soldierCount = soldiers.size();

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

  /**
   *  Starves a random citizen
   */
  void starveCitizen() {
    int whichCitizen = rng.nextInt(citizens.size());
    citizens.get(whichCitizen).starve();
  }

  /**
   *  Starves a random soldier
   */
  void starveSoldier() {
    int whichSoldier = rng.nextInt(soldiers.size());
    soldiers.get(whichSoldier).starve();
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
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.SAWMILL).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a lumberjack: Need a sawmill!", state.gameStateIndex+FRAME_RATE*5));
    } else {
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
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.FARM).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a farmer: Need a farm!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Farm targetFarm = (Farm) buildings.get(BuildingCode.FARM).get(rng.nextInt(buildings.get(BuildingCode.FARM).size()));
      citizens.add(new Farmer(freeCitizen.loc, targetFarm, this));
      citizens.remove(freeCitizen);
    }
  }

  void removeFarmer() {
    for (Citizen citizen : citizens) {
      if (citizen instanceof Farmer) {
        for (Building b : buildings.get(BuildingCode.CROP)) {
          Crop crop = (Crop) b;
          if (crop.farmer == citizen) {
            crop.farmer = null;
            break;
          }
        }

        citizens.add(new FreeCitizen(citizen.loc, getTownSquare(), this));
        citizens.remove(citizen);
        break;
      }
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
      soldiers.add(new Soldier(freeCitizen.loc, targetBarracks, this));
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
    if (freeCitizen == null) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Not enough free citizens!", state.gameStateIndex+FRAME_RATE*5));
    } else if (buildings.get(BuildingCode.FOUNDRY).size() < 1) {
      userInterface.messageQueue.add(new Message("Can't add a miner: Need a foundry!", state.gameStateIndex+FRAME_RATE*5));
    } else {
      Foundry targetFoundry = (Foundry) buildings.get(BuildingCode.FOUNDRY).get(rng.nextInt(buildings.get(BuildingCode.FOUNDRY).size()));
      citizens.add(new Miner(freeCitizen.loc, targetFoundry, this));
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

  void updatePopulationCapacity() {
    populationCapacity = HOVEL_CAPACITY * buildings.get(BuildingCode.HOVEL).size() + 2;
  }
}
