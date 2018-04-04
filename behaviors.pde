final int GATHER_SPEED = 1;  // how many seconds to gather 1 unit

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
    System.out.println("Possible cell coords:");
    ArrayList<Cell> possibleCells = (ArrayList<Cell>) this.blackboard.get("HomeCircle");
    for (Cell c : possibleCells) {
      System.out.println(c.pos.x + ", " + c.pos.y);
    }
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


      h.moveTo(target.pos.x, target.pos.y);
    }

    // TODO: A*
    // PotentialPathNode path = boardMap.findPath(h.loc, target);
    // path.draw();
    // Cell target = boardMap.findPath(h.

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
      return SUCCESS;
    }

    // Move to the nearest grass cell to our farm
    Cell target = (Cell) this.blackboard.get("Target");
    if (target == null) {
      target = f.assignedBuilding.loc.findClosestOfType(0);
      this.blackboard.put("Target", target);
    }

    // TODO: look for crops that have lost their farmer and take those

    if (!target.isIn(f.pos.x, f.pos.y)) {
      f.moveTo(target.pos.x, target.pos.y);
    } else {    // Plant some freaking crops
      Crop newCrop = new Crop(target);
      newCrop.farmer = f;
      f.crop = newCrop;
      f.ownerState.buildings.add(newCrop);
      this.blackboard.put("Crop", newCrop);
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
      f.moveTo(f.crop.pos.x, f.crop.pos.y);
    }

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

      c.moveTo(target.pos.x, target.pos.y);
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
  }

  int execute() {
    Citizen c = (Citizen) this.blackboard.get("Human");
    String resource = (String) this.blackboard.get("Resource");
    Cell target = c.assignedBuilding.loc;

    // Check to see if we've arrived at home cell
    PVector direction = PVector.sub(target.pos, c.pos);
    float distance = direction.mag();

    if (distance < c.TARGET_RADIUS) {
      // Once we're there, drop off our stuff
      switch (resource) {
        case "Lumber":
          c.ownerState.lumberSupply += c.carryWeight;
          break;
        case "Food":
          c.ownerState.foodSupply += c.carryWeight;
          break;
        case "Ore":
          c.ownerState.oreSupply += c.carryWeight;
          break;
      }

      c.setCarryWeight(0);
      return SUCCESS;
    }

    // If not, keep movin
    c.moveTo(target.pos.x, target.pos.y);
    return FAIL;
  }
}
