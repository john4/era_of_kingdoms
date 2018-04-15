void mouseWheel(MouseEvent event) {
  float e = event.getCount();
}

void keyPressed() {
  if (key == 'r') {
    resetCamera();
  }

  if (key == ' ') {
    bgmFile.stop();
    setup();
  }

  if (key == 'z') {
    if (boardMap.zoom == 1) {
      boardMap.zoom = 2;
    } else {
      resetCamera();
    }
  }
}

void resetCamera() {
  boardMap.angle = 0;
  boardMap.zoom = 1;
  boardMap.xo = 0;
  boardMap.yo = 0;
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    boardMap.xo = boardMap.xo + (mouseX - pmouseX);
    boardMap.yo = boardMap.yo + (mouseY - pmouseY);
  }
}
