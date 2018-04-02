class Wander extends Task {
  Wander(Blackboard bb, int radius) {
    this.blackboard = bb;
    this.blackboard.put("Radius", radius);
    this.blackboard.put("HomeCircle", new ArrayList<Cell>());

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

    // Check to see if we've arrived at our target cell
    PVector direction = PVector.sub(target.pos, h.pos);
    float distance = direction.mag();

    // If we have, pick a new target
    if (distance < h.TARGET_RADIUS) {
      target = pickNewDestination();
      this.blackboard.put("Target", target);
    }

    h.moveTo(target.pos.x, target.pos.y);

    // TODO: A*
    // PotentialPathNode path = boardMap.findPath(h.loc, target);
    // path.draw();
    // Cell target = boardMap.findPath(h.

    return SUCCESS;
  }
}

class Gather extends Task {
  Gather(Blackboard bb, int terrain) {
    this.blackboard = bb;
    this.blackboard.put("Terrain", terrain);
  }

  int execute() {
    return FAIL;
  }
}