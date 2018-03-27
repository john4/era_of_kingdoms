class Cell {
  ArrayList<Building> buildings = new ArrayList<Building>();
  Cell north, south, east, west;
  Cell northeast, northwest, southeast, southwest;
  int terraintype;          // value that determines the cell's type. Water, grass, forest, etc..
  int x, y;                 // the coordinates of the upper left corner of a cell
  int i, j;                 // i is width, j is height in grid
  PVector pos;              // the position of the center of the cell
  int[] nb = new int[5];    // number of terraintypes the neighbours have
  int gridsize;

  Cell(int gridi, int gridj, int type, int gridsize) {
    this.gridsize = gridsize;
    i = gridi;
    j = gridj;
    terraintype = type;
    x = i * gridsize;
    y = j * gridsize;
    pos = new PVector(x + gridsize/2, y + gridsize/2);
  }

  void show() {
    switch(terraintype) {
    case 0: //grass
      fill(103, 255, 109);
      break;
    case 1: // stone
      fill(160, 160, 160);
      break;
    case 2: //forest
      fill(0, 100, 4);
      break;
    case 3: // boundary
      fill(0);
      break;
    case 4: // sand
      fill(255, 231, 5);
      break;
    case 5: // water
      fill(0, 0, 255);
      break;
    case 6:
      fill(255, 0, 0);
      break;
    }

    noStroke();
    rect(x, y, gridsize, gridsize);
  }

  String getTerrainName() {
    switch(terraintype) {
    case 0: //grass
      return "grass";
    case 1: // stone
      return "stone";
    case 2: //forest
      return "forest";
    case 3: // boundary
      return "boundary";
    case 4: // sand
      return "sand";
    case 5: // water
      return "water";
    default:
      return "nothing";
    }
  }

// Returns true if the given position is within the bounds of this cell
  boolean isIn(float posX, float posY) {
    return x < posX && posX < x + gridsize && y < posY && posY < y + gridsize;
  }
  
  boolean hasImpass() {
    for (Building building : buildings) {
      if (building.impassable) {
        return true;
      }
    }
    return false;
  }
  
  float euclideanDistanceTo(Cell o) {
    return this.euclideanDistanceTo(o.pos.x, o.pos.y);
  }
  
  float euclideanDistanceTo(float x0, float y0) {
    return (float) (Math.sqrt(Math.pow(pos.x - x0, 2) + Math.pow(pos.y - y0, 2))); 
  }
}
