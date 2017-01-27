String msg;
PFont font;
PImage bg, logo;

float logo_aspect;

void setup() {
  fullScreen(P3D);
  
  // asset setup
  bg = loadImage("background.png");
  logo = loadImage("logo2017.png");
  logo_aspect = logo.height / logo.width;
  logo.resize(round(width * 0.3), round(logo_aspect * width * 0.3));
  
  // text setup
  msg = "";
  font = createFont("Calibri",16,true);
  textFont(font,12);
  textMode(SHAPE);
  
  // perspective settings
  camera(width/2.0, height/2.0, 1000, width/2.0, height/2.0, 0, 0, 1, 0);  //need fixed Z to avoid camera clip
}

void draw() {
  //background
  background(200);
  //image(bg,0,0);
  
  // 3D visualizer display
  lights();
  //camera(width/2.0 + sin(frameCount / 150.0) * 100, height/2.0 + (50 * sin(frameCount / 150.0)), width/2.0 + cos(frameCount / 150.0) * 100, width/2.0, height/2.0, 0, 0, 1, 0);
  fieldOfCubes();
  
  // fixed logo/text
  image(logo,0,0);
  translate(0,0,800);  // bring in front of all 3D graphics
  fill(255);
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
  pushMatrix();
  translate(width/2 + width/10,height/2,225 + 150 * sin(frameCount/150.0));
  rotateX(frameCount / 150.0);
  rotateZ(frameCount / 150.0);
  for (int x = -250; x <= 250; x+=50) {
    for (int y = -250; y <= 250; y+=50) {
      for (int z = -250; z <= 250; z+=50) {
        fill (255 - (x+250)/10,165 +(y+250)/30,(z+250)/50);
        pushMatrix();
        translate(x,y,z);
        scale(1 + 0.2 * sin(frameCount / 150.0));
        box(25);
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