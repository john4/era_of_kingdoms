import java.util.PriorityQueue;
import java.util.Map;

class BoardMap {
  Cell[][] cells;
  PriorityQueue<PotentialPathNode> queue;
  Map<Cell, Float> distanceTable;
  int numRows;
  int numCols; // should divide screensize x and y
  int gridsize;
  float xo, yo;
  float zoom = 1;
  float angle = 0;
  int w;
  int h;

  BoardMap(int w, int h, int cellSize) {
    gridsize = cellSize;
    xo = 0;
    yo = 0;
    numCols = h / cellSize;
    numRows = w / cellSize;
    cells = new Cell[numRows][numCols];

    this.w = w;
    this.h = h;
  }

  void generate() {
    // Make grid with grass and border
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        int t;

        if (i == 0 || j == 0 || i == numRows - 1 || j == numCols - 1) {
          t = 3; // boundary
        } else {
          float chance = random(1);

          if (chance < 0.01 / gridsize) {
            t = 1;
          } else {
            t = 0;
          }
        }

        cells[i][j] = new Cell(i, j, t, gridsize);
      }
    }

    // Generate stone
    for (int k = 0; k < 10; k++) {
      countNeighbourtypes();
      for (int i = 0; i < numRows; i++) {

        for (int j = 0; j < numCols; j++) {
          Cell thiscell = cells[i][j];

          if (thiscell.nb[3] == 0 || thiscell.nb[3] == 3) {

            if (thiscell.terraintype == 0 && thiscell.nb[1] > 0) {
              float chance = random(1);

              if (chance < 0.075 * (thiscell.nb[1]+0.5)) {
                thiscell.terraintype = 1;
              }
            }
          }
        }
      }
    }

    // Generate forest
    for (int k = 0; k < 15; k++) {
      countNeighbourtypes();

      for (int i = 0; i < numRows; i++) {

        for (int j = 0; j < numCols; j++) {
          Cell thiscell = cells[i][j];

          if (thiscell.nb[3] == 0 || thiscell.nb[3] == 3) {

            if (thiscell.terraintype == 0 && thiscell.nb[0] > 3) {
              float chance = random(1);

              if (chance < 0.001 * (thiscell.nb[2] * 100+1)) {
                thiscell.terraintype = 2;
              }
            }
          }
        }
      }
    }

    // Remove small forest patches cells and thicken up forestation
    for (int k = 0; k < 2; k++) {
      countNeighbourtypes();

      for (int i = 0; i < numRows; i++) {

        for (int j = 0; j < numCols; j++) {
          Cell thiscell = cells[i][j];

          if (thiscell.terraintype == 2 && thiscell.nb[2] < 2) {
            thiscell.terraintype = 0;
          }

          if (thiscell.terraintype == 0 && thiscell.nb[2] > 5) {
            thiscell.terraintype = 2;
          }
        }
      }
    }

    // Finally, inform all cells of their neighbors
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        // north
        if (j != 0) {
          cells[i][j].north = cells[i][j-1];
          // northeast
          if (i < numRows - 1) {
            cells[i][j].northeast = cells[i+1][j-1];
          }
          // northwest
          if (i != 0) {
            cells[i][j].northwest = cells[i-1][j-1];
          }
        }
        // south
        if (j < numCols - 1) {
          cells[i][j].south = cells[i][j+1];
          // southeast
          if (i < numRows - 1) {
            cells[i][j].southeast = cells[i+1][j+1];
          }
          // southwest
          if (i != 0) {
            cells[i][j].southwest = cells[i-1][j+1];
          }
        }
        // east
        if (i < numRows - 1) {
          cells[i][j].east = cells[i+1][j];
        }
        // west
        if (i != 0) {
          cells[i][j].west = cells[i-1][j];
        }
      }
    }
  }

  // Get cell from x,y position.
  Cell cellAtPos(PVector pos) {
    if (pos.x <= this.w - CELL_SIZE && pos.y <= this.h - CELL_SIZE && pos.x >= 0 && pos.y >= 0) {
      int i = floor(pos.x / this.gridsize);
      int j = floor(pos.y / this.gridsize);
      Cell c = this.cells[i][j];
      return c;
    }
    System.out.println("Invalid position " + pos.x + ", " + pos.y + " in cellAtPos");
    return null;
  }

  void countNeighbourtypes() {
    for (int i = 1; i < numRows - 1; i++) {

      for (int j = 1; j < numCols - 1; j++) {
        cells[i][j].nb = new int[10];

        for (int k = -1; k <= 1; k++) {

          for (int l = -1; l <= 1; l++) {

            if (k == 0 && l == 0) {
            } else {
              int type = cells[i + k][j + l].terraintype;
              cells[i][j].nb[type] += 1;
            }
          }
        }
      }
    }
  }

  PotentialPathNode findPath(Cell from, Cell to) {
    // initialize
    queue = new PriorityQueue<PotentialPathNode>();
    distanceTable = new HashMap<Cell, Float>();

    queue.add(new PotentialPathNode(from, null, 0, to.euclideanDistanceTo(from)));
    distanceTable.put(from, 0.0);

    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        distanceTable.put(cells[i][j], Float.POSITIVE_INFINITY);
      }
    }

    // attempt to find path
    while (!queue.isEmpty()) {
      PotentialPathNode n = queue.poll();
      if (n.cell == to) {
        return n;
      }
      if (n.cell.hasImpass()) {
        continue;
      }

      // check for a cheaper existing path
      if (distanceTable.get(n.cell) > n.costSoFar) {
        distanceTable.put(n.cell, n.costSoFar);

        // check all adjecent cells
        findPathHelper(n, n.cell.northeast, to);
        findPathHelper(n, n.cell.northwest, to);
        findPathHelper(n, n.cell.southeast, to);
        findPathHelper(n, n.cell.southwest, to);
        findPathHelper(n, n.cell.north, to);
        findPathHelper(n, n.cell.south, to);
        findPathHelper(n, n.cell.east, to);
        findPathHelper(n, n.cell.west, to);
      }
    }

    // failed to find path
    print("no path available");
    return null;
  }

  void findPathHelper(PotentialPathNode parentNode, Cell neighbor, Cell to) {
    if (neighbor != null) {
      queue.add(new PotentialPathNode(
        neighbor,
        parentNode,
        parentNode.costSoFar + parentNode.cell.euclideanDistanceTo(neighbor),
        to.euclideanDistanceTo(neighbor)
      ));
    }
  }

  void draw() {
    background(52);
    translate(xo, yo);
    scale(zoom);
    rotate(angle);

    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        cells[i][j].show();
      }
    }
    //stroke(0,100,200);
    //for (int i = 0; i < numRows; i++) {
    //  for (int j = 0; j < numCols; j++) {

    //    if (j != 0) {
    //      line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].north.pos.x, cells[i][j].north.pos.y);
    //       //northeast
    //      if (i < numRows - 1) {
    //        line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].northeast.pos.x, cells[i][j].northeast.pos.y);
    //      }
    //      // northwest
    //      if (i != 0) {
    //        line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].northwest.pos.x, cells[i][j].northwest.pos.y);
    //      }
    //    }
    //    // south
    //    if (j < numCols - 1) {
    //      line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].south.pos.x, cells[i][j].south.pos.y);
    //      // southeast
    //      if (i < numRows - 1) {
    //        line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].southeast.pos.x, cells[i][j].southeast.pos.y);
    //      }
    //      // southwest
    //      if (i != 0) {
    //        line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].southwest.pos.x, cells[i][j].southwest.pos.y);
    //      }
    //    }
    //    // east
    //    if (i < numRows - 1) {
    //      line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].east.pos.x, cells[i][j].east.pos.y);
    //    }
    //    // west
    //    if (i != 0) {
    //      line(cells[i][j].pos.x, cells[i][j].pos.y, cells[i][j].west.pos.x, cells[i][j].west.pos.y);
    //    }
    //  }
    //}
  }
}

class PotentialPathNode implements Comparable<PotentialPathNode> {
  Cell cell;
  PotentialPathNode parent;
  float costSoFar, heuristicCost;

  PotentialPathNode(Cell point, PotentialPathNode par, float cost, float heur) {
    cell = point;
    parent = par;
    costSoFar = cost;
    heuristicCost = heur;
  }

  float getTotalCost() {
    return costSoFar + heuristicCost;
  }

  int compareTo(PotentialPathNode o) {
    if (getTotalCost() > o.getTotalCost()) {
      return 1;
    }
    if (getTotalCost() < o.getTotalCost()) {
      return -1;
    }
    return 0;
  }

  void draw() {
    stroke(0,100,200);
    if (parent != null) {
      line(cell.pos.x, cell.pos.y, parent.cell.pos.x, parent.cell.pos.y);
      parent.draw();
    }
  }
}
