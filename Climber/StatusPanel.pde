
/*
track and display the climber status
 */
class StatusPanel {

  Boundary bounds;

  StatusPanel(float inX, float inY, float w, float h) {
    bounds = new Boundary(inX, inY, w, h, 0);
  }

  // display the status
  void display(float lArm, float rArm, float lLeg, float rLeg, float overall) {
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

