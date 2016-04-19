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

  color bodyColor = color(0, 0, 0);
  
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
      djd.length = box2d.scalarPixelsToWorld(jointLengths.get(int(i/2)));
      dj = (DistanceJoint) box2d.world.createJoint(djd);
    }
  }

  void display() {
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
  void applyForces() {
    // iterate through all pairs of nodes, apply repelling force
    for (int i = 0; i < joints.size (); i++) {
      Box p1 = climber.joints.get(i);
      Vec2 pos1 = p1.body.getWorldCenter();
      for (int j = i+1; j < joints.size (); j++) {
        Box p2 = climber.joints.get(j);
        Vec2 pos2 = p2.body.getWorldCenter();

        // make a unit force from p1 to p2, use it to move p2 away from p1
        Vec2 force_p1_p2 = pos2.sub(pos1);
        force_p1_p2 = force_p1_p2.mul(3.0/force_p1_p2.length());
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
  Box nearest(float x, float y, float distanceThreshold) {
    Vec2 worldPoint = box2d.coordPixelsToWorld(x, y);

    Box currentEndEffector = null;
    Box nearestEndEffector = null;
    Vec2 effectorPosition;
    float distance = 0;
    float minDistance = 100000000.0;

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

