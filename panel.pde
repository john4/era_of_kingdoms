class Panel  {
  float x, y, width; // positional values
  boolean isVisible;
  ArrayList<ITarget> targets;
  int[] c = new int[3];

  Panel(float x, float y, float width, ArrayList<ITarget> targets, int r, int g, int b) {
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
      for (int i = 0; i < targets.size(); i++) {
        text(targets.get(i).getName(), posX + 10 + i * 60, posY + 30);
        rect(posX+10+i*60,posY+30,40,40);
        rect(posX+10+i*60,posY+130,40,40);
      }
    }

    fill(this.c[0], this.c[1], this.c[2]);
    rect(this.x - boardMap.xo, boardMap.numCols * boardMap.gridsize - 20 - boardMap.yo, 20, 20);
  }

  void click() {
    float posX = x - boardMap.xo;
    float posY = y + boardMap.yo;

    if(isVisible) {
      print("CLICK " + mouseX + " " + mouseY + "\n");
      for (int i = 0; i < targets.size(); i++) {
        if (posX + 10 + i * 60 < mouseX && mouseX < posX + 70 + i * 60 && posY + 30 < mouseY && mouseY < posY + 70) {
          targets.get(i).increment();
          print("increment");
        } else if(posX + 10 + i * 60 < mouseX && mouseX < posX + 70 + i * 60 && posY + 130 < mouseY && mouseY < posY + 170) {
          targets.get(i).decrement();
          print("decrement");
        }
      }
    }
  }

  boolean inPanelToggle(int x, int y) {
    return (this.x < mouseX && this.x + 20 > mouseX && boardMap.numCols * boardMap.gridsize - 20 < mouseY &&
       boardMap.numCols * boardMap.gridsize > mouseY);
  }

  void toggleVisible() {
    this.isVisible = !this.isVisible;
  }
}

interface IPanel {

}
