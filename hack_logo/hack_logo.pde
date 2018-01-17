void setup() {
  size(1000,1000,P3D); 
}

void draw() {
  lights();
  clear();
  fill(200);
  noStroke();
  translate(500,500);
  //rotateX(mouseX * .01);
  //rotateY(mouseY * .01);
  scale(5);
  
  hackLogo();
  
}

void hackLogo() {
  frame();
  
  scale(1,1,4);

  // H
  pushMatrix();
  translate(15,10);
  scale(0.3);
  H();
  popMatrix();
  
  // A
  pushMatrix();
  translate(70,10);
  scale(0.3);
  A();
  popMatrix();
  
  translate(0,50);
  
  // H
  pushMatrix();
  translate(15,10);
  scale(0.3);
  H();
  popMatrix();
  
  // A
  pushMatrix();
  translate(70,10);
  scale(0.3);
  A();
  popMatrix();
}

void H() {
  pylon();
  translate(75,0);
  pylon();
  translate(0,50);
  rotateZ(radians(90));
  scale(1,0.75,1);
  pylon();
}

void A() {
  pushMatrix();
  rotateZ(radians(24));
  scale(1,1.1,1);
  pylon();
  popMatrix();
  
  pushMatrix();
  rotateZ(radians(-24));
  scale(1,1.1,1);
  pylon();
  popMatrix();
  
    pushMatrix();
    translate(-20,55);
  rotateZ(radians(-90));
  scale(1,0.46,1);
  pylon();
  popMatrix();
  /*
  translate(75,0);
  pylon();
  translate(0,50);
  rotateZ(radians(90));
  scale(1,0.75,1);
  pylon();*/
}

void frame() {
  pylon();
  
  pushMatrix();
  rotateZ( radians(-90) );
  pylon();
  popMatrix();
  
  pushMatrix();
  translate(100,100);
  rotateZ( radians(-180) );
  pylon();
  popMatrix();
  
  pushMatrix();
  translate(100,100);
  rotateZ( radians(-270) );
  pylon();
  popMatrix();
}

void pylon() { 
  beginShape(TRIANGLES);
  
  // front
  vertex(0,0,0);
  vertex(0,100,0);
  vertex(5,100,0);
  
  vertex(5,100,0);
  vertex(5,0,0);
  vertex(0,0,0);
  
  // back
  vertex(0,0,5);
  vertex(0,100,5);
  vertex(5,100,5);
  
  vertex(5,100,5);
  vertex(5,0,5);
  vertex(0,0,5);
  
  // left
  vertex(0,0,5);
  vertex(0,0,0);
  vertex(0,100,0);
  
  vertex(0,100,0);
  vertex(0,100,5);
  vertex(0,0,5);
  
  // right
  vertex(5,0,5);
  vertex(5,0,0);
  vertex(5,100,0);
  
  vertex(5,100,0);
  vertex(5,100,5);
  vertex(5,0,5);
  
  endShape();
}