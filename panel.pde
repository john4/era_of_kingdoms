class Panel  {
  float x, y, width; // positional values
  boolean isVisible;
  ArrayList<ITarget> targets;
  Panel(float x, float y, float width, ArrayList<ITarget> targets) {
    this.x = x;
    this.y = y;
    this.width = width;
    isVisible = false;
    this.targets = targets;
  }

  void draw() {
    float posX = x - boardMap.xo;
    float posY = y - boardMap.yo;

    if(isVisible) {
      rect(posX,posY,width,200);
      fill(255,0,0);
      for (int i = 0;i<targets.size();i++) {
        text(targets.get(i).getName(), posX+10+i*60,posY+30);
        rect(posX+10+i*60,posY+30,40,40);
        rect(posX+10+i*60,posY+130,40,40);
      }
    }
  }

  void click() {
    float posX = x - boardMap.xo;
    float posY = y + boardMap.yo;

    if(isVisible) {
      print("CLICK " + mouseX + " " + mouseY + "\n");
      for (int i = 0;i<targets.size();i++) {
        if(posX+10+i*60 < mouseX && mouseX < posX+70+i*60 && posY+30 < mouseY && mouseY < posY +70) {
          targets.get(i).increment();
          print("increment");
        } else if(posX+10+i*60 < mouseX && mouseX < posX+70+i*60 && posY+130 < mouseY && mouseY < posY +170) {
          targets.get(i).decrement();
          print("decrement");
        }
      }
    }
  }
}

interface IPanel {

}
