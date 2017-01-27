import ddf.minim.analysis.FFT;
import ddf.minim.Minim;
import ddf.minim.AudioInput;
import processing.video.Capture;

String msg;
PFont font;
PImage bg, logo;

Minim minim;
AudioInput audioInput;
FFT fft;

float logo_aspect;

float sampleRate = 44100;
int bufferSize = 1024;

int minBin = 0;
int maxBin = bufferSize / 20;
int binCount = maxBin - minBin;

void setup() {
  fullScreen(P3D);
  frameRate(30);
  
  // asset setup
  bg = loadImage("background.png");
  logo = loadImage("logo2017.png");
  logo_aspect = logo.height / logo.width;
  logo.resize(round(height), round(logo_aspect * height));
  
  // text setup
  msg = "";
  font = createFont("Calibri",16,true);
  textFont(font,12);
  textMode(MODEL);
  
  // perspective settings
  camera(width/2.0, height/2.0, 1000, width/2.0, height/2.0, 0, 0, 1, 0);  //need fixed Z to avoid camera clip
  
  // audio setup
  minim = new Minim(this);
  audioInput = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  fft = new FFT(audioInput.bufferSize(), audioInput.sampleRate());
  fft.window(FFT.HAMMING);
  fft.logAverages(22, 7);
  println(fft.avgSize());
}

void draw() {
  // background
  background(200);
  //image(bg,0,0);
  
  // framerate display (debug)
  fill(0);
  text(frameRate,0,0);
  
  // audio handling
  fft.forward(audioInput.mix);
  
  // 3D visualizer display
  lights();
  directionalLight(255,127,80,0,-1,0);
  fieldOfCubes();
  
  // fixed logo/text
  pushMatrix();
  translate(-150,height,0);
  rotateZ(-PI/2);
  image(logo,0,0);
  popMatrix();
  translate(0,0,800);  // bring text in front of all 3D graphics
  fill(25);
  textAlign(CENTER);
  text(msg,width/2,height/2+height/10);
}

void keyPressed() {
  if (key == DELETE) {
    msg = "";
  } else if (key == BACKSPACE) {
    if (msg.length() > 0)
      msg = msg.substring(0, msg.length() -1);
  } else if (key == ENTER || key == RETURN) {
    msg = msg + '\n';
  } else {
    if (key > 31 && key < 256) // only allow valid ASCII printable keys
      msg = msg + key;
  }
  
  println("Message: " + msg);
}

void fieldOfCubes() {
  //strokeWeight(1.2);
  pushMatrix();
  translate(width/2 + width/10,height/2,225 + 150 * sin(frameCount/100.0));
  rotateX(frameCount / 100.0);
  rotateZ(frameCount / 100.0);
  stroke(0);
  strokeWeight(1);
  for (int x = -250; x <= 250; x+=75) {  // 6x6x6 cube
    for (int y = -250; y <= 250; y+=75) {
      for (int z = -250; z <= 250; z+=75) {
        fill (255 - (x+250)/10,165 +(y+250)/20,(z+250)/50);
        pushMatrix();
        translate(x * 2 + sin(frameCount / 100.0),y * 2 + sin(frameCount / 100.0),z * 2 + sin(frameCount / 100));
        rotateY((frameCount + y)/ 1000.0);
        rotateZ((frameCount + x)/ 1000.0);
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
  stroke(255,0,0);  // red
  line(0,0,0,100,0,0);
  
  // y axis
  stroke(0,255,0);  // green
  line(0,0,0,0,100,0);
  
  // z axis
  stroke(0,0,255);  // blue
  line(0,0,0,0,0,100);
}