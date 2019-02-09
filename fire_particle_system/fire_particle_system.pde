import peasy.*;


/*-------------------- GLOBAL VARIABLES --------------------*/
FireSystem fire;
PImage img;
float time, elapsedTime;

PeasyCam cam;


/*-------------------- SETUP --------------------*/
void setup() {
  size(960, 540, P3D);
  
  noStroke();
  img = loadImage("texture.png");
  img.resize(20, 0);
  
  fire = new FireSystem(width / 2.0, height - 50, 0.0, img);

  float eyeZ = (height/2.0) / tan(PI*30.0 / 180.0);
  float centerX = width/2.0;
  float centerY = height/2.0;

  cam = new PeasyCam(this, centerX, centerY, 0, eyeZ);
  
  hint(ENABLE_DEPTH_SORT);
  hint(DISABLE_DEPTH_TEST);

  time = millis();
}


/*-------------------- DRAW --------------------*/
void draw() {
  background(20);

  elapsedTime = millis() - time;
  time = millis();
  
  fire.run(elapsedTime/1000);
}


/*-------------------- PARTICLE CLASS --------------------*/
/* This class implements basic particle for use in particle system.
 * Particles have vectors for location, velocity, acceleration, and
 * attributes for color, lifespan, and the image used to draw them.
 */
class Particle {
  PVector location, velocity, acceleration;
  float red, green, blue;
  float lifeTime, timeLeft;
  boolean dead;
  PImage img;
  
  Particle(PImage image) {
    location = new PVector(0.0, 0.0, 0.0);
    velocity =  new PVector(0.0, 0.0, 0.0);
    acceleration = new PVector(0.0, 0.0, 0.0);
    lifeTime = timeLeft = 0;
    red = green = blue = 0;
    img = image;
  }
  
  void display() {
    pushMatrix();
    tint(red, green, blue, (timeLeft / lifeTime) * 255);
    translate(location.x, location.y, location.z);
    
    // Rotate so that particles face the camera
    float[] rota = cam.getRotations();
    rotateX(rota[0]);
    rotateY(rota[1]);
    rotateZ(rota[2]);
    
    // Use texture to draw particles
    image(img, 0, 0);

    popMatrix();
  }
  
  void update(float dt) {
    location.add(PVector.mult(velocity, dt));
    velocity.add(PVector.mult(acceleration, dt));
    
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


/*-------------------- FIRESYSTEM CLASS --------------------*/
/* Class for implementing a fire particle system using the
 * Particle class.
 */
class FireSystem {
  PVector location;
  ArrayList<Particle> particles;
  PImage img;
  int spawnRate;
  float lowerLife, upperLife;
  float fireRadius;
  float upVel;
  float sideVel;
  float upAcc;
  float gustLow, gustHigh;
  
  FireSystem(float x, float y, float z, PImage image) {
    location = new PVector(x, y, z);
    particles = new ArrayList<Particle>();
    img = image;
    spawnRate = 5000;
    lowerLife = 1.0;
    upperLife = 4.0;
    fireRadius = 50;
    upVel = 20;
    sideVel = 60;
    upAcc = -100;
    gustLow = 10;
    gustHigh = 20;
  }
  
  void run(float dt) {
    float distX, distZ;
    float gust;
    // Loop over all particles and update them accordingly
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      // Decrease green content so fire reddens with time
      p.green = pow((p.timeLeft / p.lifeTime), 0.8) * 255;
      // Particles acceleration scales with age and distance to create plum
      distX = p.location.x - location.x;
      distZ = p.location.z - location.z;
      p.acceleration.x = ((p.lifeTime - p.timeLeft) / p.lifeTime) * -2*distX;
      p.acceleration.z = ((p.lifeTime - p.timeLeft) / p.lifeTime) * -2*distZ;
      
      // Random "gusts" of wind to add noise to top of fire.
      gust = random(0, 1);
      if (gust < 0.01) {
        p.velocity.x += ((p.lifeTime - p.timeLeft) / p.timeLeft) * random(gustLow, gustHigh);
      } else if (gust < 0.02) {
        p.velocity.x -= ((p.lifeTime - p.timeLeft) / p.timeLeft) * random(gustLow, gustHigh);
      } else if (gust < 0.03) {
        p.velocity.z += ((p.lifeTime - p.timeLeft) / p.timeLeft) * random(gustLow, gustHigh);
      } else if (gust < 0.04) {
        p.velocity.z -= ((p.lifeTime - p.timeLeft) / p.timeLeft) * random(gustLow, gustHigh);
      }
      p.run(dt);
      if (p.dead) {
        particles.remove(i);
      }
    }
    // Particles added according to spawn rate
    for (int i = 0; i < spawnRate*dt; i++) {
      addParticle();
    }
  }
  
  void addParticle() {
    Particle p = new Particle(img);
    p.location.x = random(0, fireRadius) * cos(random(0, 360)) + location.x;
    p.location.z = random(0, fireRadius) * sin(random(0, 360)) + location.z;
    p.location.y = location.y;
    float ang = random(0, 360);
    p.velocity = new PVector(sideVel*cos(ang), random(-upVel, 0), sideVel*sin(ang));
    p.acceleration = new PVector(0, upAcc, 0);
    p.lifeTime = p.timeLeft = random(lowerLife, upperLife);
    p.red = random(200, 255);
    p.green = random(200, 255);
    
    particles.add(p);
  }
}


/*-------------------- HELPERS --------------------*/
/* Function to show the frames per second and number of
 * particles of the system.
 */
void mousePressed() {
  println("Frames " + frameCount / (millis() / 1000.0));
  println("Particles " + fire.particles.size());
}
