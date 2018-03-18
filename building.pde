class Building extends Cell {

    int buildingType;

    Building(int x, int y, int type) {
        super(x, y, 6);
        buildingType = type;
    }

    void show() {
        switch(buildingType) {
            case 0: // town center
                fill(255, 0, 0);
                break;
        }

        stroke(255, 255, 255);
        rect(x, y, gridsize * i, gridsize * j);
    }
}