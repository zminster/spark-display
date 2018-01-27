// Noise Field
// Particle trails via Perlin noise. 
// Move mouse to change particle motion. 
// Click to randomize parameters.
// Built with Processing.js (processingjs.org)
// by Felix Turner (airtightinteractive.com)
// modified into a music visualizer by Sebastian Cave

int numParticles;
float fadeAmount;
float maxLen = 100;
float strokeAmount;

Particle[] particles;
int FIELDWIDTH;
int FIELDHEIGHT;

void randomize() {
  numParticles = int(1000);
  fadeAmount = random(.5, 20);
  maxLen = random(30, 200);
  strokeAmount = random(0.02, 0.3);

  particles = new Particle[numParticles];
  for (int i=0; i<numParticles; i++) {
    particles[i]=new Particle(i/5000.0);
  }
}

void mouseClicked() {
  randomize();
}

class Particle {
  float id, x, y, xp, yp, s, d, sColor, len, z, zp;

  Particle(float _id) {
    id=_id;
    init();
  }

  void init() {
    x=xp=random(0, FIELDWIDTH);
    y=yp=random(0, FIELDHEIGHT);
    z=zp=0;
    s=random(2, 7);
    sColor = map(x, 0, FIELDWIDTH, 0, 100);
    len = random(1, maxLen-1);
  }

  void update() {

    float bass = fft.calcAvg(0, 400);
    float mid = fft.calcAvg(400, 4000)*8;
    float high = fft.calcAvg(4000, 20000)*8;

    id+=0.01;

    if (bass == 0|| mid == 0) {
      bass = 1;
      mid = 1;
    }

    d=(noise(id, x/high, y/mid)-0.5)*80*bass;  

    println(d);

    x+=cos(radians(d))*s;
    y+=sin(radians(d))*s;

    fill(sColor, 80, 90);
    ellipse(xp, yp, (maxLen - len)*strokeAmount*(bass/12)*3, (maxLen - len)*strokeAmount*(bass/12)*3);
    xp=x;
    yp=y;
    len++;
    if (len >= maxLen) init();
  }
}