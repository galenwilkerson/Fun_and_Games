// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2011
// Box2DProcessing example

// Example demonstrating distance joints 
// A climber is formed by connected a series of particles with joints

import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

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



void setup() {
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
  int numberOfHolds = int(random(40, 60));
  for (int i = 0; i < numberOfHolds; i++) {
    color holdColor = color(random(255), random(255), random(255));
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

void draw() {
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
void keyPressed() {
  //  climber.rest = true;

  if (key == 'd')
    climber.leanRight = true;
  else if (key == 'a')
    climber.leanLeft = true;
}


// rest when key pressed
void keyReleased() {
//  climber.rest = false;
  climber.leanRight = false;
  climber.leanLeft = false;

}




// When the mouse is released we're done with the spring
// if the hand or foot is on a hold, attach it (NOTE, WOULD LOVE TO REPLACE THIS WITH REAL FRICTION!!)
void mouseReleased() {
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
Hold onHold(Box endEffector) {

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
void mousePressed() {
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

