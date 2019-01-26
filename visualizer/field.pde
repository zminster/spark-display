import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import java.util.Iterator;

class FieldCube {
  PVector dir, destination, position;
  float teeter, emissive_brightness;
  color c;

  boolean rotatingX, rotatingY, rotatingZ, rampingDown;
  int rotProgress, DEGREE_CHANGE, emissive_hue;


  FieldCube() {
    float dx = (random(100) - 50);
    float dy = (random(100) - 50);
    dir = new PVector(dx, dy);
    dir.normalize();
    float destination_x = dx < 0 ? random(cameraPosition.x-width, cameraPosition.x) : random(cameraPosition.x, cameraPosition.x+width);
    float destination_y;
    if (abs(destination_x - cameraPosition.x) < 40)  // x within bad zone, y must be outside
      destination_y = dy < 0 ? random(cameraPosition.y-height, cameraPosition.y-20) : random(cameraPosition.y+20, cameraPosition.y+height);
    else
      destination_y = dy < 0 ? random(cameraPosition.y-height, cameraPosition.y) : random(cameraPosition.y, cameraPosition.y+height);
    destination = new PVector(destination_x, 
      destination_y, 
      200);
    position = new PVector(width/2.0, height/2.0, -1000);
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
    position.x = destination.x;
    position.y = destination.y;
    // apply velocity
    /*if (abs(x - destination.x) > 1)
     x += dir.x * velocity;
     if (abs(y - destination.y) > 1)
     y += dir.y * velocity;*/
    position.z += velocity;

    // render
    fill(c);
    pushMatrix();
    translate(position.x, position.y, position.z);

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
    float emissive_prop = map(mid, 0, 15, 0, 500);
    // radially clamp emissive prop
    float d = dist(position.x, position.y, position.z, cameraPosition.x, cameraPosition.y, -200);
    //d = map(d,0,300,0,100);
    emissive_prop-=d;
    emissive_prop+=0.1;
    if (loudFrames > 60) emissive_prop = 500;
    if (emissive_prop > emissive_brightness) emissive_brightness = min(emissive_prop, 500); 
    else emissive_brightness -= RAMPDOWN_FACTOR;
    emissive(hue(baseColor), 100, emissive_brightness);
    scale(6 + level * 50);
    textureMode(NORMAL);
    TexturedCube();
    //box(5 + level * 300);
    popMatrix();
  }

  boolean isOffScreen() {
    return position.z > cameraPosition.z;  //-120
  }
}

ArrayList<FieldCube> field = new ArrayList<FieldCube>();
PVector cameraPosition, cameraVelocity, cameraAccel;
boolean cameraMoving;
int cameraMovingFrame;

void initField() {
  cameraPosition = new PVector(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0));
  cameraVelocity = new PVector(0, 0, 0);
  cameraAccel = new PVector(0, 0, 0);
  cameraMoving = false;
  cameraMovingFrame = 0;
  field.add(new FieldCube());
}

void doField() {
  positionCubeFieldCamera();
  advanceCubeField();
}

void advanceCubeField() {
  if (bass > bass_avg) greaterThanFrames++; 
  else greaterThanFrames = 0;
  if (level > level_avg * 1.5) loudFrames++; 
  else loudFrames = 0;
  clear();
  pushMatrix();
  translate(cameraPosition.x, cameraPosition.y, cameraPosition.z - 200);
  //sphere(40);
  popMatrix();
  lightSpecular(0, 0, 40);
  ambientLight(0, 0, 0);
  //spotLight(0,100,100,width/2, height/2, 300, 0, 0, -1, PI/2, 2);\
  spotLight(hue(baseColor), 100, 100, cameraPosition.x, cameraPosition.y, -200, 0, 0, -1, PI/2, 2);
  // split complementary directional lights
  directionalLight(100-hue(baseColor)-5, 100, 80, 0, -1, 0);
  directionalLight(100-hue(baseColor)+5, 100, 80, 0, 1, 0);
  //println(level_avg);
  //pointLight(0, 0, map((float)level_avg,0,0.4,0,100), 0, 0, 0);
  int removal_count = 10;
  for (Iterator<FieldCube> iterator = field.iterator(); iterator.hasNext(); ) {
    FieldCube c = iterator.next();

    c.render(loudFrames < 60 ? 10 + bass*2 : 15, (greaterThanFrames > 10));
    if (c.isOffScreen()) {
      iterator.remove();
      removal_count++;
    }
  }
  for (int i = 0; i < removal_count; i++)
    if (cubes.size() < 4000) field.add(new FieldCube());
}

void positionCubeFieldCamera() {
  /*//FieldCube nearest = field.get(0);
   ArrayList<FieldCube> nearest_cubes = new ArrayList<FieldCube>();
   //PVector camera2D = new PVector(cameraPosition.x, cameraPosition.y);
   //PVector nearestC = new PVector(field.get(0).position.x, field.get(0).position.y);
   for (FieldCube c : field) {
   if (abs(c.position.x-cameraPosition.x) < 20 && abs(c.position.y-cameraPosition.y) < 20)
   nearest_cubes.add(c);
   //if (c.position.z < cameraPosition.z - 200 && c.position.dist(cameraPosition) < nearest.position.dist(cameraPosition))
   // nearest = c;
   //PVector c2d = new PVector(c.position.x, c.position.y);
   // if (c.position.z < cameraPosition.z && c2d.dist(camera2D) < nearestC.dist(camera2D)) {
   // nearestC = new PVector(c.position.x, c.position.y);
   // nearest = c;
   // }
   }
   //println("CAMERA: " + cameraPosition);
   //println(nearest.position.dist(cameraPosition));
   //println("NEAREST: " + nearest.position);
   
   //if (cameraPosition.z - nearest.position.z < 200 && !cameraMoving) {
   boolean shouldMove = false;
   PVector totalOffset = new PVector(0, 0, 0);
   for (FieldCube nearest : nearest_cubes) {
   if (abs(cameraPosition.z - nearest.position.z) < 150) {
   // add velocity in direction opposite of near cube
   //PVector cube2D = new PVector(nearest.position.x, nearest.position.y);
   //PVector cam2D = new PVector(cameraPosition.x, cameraPosition.y);
   PVector heading = PVector.sub(nearest.position, cameraPosition);
   heading.normalize();
   totalOffset.add(heading);
   
   /// println("TRIGGERED ACCEL");
   /// println("NEAREST:" +nearest.position);
   //  println("CAM:" + cameraPosition);
   //  println("HEADING:" + heading);
   
   if (!cameraMoving) {
   shouldMove = true;
   }
   
   // println(cameraVelocity);
   //break;
   //noLoop();
   }
   }
   if(!cameraMoving && shouldMove) {
   cameraMoving = true;
   cameraMovingFrame = frameCount;
   
   println("MOVING TOTAL OFFSET: " + totalOffset);
   cameraVelocity.x = totalOffset.x * 5;
   cameraVelocity.y = totalOffset.y * 5;
   }
   
   // update accelerations (gravity 0.01, velocity should tend to 0)
   cameraAccel.x = (abs(cameraVelocity.x) > 1.2 ? 1 : 0) * (cameraVelocity.x < 0 ? 1 : -1);
   cameraAccel.y = (abs(cameraVelocity.y) > 1.2 ? 1 : 0) * (cameraVelocity.y < 0 ? 1 : -1);
   
   //if (abs(cameraAccel.x) < 0.1) cameraAccel.x = 0;
   //if (abs(cameraAccel.y) < 0.1) cameraAccel.y = 0;
   //println("ACCELERATION: " + cameraAccel);
   
   cameraVelocity.x += cameraAccel.x;
   cameraVelocity.y += cameraAccel.y;
   
   //println("VELOCITY: " + cameraVelocity);
   cameraPosition.x += cameraVelocity.x;
   cameraPosition.y += cameraVelocity.y;
   
   if (cameraMoving && frameCount - cameraMovingFrame > frameRate/6)
   cameraMoving = false;
   
   cameraAccel.x *= 0.5;
   cameraAccel.y *= 0.5;
   
   // slow tf down
   // if (abs(cameraVelocity.x) < 0.1) cameraVelocity.x *= 0.1;
   //if (abs(cameraVelocity.y) > 1) cameraVelocity.y *= 0.1;
   
   
   
   
   */
  //printCamera();

  float offset = map(sin(frameCount/100.0), -1, 1, -50, 50);
  camera(cameraPosition.x, cameraPosition.y, cameraPosition.z-30, cameraPosition.x+offset, cameraPosition.y, 0, 0, frameCount, frameCount);
  //perspective(PI/3.0, width/height, 2000, cameraPosition.z*10.0); 
  // find nearest cube
  // calculate # of frames between us and new cube
  // advance camera correctly to avoid collision
}
