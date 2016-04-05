import java.util.ArrayList;
import java.util.Collections;

// Static vars
static final int DPI = 276;
static final int SCREEN_WIDTH = round(DPI * 2);
static final int SCREEN_HEIGHT = round(DPI * 3.5);
static final int NUM_TRIALS = 20; // this will be set higher for the bakeoff
static final float BORDER = inchesToPixels(.2f); // have some padding from the sides
static final float DESTINATION_ROTATION = 0f;
static final float MIN_X = -SCREEN_WIDTH/2  + BORDER;
static final float MAX_X =  SCREEN_WIDTH/2  - BORDER;
static final float MIN_Y = -SCREEN_HEIGHT/2 + BORDER;
static final float MAX_Y =  SCREEN_HEIGHT/2 - BORDER;
static final float MIN_Z = inchesToPixels(.15f);
static final float MAX_Z = NUM_TRIALS * MIN_Z;
static final float DESTINATION_SIZE = (MIN_Z + MAX_Z) / 2;

// Colors vars
static final int DESTINATION_COLOR  = 0x80FFFFFF;
static final int TARGET_COLOR       = 0xFFFF0000;
static final int BACKGROUND_COLOR   = 0xFF000000;
static final int FOREGROUND_COLOR   = 0xFFCCCCCC;
static final int LINE_COLOR         = 0xFF000000;
static final int SCROLLBAR_BG_COLOR = 0xFFCCCCCC;
static final int SCROLLBAR_FG_COLOR = 0x80333333;
static final int SCROLLBAR_HL_COLOR = 0x80000000;

// Instance vars
ArrayList<Target> targets = new ArrayList<Target>();
int trialIndex = -1;
int errorCount = 0;
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
Scrollbar xInput, yInput, zInput, rInput;

void setup() {
  surface.setSize(SCREEN_WIDTH, SCREEN_HEIGHT); //set this, based on your sceen's PPI to be a 2x3.5" area.

  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this!
  for (int i = 0; i < NUM_TRIALS; i++) {
    Target t = new Target(
      random(MIN_X, MAX_X), //set a random x with some padding
      random(MIN_Y, MAX_Y), //set a random y with some padding
      ((i % 20) + 1) * MIN_Z, //increasing size from .15 up to 3.0"
      random(0, 360) //random rotation between 0 and 360
    );
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }
  Collections.shuffle(targets); // randomize the order of the button; don't change this.

  int margin = (int)BORDER/2;
  int offset = 30;
  int thickness = 40;
  // new Scrollbar(x,y,w,h,vertical?)
  xInput = new Scrollbar(margin + offset, margin - thickness/2, width - margin*2 - offset*2, thickness, false);
  yInput = new Scrollbar(margin - thickness/2, margin + offset, thickness, height - margin*2 - offset*2, true);
  zInput = new Scrollbar(margin + offset, height - margin - thickness/2, width - margin*2 - offset*2, thickness, false);
  rInput = new Scrollbar(width - margin - thickness/2, margin + offset, thickness, height - margin*2 - offset*2, true);
  nextTrial();
}

void draw() {
  rectMode(CENTER);
  background(0); // background is dark grey
  fill(FOREGROUND_COLOR);
  noStroke();

  if (startTime == 0) startTime = millis();

  if (userDone) {
    text("User completed " + NUM_TRIALS + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f) * 2);
    text("User took " + (finishTime - startTime) / 1000f / NUM_TRIALS + " sec per target", width/2, inchesToPixels(.2f) * 3);
    return;
  }

  text("Trial " + (trialIndex + 1) + " of " + NUM_TRIALS, width/2, inchesToPixels(.5f));

  drawTarget();
  drawDestination();
  updateInputs();
}

void drawTarget() {
  Target t = targets.get(trialIndex);
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(t.x, t.y);
  rotate(radians(t.rotation));
  fill(TARGET_COLOR);
  rect(0, 0, t.z, t.z);
  popMatrix();
}

void drawDestination() {
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(DESTINATION_ROTATION));
  fill(DESTINATION_COLOR);
  rect(0, 0, DESTINATION_SIZE, DESTINATION_SIZE);
  popMatrix();
}

void updateInputs() {
  xInput.draw();
  yInput.draw();
  zInput.draw();
  rInput.draw();
  rectMode(CENTER);

  Target t = targets.get(trialIndex);
  t.x = map(xInput.val(), xInput.min, xInput.max, MIN_X, MAX_X);
  t.y = map(yInput.val(), yInput.min, yInput.max, MIN_Y, MAX_Y);
  t.z = map(zInput.val(), zInput.min, zInput.max, MIN_Z, MAX_Z);
  t.rotation = map(rInput.val(), rInput.min, rInput.max, 0, 360);
}

void mouseReleased() {
  if (userDone) return;

  // check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY) < inchesToPixels(.2f)) {
    // check for incorrect placement
    if (!checkForSuccess()) errorCount++;

    // move on to next trial
    nextTrial();

    if (trialIndex >= NUM_TRIALS) {
      userDone = true;
      finishTime = millis();
    }
  }
}

void nextTrial() {
  trialIndex++;
  xInput.val(map(targets.get(trialIndex).x, MIN_X, MAX_X, xInput.min, xInput.max));
  yInput.val(map(targets.get(trialIndex).y, MIN_Y, MAX_Y, yInput.min, yInput.max));
  zInput.val(map(targets.get(trialIndex).z, MIN_Z, MAX_Z, zInput.min, zInput.max));
  rInput.val(map(targets.get(trialIndex).rotation, 0, 360, rInput.min, rInput.max));
}

static float inchesToPixels(float inch) { return inch * DPI; }

boolean checkForSuccess() {
  Target t = targets.get(trialIndex);
  float d = dist(t.x, t.y, width/2, height/2);
  float r = angleDist(t.rotation, DESTINATION_ROTATION);
  float z = abs(t.z - DESTINATION_SIZE);
  boolean withinDistance  = d <  inchesToPixels(.05f); // has to be within .1"
  boolean withinRotation  = r <= 5;                    // has to be within 5*
  boolean withinSize      = z <  inchesToPixels(.05f); // has to be within .1"
  println("Close Enough Distance: " + withinDistance);
  println("Close Enough Rotation: " + withinRotation + " (dist=" + r + ")");
  println("Close Enough Z: " + withinSize);

  return withinDistance && withinRotation && withinSize;
}

float angleDist(float a1, float a2) {
  float diff = abs(a1 - a2);
  diff %= 90;
  if (diff > 45) return 90 - diff;
  else return diff;
}

class Target {
  float x;
  float y;
  float z;
  float rotation;

  Target() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.rotation = 0;
  }

  Target(float x, float y, float z, float r) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.rotation = r;
  }
}

class Scrollbar {
  float barX, barY;                   // Position of the bar
  int barWidth, barHeight;            // Height and width of the bar
  float sliderPos, newSliderPos;      // Position of slider
  float targetPos;
  float min, max;                     // Max and min slider positions
  int weight;                         // How much effort it takes to slide
  boolean orientation;                // Vertical = true, horizontal = false
  boolean hovered;                    // Is mouse over slider?
  boolean locked;                     // Toggle lockinig of slider

  Scrollbar(float x, float y, int w, int h, boolean o) {
    barX = x;
    barY = y;
    barWidth = w;
    barHeight = h;
    orientation = o;
    sliderPos = orientation ? y + h/2 - w/2 : x + w/2 - h/2;
    newSliderPos = sliderPos;
    min = orientation ? y : x;
    max = orientation ? y + h - w : x + w - h;
    targetPos = (max + min) / 2;
    weight = 16;
  }

  private void update() {
    hovered = barX < mouseX && mouseX < barX + barWidth && barY < mouseY && mouseY < barY + barHeight;
    if (mousePressed && hovered) locked = true;
    if (!mousePressed) locked = false;
    if (locked) newSliderPos = constrain(orientation ? mouseY-barWidth/2 : mouseX-barHeight/2, min, max);
    if (abs(newSliderPos - sliderPos) > 1) sliderPos += (newSliderPos - sliderPos) / weight;
  }

  void draw() {
    update();
    rectMode(CORNER);
    noStroke();
    fill(SCROLLBAR_BG_COLOR);
    rect(barX, barY, barWidth, barHeight);
    if (orientation) {
      fill(TARGET_COLOR);
      rect(barX, targetPos, barWidth, barWidth);
      fill((hovered || locked) ? SCROLLBAR_HL_COLOR : SCROLLBAR_FG_COLOR);
      rect(barX, sliderPos, barWidth, barWidth);
    }
    else {
      fill(TARGET_COLOR);
      rect(targetPos, barY, barHeight, barHeight);
      fill((hovered || locked) ? SCROLLBAR_HL_COLOR : SCROLLBAR_FG_COLOR);
      rect(sliderPos, barY, barHeight, barHeight);
    }
  }

  float val() {
    return sliderPos;
  }

  void val(float newPos) {
    sliderPos = newPos;
    newSliderPos = sliderPos;
  }

  void setTarget(float pos) {
    targetPos = pos;
  }
}
