void generate() {
    // Make grid with grass and border
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            int t;

            if (i == 0 || j == 0 || i == rows - 1 || j == cols - 1) {
                t = 3; // boundary
            } else {
                float chance = random(1);

                if (chance < 0.01 / gridsize) {
                    t = 1;
                } else {
                    t = 0;
                }
            }

            cells[i][j] = new Cell(i, j, t);
        }
    }

    // Generate stone
    for (int k = 0; k < 10; k++) {
        countNeighbourtypes();
        for (int i = 0; i < rows; i++) {

            for (int j = 0; j < cols; j++) {
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

        for (int i = 0; i < rows; i++) {

            for (int j = 0; j < cols; j++) {
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

        for (int i = 0; i < rows; i++) {

            for (int j = 0; j < cols; j++) {
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

    // Add town center to random grass cell
    boolean placedTownCenter = false;

    while (!placedTownCenter) {
        int townRow = int(random(rows));
        int townCol = int(random(cols));
        if (cells[townRow][townCol].terraintype == 0) {
            cells[townRow][townCol] = new Building(townRow, townCol, 0);
            placedTownCenter = true;
        }
    }
}

void countNeighbourtypes() {
    for (int i = 1; i < rows - 1; i++) {

        for (int j = 1; j < cols - 1; j++) {
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