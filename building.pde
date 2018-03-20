class Building extends Cell {
    int buildingType;
    float w, h;

    Building(int x, int y, int type, int gridsize) {
        super(x, y, 6, gridsize);
        buildingType = type;
        w = h = 10;
    }

    void show() {
        switch(buildingType) {
            case 0: // town center
                fill(255, 0, 0);
                break;
        }

        stroke(255, 255, 255);
        rect(x, y, w * i, h * j);
    }
}