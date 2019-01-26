import java.util.Iterator;

final float RAMPDOWN_FACTOR = 25;  // ramps down emissive lights linearly to prevent strobe flashing

int loudFrames = 0;

void TexturedCube() {
  beginShape(QUADS);
  texture(logo_solid);

  // Given one texture and six faces, we can easily set up the uv coordinates
  // such that four of the faces tile "perfectly" along either u or v, but the other
  // two faces cannot be so aligned.  This code tiles "along" u, "around" the X/Z faces
  // and fudges the Y faces - the Y faces are arbitrarily aligned such that a
  // rotation along the X axis will put the "top" of either texture at the "top"
  // of the screen, but is not otherwised aligned with the X/Z faces. (This
  // just affects what type of symmetry is required if you need seamless
  // tiling all the way around the cube)

  // +Z "front" face
  vertex(-1, -1, 1, 0, 0);
  vertex( 1, -1, 1, 1, 0);
  vertex( 1, 1, 1, 1, 1);
  vertex(-1, 1, 1, 0, 1);

  // -Z "back" face
  vertex( 1, -1, -1, 0, 0);
  vertex(-1, -1, -1, 1, 0);
  vertex(-1, 1, -1, 1, 1);
  vertex( 1, 1, -1, 0, 1);

  // +Y "bottom" face
  vertex(-1, 1, 1, 0, 0);
  vertex( 1, 1, 1, 1, 0);
  vertex( 1, 1, -1, 1, 1);
  vertex(-1, 1, -1, 0, 1);

  // -Y "top" face
  vertex(-1, -1, -1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1, -1, 1, 1, 1);
  vertex(-1, -1, 1, 0, 1);

  // +X "right" face
  vertex( 1, -1, 1, 0, 0);
  vertex( 1, -1, -1, 1, 0);
  vertex( 1, 1, -1, 1, 1);
  vertex( 1, 1, 1, 0, 1);

  // -X "left" face
  vertex(-1, -1, -1, 0, 0);
  vertex(-1, -1, 1, 1, 0);
  vertex(-1, 1, 1, 1, 1);
  vertex(-1, 1, -1, 0, 1);

  endShape();
}


class FlyingCube {
  PVector dir;
  float x, y, z, teeter, emissive_brightness;
  color c;

  boolean rotatingX, rotatingY, rotatingZ, rampingDown;
  int rotProgress, DEGREE_CHANGE, emissive_hue;


  FlyingCube() {
    float dx = (random(100) - 50);
    float dy = (random(100) - 50);
    dir = new PVector(dx, dy, 50);
    dir.normalize();
    x = width/2.0;
    y = height/2.0;
    z = -20;
    c = color(random(100) + 155);
    emissive_hue = 53+round(random(17));

    DEGREE_CHANGE = int(random(10)+5);
    teeter = 0;
    rotProgress = 0;
    rotatingX = false;
    rotatingY = false;
    rotatingZ = false;
    rampingDown = false;
  }

  void render(float velocity, boolean shouldRotate) {
    // apply velocity
    x += dir.x * velocity;
    y += dir.y * velocity;
    z += dir.z * velocity;

    // render
    fill(c);
    pushMatrix();
    translate(x, y, z);

    // rotation
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


    //rotateY(sin(frameCount / 1000.0));
    shininess(5.0);
    float emissive_prop = map(mid, 0, 10, 0, 500);
    // radially clamp emissive prop
    float d = dist(x, y, z, width/2.0, height/2.0, -20);
    //d = map(d,0,300,0,100);
    emissive_prop-=d;
    if (loudFrames > 60) emissive_prop = 500;
    if (emissive_prop > emissive_brightness) emissive_brightness = min(emissive_prop, 500); 
    else emissive_brightness -= RAMPDOWN_FACTOR;
    emissive(hue(baseColor), 100, emissive_brightness);
    scale(10);
    textureMode(NORMAL);
    TexturedCube();
    popMatrix();
  }

  boolean isOffScreen() {
    return x < 0 || x > width || y < 0 || y > height || z > (height/2.0) / tan(PI*30.0 / 180.0) - 100;
  }
}

ArrayList<FlyingCube> cubes = new ArrayList<FlyingCube>();
int greaterThanFrames = 0;

void initWarp() {
}

void doWarp() {
  if (bass > bass_avg) greaterThanFrames++; 
  else greaterThanFrames = 0;
  if (level > level_avg * 1.5) loudFrames++; 
  else loudFrames = 0;

  //colorMode(RGB);
  clear();
  camera(width/2.0 + (-50 * sin(frameCount/100.0)), height/2.0 + (-50 * cos(frameCount/100.0)), (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, frameCount, frameCount);
  lightSpecular(0, 0, 40);
  ambientLight(0, 0, 0);
  //spotLight(0,100,100,width/2, height/2, 300, 0, 0, -1, PI/2, 2);\
  spotLight(hue(baseColor), 100, 100, width/2, height/2, 300, 0, 0, -1, PI/2, 2);
  // split complementary directional lights
  directionalLight(100-hue(baseColor)-5, 100, 80, 0, -1, 0);
  directionalLight(100-hue(baseColor)+5, 100, 80, 0, 1, 0);
  //println(level_avg);
  //pointLight(0, 0, map((float)level_avg,0,0.4,0,100), 0, 0, 0);
  int removal_count = 1;
  for (Iterator<FlyingCube> iterator = cubes.iterator(); iterator.hasNext(); ) {
    FlyingCube c = iterator.next();

    c.render(loudFrames < 60 ? level * 50 : 15, (greaterThanFrames > 10));
    if (c.isOffScreen()) {
      iterator.remove();
      removal_count++;
    }
  }
  for (int i = 0; i < removal_count; i++)
    if (cubes.size() < 2000) cubes.add(new FlyingCube());
}
