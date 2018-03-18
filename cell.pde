class Cell {

    int terraintype;          // value that determines the cell's type. Water, grass, forest, etc..
    int x, y;                 // the coordinates of the upper left corner of a cell
    int i, j;                 // i is width, j is height in grid
    int[] nb = new int[5];    // number of terraintypes the neighbours have

    Cell(int gridi, int gridj, int type) {
        i = gridi;
        j = gridj;
        terraintype = type;
        x = i * gridsize;
        y = j * gridsize;
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
}