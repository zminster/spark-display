String msg;
PFont font;

void setup() {
  msg = "";
  size(500,500);
  font = createFont("Calibri",16,true);
  textFont(font,36);
}

void draw() {
  background(65);
  fill(255);
  textAlign(CENTER);
  text(msg,width/2,height-100);
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