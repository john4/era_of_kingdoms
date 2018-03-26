void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  boardMap.zoom += event.getAmount() / 10;
  boardMap.xo -= event.getAmount() * mouseX / 10;
  boardMap.yo -= event.getAmount() * mouseY / 10;
}

void keyPressed() {
  if (key == 'r') {
    boardMap.angle = 0;
    boardMap.zoom = 1;
    boardMap.xo = 0;
    boardMap.yo = 0;
  }

  if (key == ' ') {
    setup();
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    boardMap.xo = boardMap.xo + (mouseX - pmouseX);
    boardMap.yo = boardMap.yo + (mouseY - pmouseY);
  }

  if (mouseButton == RIGHT) {
    if (pmouseY-mouseY > 0) {
      boardMap.angle -= .005;
    } else {
      boardMap.angle += .005;
    }
  }
}
