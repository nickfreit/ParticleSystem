import peasy.*;


/*-------------------- GLOBAL VARIABLES --------------------*/
MagicSystem magic;
EvilMagicSystem evil;
PImage img;
float time, elapsedTime;
int sRadius;
boolean gameOver;
float contactPoint;

PeasyCam cam;


/*-------------------- SETUP --------------------*/
void setup() {
  size(1440, 810, P3D);
  
  contactPoint = width/2;
  
  noStroke();
  img = loadImage("texture.png");
  img.resize(5, 0);
  magic = new MagicSystem(375, height/2, 0.0, img);
  evil = new EvilMagicSystem(width-375, height/2, 0.0, img);

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
  background(120);
  // Check if either player has moved past others start
  if (contactPoint < 375) {
    textSize(72);
    textAlign(CENTER);
    fill(20, 80, 20);
    text("VOLDEMORT WINS", width/2, height/2-100);
    gameOver = true;
  } else if (contactPoint > width - 375) {
    textSize(72);
    textAlign(CENTER);
    fill(200, 200, 10);
    text("HARRY WINS", width/2, height/2-100);
    gameOver = true;
  }
  
  elapsedTime = millis() - time;
  time = millis();
  
  evil.run(elapsedTime/1000);
  magic.run(elapsedTime/1000);
}


/*-------------------- PARTICLE CLASS --------------------*/
/* Class for simulating a water particle.
 * Class has attributes for location, velocity, acceleration
 * color, lifespan, and the image used to render it
 */
class Particle {
  PVector location, velocity, acceleration;
  float red, green, blue;
  float lifeTime, timeLeft;
  boolean dead;
  PImage img;
  boolean bounced;
  
  Particle(PImage image) {
    location = new PVector(0.0, 0.0, 0.0);
    velocity =  new PVector(0.0, 0.0, 0.0);
    acceleration = new PVector(0.0, 0.0, 0.0);
    lifeTime = timeLeft = 0;
    red = green = blue = 0;
    img = image;
    dead = bounced = false;
  }
  
  void display() {
    imageMode(CENTER);
    pushMatrix();
    tint(red, green, blue);
    translate(location.x, location.y, location.z);
    float[] rota = cam.getRotations();
    rotateX(rota[0]);
    rotateY(rota[1]);
    rotateZ(rota[2]);
    image(img, 0, 0);
    popMatrix();
  }
  
  void update(float dt) {
    location.add(PVector.mult(velocity, dt));
    velocity.add(PVector.mult(acceleration, dt));
  
    // Check if a particle has hit the center point, bounce it if so
    if ((velocity.x > 0 && location.x > contactPoint) && !bounced) {
      velocity.set(-random(150, 250), random(-300, 300), random(-300, 300));
      bounced = true;
    } else if ((velocity.x < 0 && location.x < contactPoint) && !bounced) {
      velocity.set(random(150, 250), random(-300, 300), random(-300, 300));
      bounced = true;
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


/*-------------------- MAGICSYSTEM CLASS --------------------*/
/* Class for representing the good guy magic composed of particles
 * has an arraylist of particles
 */
class MagicSystem {
  PVector location;
  ArrayList<Particle> particles;
  PImage img;
  
  MagicSystem(float x, float y, float z, PImage image) {
    location = new PVector(x, y, z);
    particles = new ArrayList<Particle>();
    img = image;
  }
  
  void run(float dt) {
    float distY, distZ;
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      // scale acceleration with distance from center to create harmonic motion
      distY = p.location.y - location.y;
      distZ = p.location.z - location.z;
      p.acceleration.y = -7*distY;
      p.acceleration.z = -7*distZ;
      p.run(dt);
      if (p.dead) {
        particles.remove(i);
      }
    }
    
    for (int i = 0; i < 1000*dt; i++) {
      addParticle();
    }
  }
  
    // Randomly use different starting params to create different parts of magic stream  
    void addParticle() {
    Particle p = new Particle(img);
    p.location.x =  location.x;
    float radius = 5;
    float rand = random(0,1);
    if (rand < 0.6) {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y;
      p.velocity = new PVector(random(150, 170), 0, 0);
      p.acceleration = new PVector(20, 0, 0);
      p.lifeTime = p.timeLeft = random(4.0, 5.0);
      p.green = random(100, 255);
      p.blue = random(100, 255);
    } else if (rand < 0.8) {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z -radius;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y -radius;
      p.velocity = new PVector(random(100, 120), -40, 40);
      p.acceleration = new PVector(0, 0, 0);
      p.lifeTime = p.timeLeft = random(6.0, 8.0);
      p.red = random(200, 255);
      p.blue = 0.5 * p.red;
    } else {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z + radius;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y +radius ;
      p.velocity = new PVector(random(100, 120), -40, 40);
      p.acceleration = new PVector(0, 0, 0);
      p.lifeTime = p.timeLeft = random(6.0, 8.0);
      p.red = random(200, 255);
      p.blue = 1.5 *  p.red;
    }
    particles.add(p);
  }
}


/*-------------------- EVILMAGICSYSTEM CLASS --------------------*/
/* Class for representing the bad guy magic composed of particles
 * has an arraylist of particles
 */
class EvilMagicSystem {
    PVector location;
  ArrayList<Particle> particles;
  PImage img;
  
  EvilMagicSystem(float x, float y, float z, PImage image) {
    location = new PVector(x, y, z);
    particles = new ArrayList<Particle>();
    img = image;
  }
  
  void run(float dt) {
    float distY, distZ;
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      // scale acceleration with distance from center to create harmonic motion
      distY = p.location.y - location.y;
      distZ = p.location.z - location.z;
      p.acceleration.y = -7*distY;
      p.acceleration.z = -7*distZ;
      p.run(dt);
      if (p.dead) {
        particles.remove(i);
      }
    }
    
    for (int i = 0; i < 1000*dt; i++) {
      addParticle();
    }
  }
  
  void addParticle() {
    Particle p = new Particle(img);
    p.location.x =  location.x;
    float radius = 5;
    float rand = random(0,1);
    // Randomly use different starting params to create different parts of magic stream
    if (rand < 0.6) {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y;
      p.velocity = new PVector(random(-150, -170), 0, 0);
      p.acceleration = new PVector(-20, 0, 0);
      p.lifeTime = p.timeLeft = random(4.0, 5.0);
    } else if (rand < 0.8) {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z -radius;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y -radius;
      p.velocity = new PVector(random(-100, -120), -40, 40);
      p.acceleration = new PVector(0, 0, 0);
      p.lifeTime = p.timeLeft = random(6.0, 8.0);
      p.red = random(0, 40);
      p.blue = random(0, 40);
      p.green = random(60, 100);
    } else {
      p.location.z = random(0, radius) * cos(random(0, 360)) + location.z + radius;
      p.location.y = random(0, radius) * sin(random(0, 360)) + location.y +radius ;
      p.velocity = new PVector(random(-100, -120), -40, 40);
      p.acceleration = new PVector(0, 0, 0);
      p.lifeTime = p.timeLeft = random(6.0, 8.0);
      p.red = random(60, 90);
      p.blue = random(50, 80);
    }
    particles.add(p);
  }
}


/*-------------------- HELPER FUNCTIONS --------------------*/
/* Press h to move the magic for the good guy, v for the bad guy
 */
void keyPressed() {
  if (key == 'h' && !gameOver) {
    contactPoint += 10;
  } else if (key == 'v' && !gameOver) {
    contactPoint -= 10;
  }
}

/* Gives the current frames per second and number of particles when
 * mouse is pressed
 */
void mousePressed() {
  println("Frames " + frameCount / (millis() / 1000.0));
  println("Particles " + magic.particles.size());
}
