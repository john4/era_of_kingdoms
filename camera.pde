void mouseWheel(MouseEvent event) {
  float e = event.getCount();

  map.zoom += event.getAmount() / 10;
  map.xo -= event.getAmount() * mouseX / 10;
  map.yo -= event.getAmount() * mouseY / 10;
}

void keyPressed() {
  if (key == 'r') {
    map.angle = 0;
    map.zoom = 1;
    map.xo = 0;
    map.yo = 0;
  }

  if (key == ' ') {
    setup();
  }
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    map.xo = map.xo + (mouseX - pmouseX);
    map.yo = map.yo + (mouseY - pmouseY);
  }

  if (mouseButton == RIGHT) {
    if (pmouseY-mouseY > 0) {
      map.angle -= .005;
    } else {
      map.angle += .005;
    }
  }
}