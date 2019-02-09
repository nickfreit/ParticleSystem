import peasy.*;


/*-------------------- GLOBAL VARIABLES --------------------*/
WaterSystem water;
PImage img;
float time, elapsedTime;
float sRadius = 40;
PVector sLocation = new PVector(width/2, height/2, 0);
float topSideLength = 20;
float topHeight = 100;
float scale = 10;

PeasyCam cam;


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
  
  hint(ENABLE_DEPTH_SORT);
  //hint(DISABLE_DEPTH_TEST);

  time = millis();
}


/*-------------------- DRAW --------------------*/
void draw() {
  background(100);
  
  // Draw the sphere at the x,y location of the mouse
  pushMatrix();
  if (mouseX > 0 && mouseY > 0) {

    sLocation.x = mouseX;
    sLocation.y = mouseY;
  } else {
    sLocation.x = width/2;
    sLocation.y = height/2;
  }

  translate(sLocation.x, sLocation.y, sLocation.z);
  noFill();
  stroke(0);
  sphere(sRadius);
  popMatrix();
  
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
    // Check if colliding with the sphere
    if (dist(location.x, location.y, location.z, sLocation.x, sLocation.y, sLocation.z) < sRadius) {
      PVector norm = new PVector(location.x-sLocation.x, location.y-sLocation.y, location.z-sLocation.z);
      norm.normalize();
      float dot = velocity.dot(norm);
      velocity.sub(PVector.mult(norm, 1.2 * dot));
      location.set(PVector.add(sLocation, PVector.mult(norm, sRadius)));
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
  float spawnRate;
  float sideVel;
  float lifeMin, lifeMax;
  float upAcc;
  boolean renderImg;
  
  WaterSystem(float x, float y, float z, PImage image) {
    location = new PVector(x, y, z);
    particles = new ArrayList<Particle>();
    img = image;
    spawnRate = 1500;
    sideVel = 20;
    lifeMin = 8;
    lifeMax = 12;
    upAcc = 200;
    renderImg = false;
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
    p.location.x = sideVel * sin(ang) + location.x;
    p.location.z =  sideVel * cos(ang) + location.z;
    p.location.y = location.y;
    p.velocity = new PVector(0, random(-10, 10), 0);
    p.acceleration = new PVector(0,  upAcc, 0);
    p.lifeTime = p.timeLeft = random(lifeMin, lifeMax);
    p.blue = random(200, 255);
    p.green = random(0, 100);
    particles.add(p);
  }
}


/*-------------------- HELPER FUNCTIONS --------------------*/
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
