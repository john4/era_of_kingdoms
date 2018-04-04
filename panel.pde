final int TARGET_SIZE = 40;

class Panel  {
  float x, y, width; // positional values
  boolean isVisible;
  ArrayList<ATarget> targets;
  int[] c = new int[3];

  Panel(float x, float y, float width, ArrayList<ATarget> targets, int r, int g, int b) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.isVisible = false;
    this.targets = targets;
    this.c = new int[] { r, g, b };
  }

  void draw() {
    float posX = x - boardMap.xo;
    float posY = y - boardMap.yo;

    if (isVisible) {
      fill(255, 255, 255);
      rect(posX, posY, width, 200);
      fill(255, 0, 0);

      for (int i = 0; i < targets.size(); i += 2) {
        text(targets.get(i).getName(), posX + 10 + i * 60, posY + 30);
        rect(posX+10+i*60,posY+30, TARGET_SIZE, TARGET_SIZE);
      }

      for (int i = 1; i < targets.size(); i+= 2) {
        text(targets.get(i).getName(), posX + 10 + (i - 1) * 60, posY + 100);
        rect(posX + 10 + (i - 1) * 60, posY + 100, TARGET_SIZE, TARGET_SIZE);
      }
    }

    fill(this.c[0], this.c[1], this.c[2]);
    rect(this.x - boardMap.xo, boardMap.numCols * boardMap.gridsize - 20 - boardMap.yo, 20, 20);
  }

  void click() {
    float posX = x - boardMap.xo;
    float posY = y + boardMap.yo;

    if (isVisible) {
      for (int i = 0; i < targets.size(); i += 2) {
        if (posX + 10 + i * 60 < mouseX && mouseX < posX + 70 + i * 60 && posY + 30 < mouseY && mouseY < posY + 30 + TARGET_SIZE) {
          targets.get(i).clicked();
        }
      }

      for (int i = 1; i < targets.size(); i += 2) {
        if (posX + 10 + (i - 1) * 60 < mouseX && mouseX < posX + 70 + (i - 1) * 60 && posY + 100 < mouseY && mouseY < posY + 100 + TARGET_SIZE) {
          targets.get(i).clicked();
        }
      }
    }
  }

  boolean inPanelToggle(int x, int y) {
    return (this.x < mouseX && this.x + 20 > mouseX && boardMap.numCols * boardMap.gridsize - 20 < mouseY &&
       boardMap.numCols * boardMap.gridsize > mouseY);
  }

  void toggleVisible() {
    for (Panel panel : userInterface.panels) {
      if (panel != this) {
        panel.isVisible = false;
      }
    }

    this.isVisible = !this.isVisible;
  }
}
