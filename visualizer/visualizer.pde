import ddf.minim.analysis.FFT;
import ddf.minim.Minim;
import ddf.minim.AudioInput;
import processing.video.Capture;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFX fx;

String msg;
PFont font;
PImage bg, logo, logo_solid;

Minim minim;
AudioInput audioInput;
FFT fft;

float logo_aspect;

float sampleRate = 44100;
int bufferSize = 1024;

int minBin = 0;
int maxBin = bufferSize / 20;
int binCount = maxBin - minBin;

int activeViz;
boolean spreadMode;
boolean rotateMode;
boolean shouldDoLogo;

color baseColor;

float bass, mid, high, level;
double bass_avg, mid_avg, high_avg, level_avg;

void setup() {
  size(2160,1080,P3D);
  frameRate(30);
  colorMode(HSB, 100);

  activeViz = 0;
  spreadMode = false;
  rotateMode = false;

  baseColor = color(255);
  FIELDWIDTH = width;
  FIELDHEIGHT = height;

  // asset setup
  bg = loadImage("background.png");
  logo = loadImage("logo2018.png");
  logo_aspect = logo.height / logo.width;
  logo.resize(round(height / 4.0), round(logo_aspect * height / 4.0));
  logo_solid = loadImage("logo_solid.png");
  randomize();
  fx = new PostFX(this);
  fx.preload(BloomPass.class);
  initPanels();
  initSuperPanels();
  initVaporwave();
  initWarp();
  initField();

  // text setup
  msg = "";
  font = createFont("Nunito-Bold.ttf", 500, true);
  textFont(font, 50);
  textMode(MODEL);  // faster, but looks like trash

  // perspective settings
  camera(width/2.0, height/2.0, 1000, width/2.0, height/2.0, 0, 0, 1, 0);  //need fixed Z to avoid camera clip

  // audio setup
  minim = new Minim(this);
  audioInput = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new FFT(audioInput.bufferSize(), audioInput.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(22, 7);
}

void draw() {
  // background
  background(0, 0, 20);
  //image(bg,0,0);

  // framerate display (debug)
  /*fill(0);
   text(frameRate,0,0);*/

  // audio handling
  fft.forward(audioInput.mix);
  bass = fft.calcAvg(0, 400);
  mid = fft.calcAvg(400, 4000)*8;
  high = fft.calcAvg(2000, 20000)*8;
  level = audioInput.mix.level();
  
  // update (running, weighted) averages
  bass_avg = ((bass_avg*(frameCount -1) + bass) / frameCount);
  mid_avg = ((mid_avg*(frameCount -1) + mid) / frameCount);
  high_avg = ((high_avg*(frameCount -1) + high) / frameCount);
  level_avg = ((level_avg*(frameCount -1) + level) / frameCount);

  // base color mixing
  baseColor = color(frameCount / 25.0 % 100, 80, 90);
  
  // default camera
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);

  // select visualizer display
  shouldDoLogo = true;
  switch (activeViz) {
    case 0:
      lights();
      directionalLight(hue(baseColor), 100, 80, 0, -1, 0);
      fieldOfCubes();
      break;
    case 1:
      noStroke();
      pushMatrix();
      translate((width- FIELDWIDTH)/2, (height- FIELDHEIGHT)/2);
      for (int i=0; i<numParticles; i++)
        particles[i].update();//render particles
      popMatrix();
      break;
    case 2:
      doPanels();
      break;
    case 3:
      doSuperPanels();
      break;
    case 4:
      doWarp();
      shouldDoLogo = false;
      break;
    case 5:
      doField();
      shouldDoLogo = false;
      break;
    case 6:
      pushMatrix();
      doVaporwave();
      shouldDoLogo = false;
      popMatrix();
      break;
  }
  // resets
  emissive(0,0,0);

  // fixed logo/text
  if (shouldDoLogo) {
    tint(hue(baseColor),100,100);
    pushMatrix();
    //translate(-150,height,0);
    //rotateZ(-PI/2);
    image(logo, 0, 0);
    popMatrix();
    noTint();
  }

  translate(width/2, height/2 + height / 15, 800);  // bring text in front of all 3D graphics
  scale(0.5);
  //fill(135,206,250);
  if (!shouldDoLogo)
    emissive(0,0,100);
  fill(0, 0, 100);
  textAlign(CENTER);
  text(msg, 0, 0);
  if (!shouldDoLogo)
    emissive(0,0,0);
  
  fx.render()
  .bloom(0.5,10,10)
  .compose();
}

void keyPressed() {
  if (key == DELETE) {
    msg = "";
  } else if (key == BACKSPACE) {
    if (msg.length() > 0)
      msg = msg.substring(0, msg.length() -1);
  } else if (key == ENTER || key == RETURN) {
    msg = msg + '\n';
  } else if (keyCode == LEFT || keyCode == RIGHT) {  // left/right to enable/disable cube rotate mode
    rotateMode = keyCode == RIGHT;
  } else if (keyCode == UP || keyCode == DOWN) {  // up/down to enable/disable cube spreading mode
    spreadMode = keyCode == UP;
  } else if (keyCode == TAB) {
    activeViz++;
    activeViz%=7;
  } else if (key > 31 && key < 256) // only allow valid ASCII printable keys
    msg = msg + key;
    
  println(keyCode);

  println("Message: " + msg);
}

void fieldOfCubes() {
  //strokeWeight(1.2);
  pushMatrix();
  translate(width/2 + width/10, height/2, 225 + 150 * sin(frameCount/100.0));
  rotateX(frameCount / 100.0);
  rotateZ(frameCount / 100.0);
  stroke(0);
  strokeWeight(1);
  for (int x = -250; x <= 250; x+=75) {  // 6x6x6 cube
    for (int y = -250; y <= 250; y+=75) {
      for (int z = -250; z <= 250; z+=75) {
        int avg = ((x+250) + (y+250) + (z+250))/3;
        fill (hue(baseColor)+avg/50,avg/5, avg/10 + 50);
        pushMatrix();
        if (spreadMode)
          translate(x * 2 + sin(frameCount / 100.0), y * 2 + sin(frameCount / 100.0), z * 2 + sin(frameCount / 100));
        else
          translate(x, y, z);
        if (rotateMode) {
          rotateY((frameCount + y)/ 1000.0);
          rotateZ((frameCount + x)/ 1000.0);
        }
        //scale(1 + 0.2 * sin(frameCount / 75.0));
        //int index = (x + 250) / 75 + 6 * (((y + 250) / 75) + 6 * (z + 250)/75);
        //scale(min(    (1 + fft.getBand(round(index * 1.5))) * 4,    10));
        int xn = (x + 250) / 75;
        int yn = (y + 250) / 75;
        int index = yn * 6 + xn ;// 30 ? yn * 6 + xn : 29;
        float scaleFactor = log(fft.getAvg(index) + 1);
        scaleFactor = min(scaleFactor * 6, 5.0);
        scale( scaleFactor + 5 );
        box(5);
        popMatrix();
      }
    }
  }
  popMatrix();
}

void drawAxes() {
  strokeWeight(10);

  // x axis
  stroke(255, 0, 0);  // red
  line(0, 0, 0, 100, 0, 0);

  // y axis
  stroke(0, 255, 0);  // green
  line(0, 0, 0, 0, 100, 0);

  // z axis
  stroke(0, 0, 255);  // blue
  line(0, 0, 0, 0, 0, 100);
}
