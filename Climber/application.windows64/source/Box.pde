// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// A rectangular box

class Box {

  // We need to keep track of a Body and a width and height
  Body body;
  float w;
  float h;

  color col, defaultColor;

  boolean selected = false;
  boolean fixed = false;

  RevoluteJoint tempJoint = null;  // connection of particle to hold


  // Constructor
  Box(float x, float y, float w_, float h_, boolean lock, color c) {
    w = w_;
    h = h_;

    // Define and create the body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    if (lock) bd.type = BodyType.STATIC;
    else bd.type = BodyType.DYNAMIC;
//    bd.bullet = true;
    bd.angularDamping = 10.0;

    body = box2d.createBody(bd);

    // Define the shape -- a  (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 10.0;
    //    fd.density = 0.0;
    fd.friction = 1;
    fd.restitution = 0;

    body.createFixture(fd);

    // Give it some initial random velocity
    //    body.setLinearVelocity(new Vec2(random(-5,5),random(2,5)));
    //   body.setAngularVelocity(random(-5,5));

    col = c;
    defaultColor = c;
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    
    if (selected) col = color(255, 0, 0);
    else col = defaultColor;

    rectMode(PConstants.CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(col);
    stroke(col);
    rect(0, 0, w, h);
    popMatrix();
  }
}

