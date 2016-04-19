import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import shiffman.box2d.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.joints.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.collision.shapes.Shape; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.contacts.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Climber_Galen_use_Distance_Joints extends PApplet {

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// Example demonstrating distance joints 
// A climber is formed by connected a series of particles with joints










// A reference to our box2d world
Box2DProcessing box2d;

// An object to describe a Climber (a list of particles with joint connections)
Climber climber;

// the floor
Boundary boundary;

// the climbing holds
//ArrayList<Particle> holds;
ArrayList<Hold> holds;

// spring to move effectors
Spring spring;

// the climber's status in a panel
StatusPanel statusPanel;

Box containingEndEffector;

int gripDistanceThreshold = 1;



public void setup() {
  size(700, 700);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  // a floor
  boundary = new Boundary(0, height, width * 2, 10, 0);

  // Make the climber
  climber = new Climber(width/2, height - 120);

  // Create the empty list of holds
  //  holds = new ArrayList<Particle>();
  holds = new ArrayList<Hold>();

  // place some holds on the wall randomly
  int numberOfHolds = PApplet.parseInt(random(40, 60));
  for (int i = 0; i < numberOfHolds; i++) {
    int holdColor = color(random(255), random(255), random(255));
    //    holds.add(new Particle(random(width-150), random(height), random(2, 7), "KINEMATIC", holdColor));
    holds.add(new Hold(random(width-150), random(height), random(20, 25), random(10, 20), true, holdColor));

    // holds.get(i).body.setLinearVelocity(new Vec2(0,-3));
  }
  /*
  // place the climber's hands on two holds
   Vec2 hold1Pos = climber.lHand.body.getWorldCenter();
   color holdColor = color(random(255), random(255), random(255));
   holds.add(new Hold(hold1Pos.x, hold1Pos.y, random(10, 15), random(1, 4), true, holdColor));
   
   Vec2 hold2Pos = climber.rHand.body.getWorldCenter();
   holdColor = color(random(255), random(255), random(255));
   holds.add(new Hold(hold2Pos.x, hold2Pos.y, random(10, 15), random(1, 4), true, holdColor));
   */

  // Make the spring (it doesn't really get initialized until the mouse is clicked)
  spring = new Spring();

  statusPanel = new StatusPanel(width - 80, 120, 100, 200);
}

public void draw() {
  background(255);

  // We must always step through time!
  box2d.step();

  // Always alert the spring to the new mouse location
  spring.update(mouseX, mouseY);
  
  // Look at all holds
  for (int i = 0; i < holds.size (); i++) {
    //    Particle p = holds.get(i);
    Hold p = holds.get(i);
    p.display();

    /*
    if (p.done()) {
     holds.remove(i);
     }
     */
  }

  // Draw the climber
  climber.display();


  // Draw the spring (it only appears when active)
  spring.display();

  boundary.display();

  statusPanel.display(10, 10, 10, 10, 10);
}

// rest when key pressed
public void keyPressed() {
  //  climber.rest = true;

  if (key == 'd')
    climber.leanRight = true;
  else if (key == 'a')
    climber.leanLeft = true;
}


// rest when key pressed
public void keyReleased() {
//  climber.rest = false;
  climber.leanRight = false;
  climber.leanLeft = false;

}




// When the mouse is released we're done with the spring
// if the hand or foot is on a hold, attach it (NOTE, WOULD LOVE TO REPLACE THIS WITH REAL FRICTION!!)
public void mouseReleased() {
  spring.destroy();
  if (containingEndEffector == null) return;

  containingEndEffector.selected = false;

  // determine if end effector is on hold

  //  Particle hold = onHold(containingEndEffector);

  /*
  Hold hold = onHold(containingEndEffector);
   
   if ((containingEndEffector == climber.lHand || containingEndEffector == climber.rHand ||containingEndEffector == climber.lFoot ||containingEndEffector == climber.rFoot) && hold != null) {
   // create a temporary joint between the hold and end effector
   
   RevoluteJointDef rjd = new RevoluteJointDef();
   rjd.initialize(hold.body, containingEndEffector.body, containingEndEffector.body.getWorldCenter()) ;
   containingEndEffector.tempJoint = (RevoluteJoint) box2d.world.createJoint(rjd);
   
   // move the climber's body upward
   climber.up = true;
   }
   */
  climber.up = true;
}

// return Particle if end effector is on hold, else null
//Particle onHold(Particle endEffector) {
public Hold onHold(Box endEffector) {

  Vec2 effectorLocation = endEffector.body.getWorldCenter();

  // iterate through all holds, find whether end effector is close to one
  for (int i = holds.size ()-1; i >= 0; i--) {
    //    Particle p = holds.get(i);
    Hold p = holds.get(i);

    Vec2 holdLocation = p.body.getWorldCenter();

    if (holdLocation.sub(effectorLocation).length() < gripDistanceThreshold)
      return p;
  }

  // else
  return null;
}



// When the mouse is pressed we. . .
public void mousePressed() {
  // Check to see if the mouse was clicked on the box
  // returns the end effector containing the mouse click
  //  containingEndEffector = climber.contains(mouseX, mouseY);
  containingEndEffector = climber.nearest(mouseX, mouseY, 3);
  if (containingEndEffector != null) {
    climber.up = false; // don't try to move the body upward
    if (containingEndEffector.tempJoint != null) {
      box2d.world.destroyJoint(containingEndEffector.tempJoint);
      containingEndEffector.tempJoint = null;
    }
    // And if so, bind the mouse location to the box with a spring
    containingEndEffector.fixed = false;
    spring.bind(mouseX, mouseY, containingEndEffector);
  }
}

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A fixed boundary class (now incorporates angle)

class Boundary {

  // A boundary is a simple rectangle with x,y,width,and height
  float x;
  float y;
  float w;
  float h;
  // But we also have to make a body for box2d to know about it
  Body b;

  Boundary(float x_, float y_, float w_, float h_, float a) {
    x = x_;
    y = y_;
    w = w_;
    h = h_;

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.angle = a;
    bd.position.set(box2d.coordPixelsToWorld(x, y));


    b = box2d.createBody(bd);




    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.3f;
    fd.restitution = 0.5f;

    b.createFixture(fd);



    // Attached the shape to the body using a Fixture
    // b.createFixture(sd,1);
  }

  // Draw the boundary, if it were at an angle we'd have to do something fancier
  public void display() {
    noFill();
    stroke(0);
    strokeWeight(5);
    rectMode(CENTER);

    float a = b.getAngle();

    pushMatrix();
    translate(x, y);
    rotate(-a);
    rect(0, 0, w, h);
    popMatrix();
  }
}

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

  int col, defaultColor;

  boolean selected = false;
  boolean fixed = false;

  RevoluteJoint tempJoint = null;  // connection of particle to hold


  // Constructor
  Box(float x, float y, float w_, float h_, boolean lock, int c) {
    w = w_;
    h = h_;

    // Define and create the body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    if (lock) bd.type = BodyType.STATIC;
    else bd.type = BodyType.DYNAMIC;
//    bd.bullet = true;
    bd.angularDamping = 10.0f;

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
    fd.density = 10.0f;
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
  public void killBody() {
    box2d.destroyBody(body);
  }

  // Drawing the box
  public void display() {
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

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// Series of Boxs connected with distance joints

class Climber {

  // Bridge properties
  float totalLength;  // How long
  int numPoints;      // How many points

    // Our climber is a list of particles
  ArrayList<Box> joints;

  ArrayList<Box> jointPairs;

  IntList jointLengths;


  Box head, neck;
  Box lHand, lElbow;
  Box rHand, rElbow;
  Box belly, hips;
  Box lKnee, lFoot;
  Box rKnee, rFoot;

  DistanceJointDef djd;
  DistanceJoint dj;

  int bodyColor = color(0, 0, 0);
  
  boolean rest = false; // whether the climber is resting or no
  boolean up = false; // whether the torso should try to move upward

  boolean leanRight = false;
  boolean leanLeft = false;

  // constructor
  Climber(float x, float y) {

    joints = new ArrayList<Box>();
    jointPairs = new ArrayList<Box>(); 
    jointLengths = new IntList();

//  Box(float x, float y, float w_, float h_, boolean lock, color c) {

    head = new Box(x, y, 4, 4, false, bodyColor);
    joints.add(head);
    neck = new Box(x, y+10, 2, 2, false, bodyColor);
    joints.add(neck);
    lHand = new Box(x-40, y+10, 6, 2, false, bodyColor);
    joints.add(lHand);
    lElbow = new Box(x-20, y+10, 2, 2, false, bodyColor);
    joints.add(lElbow);
    rHand = new Box(x+40, y+10, 6, 2, false, bodyColor);
    joints.add(rHand);
    rElbow = new Box(x+20, y+10, 2, 2, false, bodyColor);
    joints.add(rElbow);
    belly =  new Box(x, y+30, 2, 2, false, bodyColor);
    joints.add(belly);
    hips = new Box(x, y+50, 2, 2, false, bodyColor);
    joints.add(hips);
    lFoot = new Box(x-40, y+100, 6, 2, false, bodyColor);
    joints.add(lFoot);
    lKnee = new Box(x-20, y+80, 2, 2, false, bodyColor);
    joints.add(lKnee);
    rFoot = new Box(x+40, y+100, 6, 2, false, bodyColor);
    joints.add(rFoot);
    rKnee = new Box(x+20, y+80, 2, 2, false, bodyColor);
    joints.add(rKnee);

    // add pairs of joined joints
    jointPairs.add(head);
    jointPairs.add(neck);
    jointLengths.append(10);


    jointPairs.add(neck);
    jointPairs.add(lElbow);
    jointLengths.append(20);


    jointPairs.add(neck);
    jointPairs.add(rElbow);
    jointLengths.append(20);

    jointPairs.add(neck);
    jointPairs.add(belly);
    jointLengths.append(10);

    jointPairs.add(belly);
    jointPairs.add(hips);
    jointLengths.append(10);

    jointPairs.add(lElbow);
    jointPairs.add(lHand);
    jointLengths.append(20);

    jointPairs.add(rElbow);
    jointPairs.add(rHand);
    jointLengths.append(20);

    jointPairs.add(hips);
    jointPairs.add(lKnee);
    jointLengths.append(20);

    jointPairs.add(hips);
    jointPairs.add(rKnee);
    jointLengths.append(20);

    jointPairs.add(lKnee);
    jointPairs.add(lFoot);
    jointLengths.append(20);

    jointPairs.add(rKnee);
    jointPairs.add(rFoot);
    jointLengths.append(20);


    for (int i = 0; i < jointPairs.size (); i += 2) {
      Box p1 = jointPairs.get(i);
      Box p2 = jointPairs.get(i+1);
      djd = new DistanceJointDef();
      djd.bodyA = p1.body;
      djd.bodyB = p2.body;
      djd.frequencyHz = 0;
      djd.dampingRatio = 10;
      djd.length = box2d.scalarPixelsToWorld(jointLengths.get(PApplet.parseInt(i/2)));
      dj = (DistanceJoint) box2d.world.createJoint(djd);
    }
  }

  public void display() {
    for (int i = 0; i < jointPairs.size (); i += 2) {
      Box p1 = jointPairs.get(i);
      Box p2 = jointPairs.get(i+1);
      Vec2 pos1 = box2d.getBodyPixelCoord(p1.body);
      Vec2 pos2 = box2d.getBodyPixelCoord(p2.body);
      stroke(0);
      strokeWeight(2);
      line(pos1.x, pos1.y, pos2.x, pos2.y);
    }


    for (int i = 0; i < joints.size (); i++) {    
      Box p1 = joints.get(i);
      p1.display();
    }

    if (rest == false)
      applyForces();
      
  }


  // force-directed spring layout - helps give life to figure
  // all neighbors sharing a segment (edge/link) attract each other
  // all nodes repel each other
  public void applyForces() {
    // iterate through all pairs of nodes, apply repelling force
    for (int i = 0; i < joints.size (); i++) {
      Box p1 = climber.joints.get(i);
      Vec2 pos1 = p1.body.getWorldCenter();
      for (int j = i+1; j < joints.size (); j++) {
        Box p2 = climber.joints.get(j);
        Vec2 pos2 = p2.body.getWorldCenter();

        // make a unit force from p1 to p2, use it to move p2 away from p1
        Vec2 force_p1_p2 = pos2.sub(pos1);
        force_p1_p2 = force_p1_p2.mul(3.0f/force_p1_p2.length());
        p2.body.applyForce(force_p1_p2, pos2);

        // reverse it, and apply to p1 (away from p2)
        p1.body.applyForce(force_p1_p2.mul(-1), pos1);
      }
    }
    
    // should we try to move the climber's body upward?
    if (up) {
      Vec2 headPos = head.body.getWorldCenter();
      Vec2 headForce = new Vec2(0,5);
      head.body.applyForce(headForce, headPos);
      Vec2 neckPos = neck.body.getWorldCenter();
      Vec2 neckForce = new Vec2(0,5);
      neck.body.applyForce(neckForce, neckPos);
      Vec2 bellyPos = belly.body.getWorldCenter();
      Vec2 bellyForce = new Vec2(0,5);
      belly.body.applyForce(bellyForce, bellyPos);
    }
    
     if (leanLeft) {
      Vec2 headPos = head.body.getWorldCenter();
      Vec2 headForce = new Vec2(-5,0);
      head.body.applyForce(headForce, headPos);
      Vec2 neckPos = neck.body.getWorldCenter();
      Vec2 neckForce = new Vec2(-5,0);
      neck.body.applyForce(neckForce, neckPos);
      Vec2 bellyPos = belly.body.getWorldCenter();
      Vec2 bellyForce = new Vec2(-5,0);
      belly.body.applyForce(bellyForce, bellyPos);
    }
    
     if (leanRight) {
      Vec2 headPos = head.body.getWorldCenter();
      Vec2 headForce = new Vec2(5,0);
      head.body.applyForce(headForce, headPos);
      Vec2 neckPos = neck.body.getWorldCenter();
      Vec2 neckForce = new Vec2(5,0);
      neck.body.applyForce(neckForce, neckPos);
      Vec2 bellyPos = belly.body.getWorldCenter();
      Vec2 bellyForce = new Vec2(5,0);
      belly.body.applyForce(bellyForce, bellyPos);
    }
    
    
  }


  // check whether any endeffector is near this point
  // return nearest endEffector if true
  // else return null
  public Box nearest(float x, float y, float distanceThreshold) {
    Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);

    Box currentEndEffector = null;
    Box nearestEndEffector = null;
    Vec2 effectorPosition;
    float distance = 0;
    float minDistance = 100000000.0f;

    for (int i = 0; i < joints.size (); i++) {

      currentEndEffector = joints.get(i);
      effectorPosition = currentEndEffector.body.getWorldCenter();

      distance = effectorPosition.sub(worldPoint).length();

      if (distance < distanceThreshold && distance < minDistance) {
        minDistance = distance;
        nearestEndEffector = currentEndEffector;
      }
    }

    if (nearestEndEffector != null)
      nearestEndEffector.selected = true;     

    return nearestEndEffector;
  }


  /*

   void playSound() {
   
   
   
   // play the file from start to finish.
   // if you want to play the file again, 
   // you need to call rewind() first.
   player.play();
   }
   */
}

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// A climbing hold
// want to be able to create various shapes, concave, convex
// would be useful to create random shapes having certain characteristics of friction, difficult, best direction to pull, etc.
// e.g. slopers, buckets, flakes, etc.


class Hold {

  // We need to keep track of a Body and a width and height
  Body body;
  float w;
  float h;

  int col, defaultColor;

  boolean selected = false;
  boolean fixed = false;

  RevoluteJoint tempJoint = null;  // connection of particle to hold


  // Constructor
  Hold(float x, float y, float w_, float h_, boolean lock, int c) {
    w = w_;
    h = h_;

    // Define and create the body
    BodyDef bd = new BodyDef();
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(x, y)));
    if (lock) bd.type = BodyType.STATIC;
    else bd.type = BodyType.DYNAMIC;
    //    bd.bullet = true;
    bd.angularDamping = 10.0f;

    body = box2d.createBody(bd);


    Vec2[] vertices = new Vec2[4]; // An array of 4 vectors
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-15, 25));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(15, 0));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(20, -15));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(-10, -10));
    /*
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(x-.15 * w, y+.25*h));
     vertices[1] = box2d.vectorPixelsToWorld(new Vec2(x+.15 * w, y+0));
     vertices[2] = box2d.vectorPixelsToWorld(new Vec2(x+.20 * w, y-.15*h));
     vertices[3] = box2d.vectorPixelsToWorld(new Vec2(x-.10 * w, y-.10*h));
     */
    PolygonShape sd = new PolygonShape(); 
    sd.set(vertices, vertices.length);

    /*
    // Define the shape -- a  (this is what we use for a rectangle)
     PolygonShape sd = new PolygonShape();
     float box2dW = box2d.scalarPixelsToWorld(w/2);
     float box2dH = box2d.scalarPixelsToWorld(h/2);
     sd.setAsBox(box2dW, box2dH);
     */

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 10.0f;
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
  public void killBody() {
    box2d.destroyBody(body);
  }

  /*
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
   */

  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    // First we get the Fixture attached to the
    //  body...
    Fixture f = body.getFixtureList();
    PolygonShape ps = (PolygonShape) f.getShape(); 
    //...then the Shape attached to the Fixture.
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(col);
    stroke(0);
    strokeWeight(1);
    beginShape();
    for (int i = 0; i < ps.getVertexCount (); i++) {
      Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    popMatrix();
  }
}

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// A circular particle

class Particle {

  // We need to keep track of a Body and a radius
  Body body;
  float r;

  int col, defaultColor;

  boolean selected = false;
  boolean fixed = false;

  float mass;

  RevoluteJoint tempJoint = null;  // connection of particle to hold

  // location x, y, radius, and type ("STATIC", "DYNAMIC", "KINEMATIC")
  Particle(float x, float y, float r_, String type, int c) {
    r = r_;
    // This function puts the particle in the Box2d world
    makeBody(x, y, r, type);
    body.setUserData(this);

    col = c;
    defaultColor = c;
  }

  // This function removes the particle from the box2d world
  public void killBody() {
    box2d.destroyBody(body);
  }

  // Change color when hit
  public void change() {
    col = color(255, 0, 0);
  }

  // Is the particle ready for deletion?
  public boolean done() {
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
  public void display() {
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
  public void makeBody(float x, float y, float r, String type) {
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

    fd.density = 30.0f;
    //    fd.friction = 0.01;
    fd.friction = 1.0f;
    fd.restitution = 0; // Restitution is bounciness

    body.createFixture(fd);

    mass = body.getMass();
    // Give it a random initial velocity (and angular velocity)
    //body.setLinearVelocity(new Vec2(random(-10f,10f),random(5f,10f)));
    // body.setAngularVelocity(random(-10, 10));
  }
}

// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2010
// Box2DProcessing example

// Class to describe the spring joint (displayed as a line)

class Spring {

  // This is the box2d object we need to create
  MouseJoint mouseJoint;

  Spring() {
    // At first it doesn't exist
    mouseJoint = null;
  }

  // If it exists we set its target to the mouse location 
  public void update(float x, float y) {
    if (mouseJoint != null) {
      // Always convert to world coordinates!
      Vec2 mouseWorld = box2d.coordPixelsToWorld(x,y);
      mouseJoint.setTarget(mouseWorld);
    }
  }

  public void display() {
    if (mouseJoint != null) {
      // We can get the two anchor points
      Vec2 v1 = new Vec2(0,0);
      mouseJoint.getAnchorA(v1);
      Vec2 v2 = new Vec2(0,0);
      mouseJoint.getAnchorB(v2);
      // Convert them to screen coordinates
      v1 = box2d.coordWorldToPixels(v1);
      v2 = box2d.coordWorldToPixels(v2);
      // And just draw a line
      stroke(0);
      strokeWeight(1);
      line(v1.x,v1.y,v2.x,v2.y);
    }
  }


  // This is the key function where
  // we attach the spring to an x,y location
  // and the Box object's location
  public void bind(float x, float y, Box box) {
    // Define the joint
    MouseJointDef md = new MouseJointDef();
    // Body A is just a fake ground body for simplicity (there isn't anything at the mouse)
    md.bodyA = box2d.getGroundBody();
    // Body 2 is the box's boxy
    md.bodyB = box.body;
    // Get the mouse location in world coordinates
    Vec2 mp = box2d.coordPixelsToWorld(x,y);
    // And that's the target
    md.target.set(mp);
    // Some stuff about how strong and bouncy the spring should be
    md.maxForce = 100 * box.body.m_mass;
    md.frequencyHz = 1.0f;
    md.dampingRatio = 1;

    // Make the joint!
    mouseJoint = (MouseJoint) box2d.world.createJoint(md);
  }

/*
// This is the key function where
  // we attach the spring to an x,y location
  // and the Box object's location
  void bind(float x, float y, Particle particle) {
    // Define the joint
    MouseJointDef md = new MouseJointDef();
    // Body A is just a fake ground body for simplicity (there isn't anything at the mouse)
    md.bodyA = box2d.getGroundBody();
    // Body 2 is the box's boxy
    md.bodyB = particle.body;
    // Get the mouse location in world coordinates
    Vec2 mp = box2d.coordPixelsToWorld(x,y);
    // And that's the target
    md.target.set(mp);
    // Some stuff about how strong and bouncy the spring should be
    md.maxForce = 1000.0 * particle.body.m_mass;
    md.frequencyHz = 5.0;
    md.dampingRatio = 0.9;

    // Make the joint!
    mouseJoint = (MouseJoint) box2d.world.createJoint(md);
  }
  */
  
  /*
  // This is the key function where
  // we attach the spring to an x,y location
  // and the Box object's location
  void bind(float x, float y, Box box) {
    // Define the joint
    MouseJointDef md = new MouseJointDef();
    // Body A is just a fake ground body for simplicity (there isn't anything at the mouse)
    md.bodyA = box2d.getGroundBody();
    // Body 2 is the box's boxy
    md.bodyB = box.body;
    // Get the mouse location in world coordinates
    Vec2 mp = box2d.coordPixelsToWorld(x,y);
    // And that's the target
    md.target.set(mp);
    // Some stuff about how strong and bouncy the spring should be
    md.maxForce = 1000.0 * box.body.m_mass;
    md.frequencyHz = 5.0;
    md.dampingRatio = 0.9;

    // Make the joint!
    mouseJoint = (MouseJoint) box2d.world.createJoint(md);
  }
  */
  
  
  
  public void destroy() {
    // We can get rid of the joint when the mouse is released
    if (mouseJoint != null) {
      box2d.world.destroyJoint(mouseJoint);
      mouseJoint = null;
    }
  }

}



/*
track and display the climber status
 */
class StatusPanel {

  Boundary bounds;

  StatusPanel(float inX, float inY, float w, float h) {
    bounds = new Boundary(inX, inY, w, h, 0);
  }

  // display the status
  public void display(float lArm, float rArm, float lLeg, float rLeg, float overall) {
    // draw a box and horizontal bars representing status

    stroke(0);
    bounds.display();

    stroke(0, 0, 0);
    PFont myFont;
    // The font must be located in the sketch's 
    // "data" directory to load successfully
    myFont = createFont("Georgia", 16);
    textFont(myFont);
    //    textAlign(CENTER, CENTER);
    //    textFont(ont, 32);
    text("left arm", bounds.x - 40, bounds.y - 80);
    //    line(bounds.x - 40, bounds.y - 90, bounds.x + bounds.w - 60, bounds.y - 90);
    line(bounds.x - 40, bounds.y - 70, bounds.x + bounds.w - 60, bounds.y - 70);
    text("right arm", bounds.x - 40, bounds.y - 60);
    line(bounds.x - 40, bounds.y - 50, bounds.x + bounds.w - 60, bounds.y - 50);
    text("left leg", bounds.x - 40, bounds.y - 40);
    line(bounds.x - 40, bounds.y - 30, bounds.x + bounds.w - 60, bounds.y - 30);
    text("right leg", bounds.x - 40, bounds.y - 20);
    line(bounds.x - 40, bounds.y - 10, bounds.x + bounds.w - 60, bounds.y - 10);
    text("overall", bounds.x - 40, bounds.y);
    line(bounds.x - 40, bounds.y + 10, bounds.x + bounds.w - 60, bounds.y + 10);
  }
}


/*
The climbing wall itself

patterns, textures, colors, holds, friction areas, cracks, features are all interesting

indoor, outdoor

fractal patterns

delaunay triangulation patterns

want 3D?


*/
class Wall {


Wall() {

}

public void display() {
  
}
}


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Climber_Galen_use_Distance_Joints" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
