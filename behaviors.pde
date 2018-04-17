final int GATHER_SPEED = 1;  // how many seconds to gather 1 unit

class Move extends Task {

  Move(Blackboard bb) {
    this.blackboard = bb;
  }

  int execute() {
    Human h = (Human) this.blackboard.get("Human");
    Cell target = (Cell) this.blackboard.get("Target");
    PotentialPathNode node = (PotentialPathNode) this.blackboard.get("Path");

    if (target == null) { // can't do anything without a target.
      return FAIL;
    }

    if (h.collisions >= MAX_COLLISIONS) { // run A* on max collision count
      h.collisions = 0; // reset collision counter
      node = boardMap.findPath(target, h.loc);
    }

    // close enough to let moveTo take over
    double dist = CELL_SIZE * Math.sqrt(2) + .1;
    if (node == null || target.euclideanDistanceTo(h.loc) < dist) {
      this.blackboard.put("Path", null); // pathfinding is done
      h.moveTo(target.pos.x, target.pos.y, true);
    } else {
      followPath(node, h); // node traverse to find path
    }

    return FAIL;
  }

  void followPath(PotentialPathNode node, Human h) {
    // should never be null, store current node for next frame.
    this.blackboard.put("Path", node);
    // if reached node but node still has parent, recall to update node and move to new cell.
    if (node.cell.i == h.loc.i && node.cell.j == h.loc.j && node.parent != null) {
      followPath(node.parent, h);
    } else {
      // if(node != null) {
      //   node.draw();
      // }
      h.vel = new PVector(0,0);
      h.vel.setMag(.1);
      h.moveTo(node.cell.pos.x, node.cell.pos.y, true);
    }
  }
}

class Wander extends Task {
  Wander(Blackboard bb, int radius) {
    this.blackboard = bb;
    this.blackboard.put("Radius", radius);
    this.blackboard.put("HomeCircle", new ArrayList<Cell>());
    this.blackboard.put("Waiting", 0);

    Human h = (Human) this.blackboard.get("Human");
    Building assignedBuilding = h.assignedBuilding;
    this.blackboard.put("Target", assignedBuilding.loc);
    midpointCircle((int) assignedBuilding.pos.x, (int) assignedBuilding.pos.y, radius);
  }

  /** Select a random cell on the map within the home circle */
  Cell pickNewDestination() {
    ArrayList<Cell> possibleCells = (ArrayList<Cell>) this.blackboard.get("HomeCircle");
    float r = random(possibleCells.size() - 1);
    return possibleCells.get((int) r);
  }

  void midpointHandleCell(int x, int y) {
    try {
      Cell c = boardMap.cellAtPos(new PVector(x, y));
      ArrayList<Cell> cells = (ArrayList<Cell>) this.blackboard.get("HomeCircle");
      if (!cells.contains(c) && c.terraintype != 3 && c.terraintype != 6) {  // TODO: don't select building cells
        cells.add(c);
      }
    } catch (NullPointerException err) {
      System.out.println("Bad cell");
    }
  }

  /** https://en.wikipedia.org/wiki/Midpoint_circle_algorithm */
  void midpointCircle(int x0, int y0, int radius) {
    int x = radius - 1;
    int y = 0;
    int dx = 1;
    int dy = 1;
    int err = dx - (radius << 1);

    while (x >= y)
    {
        midpointHandleCell(x0 + x, y0 + y);
        midpointHandleCell(x0 + y, y0 + x);
        midpointHandleCell(x0 - y, y0 + x);
        midpointHandleCell(x0 - x, y0 + y);
        midpointHandleCell(x0 - x, y0 - y);
        midpointHandleCell(x0 - y, y0 - x);
        midpointHandleCell(x0 + y, y0 - x);
        midpointHandleCell(x0 + x, y0 - y);

        if (err <= 0)
        {
            y++;
            err += dy;
            dy += 2;
        }

        if (err > 0)
        {
            x--;
            dx += 2;
            err += dx - (radius << 1);
        }
    }
  }

  int execute() {
    Human h = (Human) this.blackboard.get("Human");
    Cell target = (Cell) this.blackboard.get("Target");
    int wait = (int) this.blackboard.get("Waiting");

    if (wait > 0) {
      this.blackboard.put("Waiting", wait - 1);
      return FAIL;
    } else {
      // Check to see if we've arrived at our target cell
      PVector direction = PVector.sub(target.pos, h.pos);
      float distance = direction.mag();

      // If we have, wait then pick a new target
      if (distance < h.TARGET_RADIUS) {
        target = pickNewDestination();
        this.blackboard.put("Target", target);
        this.blackboard.put("Waiting", 50);
      }
    }

    return SUCCESS;
  }
}

class Plant extends Task {
  Plant(Blackboard bb) {
    this.blackboard = bb;
    this.blackboard.put("Crop", null);
    this.blackboard.put("Target", null);
  }

  int execute() {
    Crop crop = (Crop) this.blackboard.get("Crop");
    Farmer f = (Farmer) this.blackboard.get("Human");

    // If we have somewhere to farm from, don't plant any more crops
    if (crop != null) {
      f.crop = crop;
      this.blackboard.put("Human", f);
      return SUCCESS;
    }

    // Check if there are any unmanned crops, choose those and reassign farm if necessary
    boolean pickedExistingCrop = false;
    ArrayList<Building> crops = f.ownerState.buildings.get(BuildingCode.CROP);
    for (Building b : crops) {
      if (((Crop) b).farmer == null) {
        f.crop = (Crop) b;
        ((Crop) b).farmer = f;
        pickedExistingCrop = true;
        this.blackboard.put("Crop", f.crop);
        break;
      }
    }

    if (pickedExistingCrop) {
      ArrayList<Building> farms = f.ownerState.buildings.get(BuildingCode.FARM);
      float dist = 999999;
      float newDist = 999999;

      for (Building b : farms) {
        newDist = b.loc.euclideanDistanceTo(f.crop.loc);

        if (newDist < dist) {
          dist = newDist;
          f.assignedBuilding = b;
        }
      }
      return SUCCESS;
    }

    // Move to the nearest grass cell to our farm
    Cell target = (Cell) this.blackboard.get("Target");
    if (target == null) {
      target = f.assignedBuilding.loc.findClosestOfType(0);
      this.blackboard.put("Target", target);
      return FAIL;
    }

    if (!target.isIn(f.pos.x, f.pos.y)) {
      this.blackboard.put("Target", target);
    } else {    // Plant some freaking crops
      if (!boardMap.validBuildingSpot(target)) {
        this.blackboard.put("Target", null);
        return FAIL;
      }

      Crop newCrop = (Crop) f.ownerState.addBuilding(BuildingCode.CROP, target);
      newCrop.farmer = f;
      f.crop = newCrop;
      this.blackboard.put("Crop", newCrop);
      this.blackboard.put("Human", f);
    }

    return FAIL;
  }
}

class Harvest extends Task {
  Harvest(Blackboard bb) {
    this.blackboard = bb;
    this.blackboard.put("LastGather", -1);
  }

  int execute() {
    Farmer f = (Farmer) this.blackboard.get("Human");

    int carrying = f.carryWeight;
    if (carrying >= f.CARRY_CAPACITY) {
      return SUCCESS;
    }

    if (f.loc == f.crop.loc) {
      int lastGather = (int) this.blackboard.get("LastGather");

      if (millis() - lastGather >= GATHER_SPEED * 1000) {
        f.setCarryWeight(carrying + 1);
        this.blackboard.put("LastGather", millis());
      }
    } else {
      this.blackboard.put("Target", boardMap.cellAtPos(f.crop.pos));
    }

    return FAIL;
  }
}

class Process extends Task {
  Process(Blackboard bb) {
    this.blackboard = bb;
    this.blackboard.put("ProcessingTimeSpent", 0);
    this.blackboard.put("ProcessingLastTick", millis());
  }

  int execute() {
    Citizen c = (Citizen) this.blackboard.get("Human");
    Cell target = c.assignedBuilding.loc;
    int timeSpent = (int) this.blackboard.get("ProcessingTimeSpent");
    int lastTick = (int) this.blackboard.get("ProcessingLastTick");

    if (timeSpent > 10 || c.blackboard.get("Stage") == "DropOff") {
      this.blackboard.put("ProcessingTimeSpent", 0);
      c.blackboard.put("Stage", "DropOff");
      return SUCCESS;
    }

    // Check to see if we've arrived at home cell
    PVector direction = PVector.sub(target.pos, c.pos);
    float distance = direction.mag();

    // If we're there, wait until we've finished processing our stuff
    if (distance < c.TARGET_RADIUS) {
      if (millis() - lastTick >= GATHER_SPEED * 1000) {
        this.blackboard.put("ProcessingLastTick", millis());
        this.blackboard.put("ProcessingTimeSpent", timeSpent + 1);
        return FAIL;
      }
    }

    this.blackboard.put("Target", target);
    return FAIL;
  }
}

class Gather extends Task {
  Gather(Blackboard bb, int terrain) {
    this.blackboard = bb;
    this.blackboard.put("Terrain", terrain);  // type of terrain we want to gather from
    this.blackboard.put("LastGather", -1);    // time of last carrying increase
    this.blackboard.put("Target", null);
  }

  int execute() {
    Citizen c = (Citizen) this.blackboard.get("Human");

    // Check if we're all full of stuff. If yes, ready to go home
    int carrying = c.carryWeight;
    if (carrying >= c.CARRY_CAPACITY) {
      this.blackboard.put("Target", null);
      return SUCCESS;
    }

    int terrain = (int) this.blackboard.get("Terrain");
    int lastGather = (int) this.blackboard.get("LastGather");

    // If not at correct terrain, find nearest cell with correct terrain type and go there
    if (c.loc.terraintype != terrain) {
      Cell target = (Cell) this.blackboard.get("Target");

      if (target == null) {
        target = c.loc.findClosestOfType(terrain);
      }

      this.blackboard.put("Target", target);
    } else {   // Gather slowly
      if (millis() - lastGather >= GATHER_SPEED * 1000) {
        c.setCarryWeight(carrying + 1);
        this.blackboard.put("LastGather", millis());
      }
    }

    return FAIL;
  }
}

class DropOff extends Task {
  DropOff(Blackboard bb, String resource) {
    this.blackboard = bb;
    this.blackboard.put("Resource", resource);
    this.blackboard.put("Target", null);
  }

  int execute() {
    Citizen c = (Citizen) this.blackboard.get("Human");
    String resource = (String) this.blackboard.get("Resource");
    Cell target = (Cell) this.blackboard.get("Target");

    if (target == null) {
      // We want to go to the correct / nearest stockpile
      ArrayList<Building> stockpiles = c.ownerState.buildings.get(BuildingCode.STOCKPILE);
      float dist = 999999;
      float newDist = 999999;

      for (Building b : stockpiles) {
        newDist = b.loc.euclideanDistanceTo(c.loc);

        if (newDist < dist) {
          dist = newDist;
          target = b.loc;
        }
      }
    }

    if (target == null) {
      return FAIL;
    }

    // Check to see if we've arrived at home cell
    PVector direction = PVector.sub(target.pos, c.pos);
    float distance = direction.mag();

    if (distance < c.TARGET_RADIUS) {
      // Once we're there, drop off our stuff
      switch (resource) {
        case "Lumber":
          c.ownerState.adjustResource(ResourceCode.LUMBER, c.carryWeight);
          break;
        case "Food":
          c.ownerState.foodSupply += c.carryWeight;
          break;
        case "Metal":
          c.ownerState.adjustResource(ResourceCode.METAL, c.carryWeight);
          break;
      }

      c.setCarryWeight(0);
      c.blackboard.put("Stage", "Gather");
      this.blackboard.put("Target", null);
      return SUCCESS;
    }

    // If not, keep movin
    this.blackboard.put("Target", target);
    return FAIL;
  }
}

class TargetEnemy extends Task {
  TargetEnemy(Blackboard bb, int radius) {
    this.blackboard = bb;
    this.blackboard.put("Radius", radius);
  }

  int execute() {
    Soldier s = (Soldier) this.blackboard.get("Human");
    int r = (int) this.blackboard.get("Radius");

    // Already have a live target?
    Human mark = (Human) s.blackboard.get("Mark");
    if (mark != null && mark.health > 0) {
      if (state.humanPlayer.combatMode == CombatMode.DEFENSIVE && s.assignedBuilding.loc.euclideanDistanceTo(mark.loc) > r) {
        s.blackboard.put("Mark", null);
      }

      return SUCCESS;
    }

    mark = null;

    // Picking an enemy prioritizes soldiers over citizens, closest first
    ArrayList<Human> enemySoldiers = state.computerPlayer.getSoldiers();
    ArrayList<Human> enemyCitizens = state.computerPlayer.getCitizens();

    float shortestDistance = 99999;

    if (enemySoldiers.size() > 0) {
      mark = enemySoldiers.get(0);
      shortestDistance = s.loc.euclideanDistanceTo(mark.loc);

      for (Human enemySoldier : enemySoldiers) {
        if (s.assignedBuilding.loc.euclideanDistanceTo(enemySoldier.loc) < shortestDistance) {
          mark = enemySoldier;
        }
      }
    }

    if (state.humanPlayer.combatMode == CombatMode.DEFENSIVE && shortestDistance > r) {
      mark = null;
    }

    if (mark == null && enemyCitizens.size() > 0) {
      mark = enemyCitizens.get(0);
      shortestDistance = s.loc.euclideanDistanceTo(mark.loc);

      for (Human enemyCitizen : enemyCitizens) {
        if (s.assignedBuilding.loc.euclideanDistanceTo(enemyCitizen.loc) < shortestDistance) {
          mark = enemyCitizen;
        }
      }
    }

    if (state.humanPlayer.combatMode == CombatMode.DEFENSIVE && shortestDistance > r) {
      mark = null;
    }

    s.blackboard.put("Mark", mark);

    return mark == null ? FAIL : SUCCESS;
  }
}

// TODO: soldiers should probably give up at some point
class AttackEnemy extends Task {
  AttackEnemy(Blackboard bb) {
    this.blackboard = bb;
  }

  int execute() {
    Soldier s = (Soldier) this.blackboard.get("Human");
    Human mark = (Human) s.blackboard.get("Mark");

    if (mark == null) {
      return FAIL;
    }

    this.blackboard.put("Target", boardMap.cellAtPos(mark.pos));
    return SUCCESS;
  }
}
