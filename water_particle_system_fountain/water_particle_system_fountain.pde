import peasy.*;


/*-------------------- GLOBAL VARIABLES --------------------*/
WaterSystem water;
PImage img;
float time, elapsedTime;
float bounceFactor = 0.2;
float bounceBuffer = 3;
PeasyCam cam;

// Fountain parameters
float fountainX;
float fountainY;

float pillarSideLength = 20;
float upperPillarHeight = 100;
float lowerPillarHeight = 200;

float upperPlateHeight = 10;
float upperPlateSide = 200;

float lowerPlateHeight = 20;
float lowerPlateSide = 400;


/*-------------------- SETUP --------------------*/
void setup() {
  size(960, 540, P3D);
  
  noStroke();
  img = loadImage("texture.png");
  img.resize(10, 0);
  water = new WaterSystem(width/2, height/4, 0.0, img);

  float eyeZ = (height/2.0) / tan(PI*30.0 / 180.0);
  float centerX = width/2.0;
  float centerY = height/2.0;
  cam = new PeasyCam(this, centerX, centerY, 0, eyeZ);
  
  fountainX = width/2;
  fountainY = height/4;
  
  hint(ENABLE_DEPTH_SORT);
  //hint(DISABLE_DEPTH_TEST);

  time = millis();
}


/*-------------------- DRAW --------------------*/
void draw() {
  background(100);
  
  drawFountain(fountainX, fountainY, 0);
  
  elapsedTime = millis() - time;
  time = millis();  
  water.run(elapsedTime/1000);
}




/*-------------------- PARTICLE CLASS --------------------*/
/* Class for simulating a water particle.
 * Class has attributes for location, velocity, acceleration
 * color, lifespan, and the image used to render it (if image
 * rendering mode is used)
 */
class Particle {
  PVector location, velocity, acceleration;
  float red, green, blue;
  float lifeTime, timeLeft;
  boolean dead;
  PImage img;
  boolean renderImg;
  
  Particle(PImage image) {
    location = new PVector(0.0, 0.0, 0.0);
    velocity =  new PVector(0.0, 0.0, 0.0);
    acceleration = new PVector(0.0, 0.0, 0.0);
    lifeTime = timeLeft = 0;
    red = green = blue = 0;
    img = image;
    renderImg = false;
  }
  
  void display() {
    imageMode(CENTER);
    pushMatrix();
    tint(red, green, blue, 200);
    translate(location.x, location.y, location.z);
    float[] rota = cam.getRotations();
    rotateX(rota[0]);
    rotateY(rota[1]);
    rotateZ(rota[2]);
    if (renderImg) {
      image(img, 0, 0);
    } else {
      stroke(red, green, blue, 255/2);
      strokeWeight(4);
      point(0,0);
    }    
    popMatrix();
  }
  
  void update(float dt) {
    location.add(PVector.mult(velocity, dt));
    velocity.add(PVector.mult(acceleration, dt));
    
    // Check if particle is colliding with any part of the upper portion of the fountain
    if (
    (location.z < upperPlateSide*sqrt(3)/2 && 
    location.z > -upperPlateSide*sqrt(3)/2 &&
    location.x < upperPlateSide/2+fountainX && 
    location.x > -upperPlateSide/2+fountainX && 
    location.y > fountainY + upperPillarHeight - bounceBuffer)
    ||
    (location.x < upperPlateSide + fountainX && 
    location.x > upperPlateSide/2 + fountainX &&
    location.z > (location.x-fountainX) * sqrt(3) - upperPlateSide*sqrt(3) && 
    location.z < (location.x-fountainX) * -sqrt(3) + upperPlateSide*sqrt(3) &&
    location.y > fountainY + upperPillarHeight - bounceBuffer) 
    ||
    (location.x > -upperPlateSide+fountainX && 
    location.x < -upperPlateSide/2+fountainX &&
    location.z < (location.x-fountainX) * sqrt(3) + upperPlateSide*sqrt(3) && 
    location.z > (location.x-fountainX) * -sqrt(3) - upperPlateSide*sqrt(3) &&
    location.y > fountainY + upperPillarHeight - bounceBuffer)) {
      velocity.y *= -bounceFactor;
      location.y = fountainY + upperPillarHeight - bounceBuffer - 1;
    }
    
    // Check if the particle is colliding with any part of the bottom portion of the fountain
    if (
    (location.z < lowerPlateSide*sqrt(3)/2 && 
    location.z > -lowerPlateSide*sqrt(3)/2 &&
    location.x < lowerPlateSide/2+fountainX && 
    location.x > -lowerPlateSide/2+fountainX && 
    location.y > fountainY + lowerPillarHeight + upperPillarHeight - bounceBuffer + upperPlateHeight)
    ||    
    (location.x < lowerPlateSide+fountainX && 
    location.x > lowerPlateSide/2+fountainX &&
    location.z > (location.x-fountainX) * sqrt(3) - lowerPlateSide*sqrt(3) && 
    location.z < (location.x-fountainX) * -sqrt(3) + lowerPlateSide*sqrt(3) &&
    location.y > fountainY + lowerPillarHeight + upperPillarHeight - bounceBuffer + upperPlateHeight)
    ||
    (location.x > -lowerPlateSide+fountainX && 
    location.x < -lowerPlateSide/2+fountainX &&
    location.z < (location.x-fountainX) * sqrt(3) + lowerPlateSide*sqrt(3) && 
    location.z > (location.x-fountainX) * -sqrt(3) - lowerPlateSide*sqrt(3) &&
    location.y > fountainY + lowerPillarHeight + upperPillarHeight - bounceBuffer + upperPlateHeight)){
      velocity.y *= -bounceFactor;
      location.y = fountainY + upperPillarHeight + lowerPillarHeight - bounceBuffer - 1;
    }
    
    timeLeft -= dt;
    if (timeLeft <= 0) {
      dead = true;
    }
  }
  
  void run(float dt) {  
    display();
    update(dt);
  }
}


/*-------------------- WATERSYSTEM CLASS --------------------*/
/* Class for representing the water system which is composed of particles.
 * System has a location and an ArrayList of particles that it uses.
 */
class WaterSystem {
  PVector location;
  ArrayList<Particle> particles;
  PImage img;
  int spawnRate = 1500;
  float spawnRadius = 20;
  float spawnSpeed = 40;
  float speedUpMax = 300;
  float speedUpMin = 200;
  float accUp = 200;
  float lifeMin = 8;
  float lifeMax = 12;
  boolean renderImg = false;
  
  WaterSystem(float x, float y, float z, PImage image) {
    location = new PVector(x, y, z);
    particles = new ArrayList<Particle>();
    img = image;
  }
  
  void run(float dt) {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      if (renderImg) {
        p.renderImg = true;
      }
      p.run(dt);
      if (p.dead) {
        particles.remove(i);
      }
    }
    for (int i = 0; i < spawnRate*dt; i++) {
      addParticle();
    }
  }
  
  void addParticle() {
    Particle p = new Particle(img);
    float ang = random(0, 360);
    p.location.x = spawnRadius * sin(ang) + location.x;
    p.location.z =  spawnRadius * cos(ang) + location.z;
    p.location.y = location.y;
    p.velocity = new PVector(spawnSpeed*sin(ang), -random(speedUpMin, speedUpMax), spawnSpeed*cos(ang));
    p.acceleration = new PVector(0,  accUp, 0);
    p.lifeTime = p.timeLeft = random(lifeMin, lifeMax);
    p.blue = random(200, 255);
    p.green = random(0, 100);
    
    particles.add(p);
  }
}


/*-------------------- HELPER FUNCTIONS --------------------*/
/* Function to draw a hexagonal prism with top center at (x, y, z)
 * and height h, side length s
 */
void drawHexPrism(float x, float y, float z, float h, float s) {
  pushMatrix();
  
  stroke(0);
  strokeWeight(1);
  translate(x, y, z);
  
  pushMatrix();
  translate(0, 0, s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  pushMatrix();
  translate(0, 0, -s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  pushMatrix();
  rotateY(PI/3);
  translate(0, 0, -s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  pushMatrix();
  rotateY(2*PI/3);
  translate(0, 0, -s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  pushMatrix();
  rotateY(-PI/3);
  translate(0, 0, -s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  pushMatrix();
  rotateY(-2*PI/3);
  translate(0, 0, -s*sqrt(3)/2);
  quad(s/2, 0, -s/2, 0, -s/2, h, s/2, h);
  popMatrix();
  
  popMatrix();
}

/* Draws hexagon at position x, y, z, with side length s
 */
void drawHex(float x, float y, float z, float s) {
  pushMatrix();
  translate(x, y, z);
  rotateX(PI/2);
  noStroke();
  quad(s/2, s*sqrt(3)/2, -s/2, s*sqrt(3)/2, -s, 0, -s/2, -s*sqrt(3)/2);
  quad(-s/2, -s*sqrt(3)/2, s/2, -s*sqrt(3)/2, s, 0, s/2, s*sqrt(3)/2);
  popMatrix();
}

/* Draw a fountain with top at (x, y, z)
 */
void drawFountain(float x, float y, float z) {

  fill(143, 188, 143);
  
  drawHexPrism(x, y, z, upperPillarHeight, pillarSideLength);
  drawHexPrism(x, y + upperPillarHeight, z, upperPlateHeight, upperPlateSide);
  drawHexPrism(x, y + upperPillarHeight + upperPlateHeight, z, lowerPillarHeight, pillarSideLength); 
  drawHexPrism(x, y + upperPillarHeight + upperPlateHeight + lowerPillarHeight, z, lowerPlateHeight, lowerPlateSide);
  
  drawHex(x, y + upperPillarHeight, z, upperPlateSide);
  drawHex(x, y + upperPillarHeight + upperPlateHeight, z, upperPlateSide);
  
  drawHex(x, y + upperPillarHeight + upperPlateHeight + lowerPillarHeight, z, lowerPlateSide);
  drawHex(x, y + upperPillarHeight + upperPlateHeight + lowerPillarHeight + lowerPlateHeight, z, lowerPlateSide);
}

/* Gives the current frames per second and number of particles when
 * mouse is pressed
 */
void mousePressed() {
  println("Frames " + frameCount / (millis() / 1000.0));
  println("Particles " + water.particles.size());
}

/* Flips the rendering mode to use the texture
 */
void keyPressed() {
  if (key == 'm') {
    water.renderImg = !water.renderImg;
  }
}
