import java.util.Iterator;

class SuperPanel {
  float x, y;
  float rand;
  boolean rotatingX, rotatingY, rotatingZ;
  int rotProgress, fallingProgress;
  float teeter;
  int DEGREE_CHANGE;

  SuperPanel(float x, float y) {
    rand = random(100);
    DEGREE_CHANGE = int(random(10)+5);
    teeter = 0;
    rotProgress = 0;
    this.x = x;
    this.y = y;
  }

  void fallY(float amount) {
    y += amount;
  }

  void render(int z, boolean shouldRotate) {
    pushMatrix();
    translate(x, y, z);
    rotProgress += DEGREE_CHANGE;
    if ((rotatingX || rotatingY || rotatingZ) && rotProgress >= 360) {  // kill overrotation
      rotatingX = false;
      rotatingY = false;
      rotatingZ = false;
      rotProgress = 0;
      teeter = 0;
    } else if (rotatingX) {
      rotateX(radians(rotProgress));
    } else if (rotatingY) {
      rotateY(radians(rotProgress));
    } else if (rotatingZ) {
      rotateZ(radians(rotProgress));
    } else if (shouldRotate) {
      switch (int(random(3))) {
      case 0:
        rotatingX = true;
        rotProgress = 0;
        break;
      case 1:
        rotatingY = true;
        rotProgress = 0;
        break;
      case 2:
        rotatingZ = true;
        rotProgress = 0;
        break;
      }
    } else {
      teeter += radians(sin(frameCount / 100.0) * 0.5);
      rotateZ(teeter);
      rotateY(teeter);
    }
    scale(0.5 + 5 * level, 0.5 + 5 * level, 0.2);
    box(PANEL_SIZE);
    popMatrix();
  }
}

ArrayList<SuperPanel> panels;
int panelsX;
int panelsY;
final int PANEL_SIZE = 50;

void initSuperPanels() {
  panelsX = width/PANEL_SIZE + 2;
  panelsY = height/PANEL_SIZE + 2;
  panels = new ArrayList<SuperPanel>();
  for (int i = 0; i < panelsX; i++) {
    for (int j = 0; j < panelsY+1; j++) {
      panels.add(new SuperPanel(i * PANEL_SIZE, j * PANEL_SIZE));
    }
  }
}

void doSuperPanels() {
  pushMatrix();
  noStroke();
  lights();
  fill(baseColor);
  // far wall
  for (SuperPanel s : panels) {
    boolean shouldRotate = bass > 8;
    s.render(50, shouldRotate);
    println("level" + level);
    if (mid > (mid_avg * 1.1)) {
      //float fall_amount = (mid > PANEL_SIZE ? PANEL_SIZE : mid);
      float fall_amount = 10;
      s.fallY(fall_amount);
    }
  }
  popMatrix();
  
  pruneRows();
}

void pruneRows() {
  boolean trigger = false; // triggers addition of a new row when needed
  // Iterator approach avoids ConcurrentModificationException, since we are live-editing a Collection
  for (Iterator<SuperPanel> iterator = panels.iterator(); iterator.hasNext(); ) {
    SuperPanel s = iterator.next();
    if (s.y > height+PANEL_SIZE) {
      iterator.remove();
      trigger = true;
    }
  }

  if (trigger) {  // add new row (just above screen) if needed
    for (int i = 0; i < panelsX; i++) {
      panels.add(new SuperPanel(i * PANEL_SIZE, -1 * PANEL_SIZE));
    }
  }
}
