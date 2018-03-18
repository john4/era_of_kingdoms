// Game Artificial Intelligence
// Professor Gold
// Spring 2018
// Final Project
//
// John Martin, Arianna Tang, Nicholas Lailler
//


int rows;
int cols; // should divide screensize x and y

int gridsize = 10;

float xo, yo;
float zoom = 1;
float angle = 0;

Cell c;
Cell[][] cells;

void setup() {
    size(960, 540);

    //fullScreen();
    xo = 0;
    yo = 0;

    cols = height / gridsize;
    rows = width / gridsize;

    cells = new Cell[rows][cols];

    generate();
}

void draw() {
    background(52);
    translate(xo, yo);
    scale(zoom);
    rotate(angle);

    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            cells[i][j].show();
        }
    }
}