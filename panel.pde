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
    if(isVisible) {
      rect(x,y,width,200);
      fill(255,0,0);
      for (int i = 0;i<targets.size();i++) {
        text(targets.get(i).name, x+10+i*60,y+30);
        rect(x+10+i*60,y+30,40,40);
        rect(x+10+i*60,y+130,40,40);
      }


    }
  }

  void click() {
    if(isVisible) {
      print("CLICK " + mouseX + " " + mouseY + "\n");
      for (int i = 0;i<targets.size();i++) {
        if(x+10+i*60 < mouseX && mouseX < x+70+i*60 && y+30 < mouseY && mouseY < y +70) {
          targets.get(i).increment();
          print("increment");
        } else if(x+10+i*60 < mouseX && mouseX < x+70+i*60 && y+130 < mouseY && mouseY < y +170) {
          targets.get(i).decrement();
          print("decremnt");
        }
      }
    }
  }
}

interface IPanel {

}
