class Box {
  float rand;
  boolean rotatingX, rotatingY, rotatingZ;
  int rotProgress;
  int DEGREE_CHANGE;
  
  Box() {
    rand = random(100);
    DEGREE_CHANGE = int(random(10)+5);
  }
  
  void render(int x, int y, int z, boolean shouldRotate) {
    pushMatrix();
    translate(x, y, z);
    rotProgress += DEGREE_CHANGE;
    if ((rotatingX || rotatingY || rotatingZ) && rotProgress >= 360) {  // kill overrotation
      rotatingX = false;
      rotatingY = false;
      rotatingZ = false;
      rotProgress = 0;
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
    }
    scale(1,1,0.2);
    box(48);
    popMatrix();
  }
    
}

Box[][] boxes;
int boxesX;
int boxesY;
final int BOX_SIZE = 50;

void initPanels() {
  boxesX = width/BOX_SIZE + 2;
  boxesY = height/BOX_SIZE + 2;
  boxes = new Box[boxesX][boxesY];
  for (int i = 0; i < boxesX; i++) {
    for (int j = 0; j < boxesY; j++) {
      boxes[i][j] = new Box();
    }
  }
}

void doPanels() {
  float bass = fft.calcAvg(0, 400);
  float mid = fft.calcAvg(400, 4000)*8;
  float high = fft.calcAvg(4000, 20000)*8;
  
  pushMatrix();
  noStroke();
  lights();
  fill(baseColor);
  // far wall
  for (int i = 0; i < boxesX; i++) {
    for (int j = 0; j < boxesY; j++) {
      boolean shouldRotate = bass > 8;
      /*if (j / float(boxesY) < 0.33 && bass > 10) shouldRotate = true;
      if (j / float(boxesY) < 0.66 && mid > 5) shouldRotate = true;
      if (high > 2) shouldRotate = true;*/
      boxes[i][j].render(i * BOX_SIZE, j * BOX_SIZE, 50, shouldRotate);
    }
  }
  popMatrix();
}