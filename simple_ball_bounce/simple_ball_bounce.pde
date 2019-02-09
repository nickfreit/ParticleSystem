/* Code to make a ball bounce in a 3D cube. 
Click the mouse to make the ball start bouncing around. */

Ball b;
float time;
float timeElapsed;
boolean displayBall = false;

void setup() {
  size(800, 800, P3D);
  b = new Ball();
  b.radius = 12;
  b.location.set(width/2, height/2, 0);
  b.velocity.set(random(-200, 200), random(500, 600), random(-200, 200));
  b.acceleration.set(0, 2000, 0);
  
  camera(width/5, height/5, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  
  time = millis();
}

void draw() {
  background(255);
  lights();
  
  timeElapsed = millis() - time;
  time = millis();
  
  if (displayBall) {
    b.update(timeElapsed/1000.0);
    b.display();
  }
  
  pushMatrix();
  translate(width/2, height/2, 0);
  fill(50, 50);
  stroke(0);
  strokeWeight(5);
  box(200, 200, 200);
  popMatrix();
  if (mousePressed) {
    displayBall = true;
  }

}

class Ball {
  PVector location, velocity, acceleration;
  float radius;
  
  Ball() {
    location = new PVector(0.0, 0.0, 0.0);
    velocity = new PVector(0.0, 0.0, 0.0);
    acceleration = new PVector(0.0, 0.0, 0.0);
    radius = 0;
  }
  
  void display() {
    fill(100, 100, 200);
    noStroke();
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(radius);
    popMatrix();
  }
  
  void update(float dt) {
    velocity.add(PVector.mult(acceleration, dt));
    location.add(PVector.mult(velocity, dt));
    if (location.y + radius > 500) {
      velocity.y *= -.95;
      location.y = 500 - radius;
    }
    if (location.y - radius < 300) {
      velocity.y *= -.95;
      location.y = 300 + radius;
    }
    if (location.x + radius > 500) {
      velocity.x *= -.95;
      location.x = 500 - radius;
    }
    if (location.x - radius < 300) {
      velocity.x *= -.95;
      location.x = 300 + radius;
    }
    if (location.z + radius > 100) {
      velocity.z *= -.95;
      location.z = 100 - radius;
    }
    if (location.z - radius < -100) {
      velocity.z *= -.95;
      location.z = -100 + radius;
    }
    if (location.y + radius >= 498 && abs(velocity.y) < 50) {
      velocity.z *= 0.995;
      velocity.x *= 0.995;
    }
  }
}
