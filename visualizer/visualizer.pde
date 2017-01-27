String msg;

void setup() {
  msg = "";
  size(500,500);
}

void draw() {
  rect(50,50,1,1);
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
      msg = msg + (char)key;
  }
  
  println("Message: " + msg);
}