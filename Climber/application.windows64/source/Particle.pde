// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A circular particle

class Particle {

  // We need to keep track of a Body and a radius
  Body body;
  float r;

  color col, defaultColor;

  boolean selected = false;
  boolean fixed = false;

  float mass;

  RevoluteJoint tempJoint = null;  // connection of particle to hold

  // location x, y, radius, and type ("STATIC", "DYNAMIC", "KINEMATIC")
  Particle(float x, float y, float r_, String type, color c) {
    r = r_;
    // This function puts the particle in the Box2d world
    makeBody(x, y, r, type);
    body.setUserData(this);

    col = c;
    defaultColor = c;
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Change color when hit
  void change() {
    col = color(255, 0, 0);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+r*2) {
      killBody();
      return true;
    }
    return false;
  }

  // 
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);

    rotate(-a);

    if (selected) col = color(255, 0, 0);
    else col = defaultColor;

    fill(col);
    stroke(0);

    strokeWeight(1);
    ellipse(0, 0, r*2, r*2);
    // Let's add a line so we can see the rotation
    //line(0, 0, r, 0);
    popMatrix();
  }

  // Here's our function that adds the particle to the Box2D world
  void makeBody(float x, float y, float r, String type) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);

    if (type == "STATIC") {
      bd.type = BodyType.STATIC;
    } else if (type == "DYNAMIC") {
      bd.type = BodyType.DYNAMIC;
    } else if (type == "KINEMATIC") {
      bd.type = BodyType.KINEMATIC;
    }


    body = box2d.world.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;

    fd.density = 30.0;
    //    fd.friction = 0.01;
    fd.friction = 1.0;
    fd.restitution = 0; // Restitution is bounciness

    body.createFixture(fd);

    mass = body.getMass();
    // Give it a random initial velocity (and angular velocity)
    //body.setLinearVelocity(new Vec2(random(-10f,10f),random(5f,10f)));
    // body.setAngularVelocity(random(-10, 10));
  }
}

