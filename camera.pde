void mouseWheel(MouseEvent event) {
    float e = event.getCount();

    zoom += event.getAmount() / 10;
    xo -= event.getAmount() * mouseX / 10;
    yo -= event.getAmount() * mouseY / 10;
}

void keyPressed() {
    if (key == 'r') {
        angle = 0;
        zoom = 1;
        xo = 0;
        yo = 0;
    }

    if (key == ' ') {
        setup();
    }
}

void mouseDragged() {
    if (mouseButton == LEFT) {
        xo= xo + (mouseX - pmouseX);
        yo = yo + (mouseY - pmouseY);
    }

    if (mouseButton == RIGHT) {
        if (pmouseY-mouseY > 0) {
            angle -= .005;
        } else {
            angle += .005;
        }
    }
}