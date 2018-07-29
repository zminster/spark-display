final int TESSELLATION_FACTOR = 10;
int cols, rows, scl, w, h;
float[][] terrain;
float flying = 0;

void initVaporwave() {
  w = width * 3;
  h = height * 3;
  scl = height / TESSELLATION_FACTOR;
  cols = w / scl;
  rows = h / scl;
  terrain = new float[cols][rows];
}

void doVaporwave() {
  // prepare frame
  //background(62,93,38);
  background(5+hue(baseColor),50,10);
  
  // prepare terrain values
  flying -= level * 0.5;
  float yoff = flying;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      terrain[x][y] = map(noise(xoff,yoff), 0, 1, -5, 500);
      xoff+=0.4;
    }
    yoff+=0.4;
  }
  
  // rotate frame appropriately
  translate(width/2,height/2);
  rotateX(PI/3);
  translate(-w/2,-h/2,0);
  
  // add lighting
  spotLight(hue(baseColor),100,100, w/2,0,300, 0,1,0, PI/4,1);
    spotLight(hue(baseColor),25,100, w/2,0,300, 0,-1,0, PI,1);

  //spotLight(216,18,225, w/2,0,200, 0,1,0, PI/4,1);
  //spotLight(216,18,225, w/2,0,100, 0,1,0, PI/4,1);
  pointLight(hue(baseColor),100,100, w/2,0,100);
  directionalLight(62,93,38,0,0,-1);
  //directionalLight(216,18,225,0,1,0);
  
  // adjust properties
  fill(0,0,100);
  shininess(5.0);
  strokeWeight(1);
  noStroke();
  
  // draw "sun" & logo
  pushMatrix();
  translate(w/2,-50,100);
  rotateX(-PI/3);
  ellipse(0,0,500,500);
  tint(hue(baseColor),50,100);
  image(logo, -130,-190);
  noTint();
  popMatrix();
  
  // readjust properties
  stroke(hue(baseColor),100,100);
  emissive(0,0,0);
  
  // draw terrain
  float terrain_z1, terrain_z2;
  int xCenterOffset;
  for (int y = 0; y < rows-1; y++) {
    beginShape(TRIANGLE_STRIP);
    for (int x = 0; x < cols; x++) {
      terrain_z1 = terrain[x][y];
      terrain_z2 = terrain[x][y+1];
      // adjust terrain near "road" parabolically
      // f(x) = (x/6)^2
      // where x is domain-shifted to make "road" (position w/2) the center
      // and 6 is the number of squares left/right to affect
      xCenterOffset = x*scl-w/2;
      if (abs(xCenterOffset) <= 6 * scl) {
        if (abs(xCenterOffset) <= 3 * scl) {
          terrain_z1 *= 0.1;
          terrain_z2 *= 0.1;
        } else {
          terrain_z1 *= 0.3 * (abs(xCenterOffset) / scl - 2);
          terrain_z2 *= 0.3 * (abs(xCenterOffset) / scl - 2);
        }
        /* // DEPRECATED ::
        float f_val = xCenterOffset/(6.0*scl);
        terrain_z1 *= f_val * f_val;
        terrain_z2 *= f_val * f_val;*/
      }
      
      // DEPRECATED: adjust horizon parabolically (so mountains "fade into existence")
      // horizon is y=0, terrain values at y=0 should be 0 and gradually ramp up to full output
      // according to function f(y) = (y/6)^2 as before
      /*if (y <= 10) {
        float f_val = y/10.0;
        terrain_z1 *= f_val * f_val;
        terrain_z2 *= f_val * f_val;
      }*/
      
      vertex(x * scl, y * scl, terrain_z1);
      vertex(x * scl, (y+1) * scl, terrain_z2);
    }
    endShape();
  }
}
