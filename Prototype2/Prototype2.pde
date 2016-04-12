import java.util.ArrayList;
import java.util.Collections;

// Static vars
// static final int DPI = 276; // for jake's laptop
static final int DPI = 199; // for loaner android
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
static final int SUCCESS_COLOR      = 0xFFDFF2BF;
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

public void settings() { size(SCREEN_WIDTH, SCREEN_HEIGHT); }

void setup() {
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
    println("created target with " + t.x + "," + t.y + "," + t.r + "," + t.z);
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
    text("User completed " + NUM_TRIALS + " trials", SCREEN_WIDTH/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", SCREEN_WIDTH/2, inchesToPixels(.2f) * 2);
    text("User took " + (finishTime - startTime) / 1000f / NUM_TRIALS + " sec per target", SCREEN_WIDTH/2, inchesToPixels(.2f) * 3);
    return;
  }

  text("Trial " + (trialIndex + 1) + " of " + NUM_TRIALS, SCREEN_WIDTH/2, inchesToPixels(.5f));

  drawTarget();
  drawDestination();
  updateInputs();

  // If accurate enough, flash the whole screen green
  if (checkForSuccess(true)) {
    background(SUCCESS_COLOR);
    fill(0);
    text("Click for Next Trial", SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
  }
}

void drawTarget() {
  Target t = targets.get(trialIndex);
  pushMatrix();
  translate(SCREEN_WIDTH/2 + t.x, SCREEN_HEIGHT/2 + t.y);
  rotate(radians(t.r));
  fill(TARGET_COLOR);
  rect(0, 0, t.z, t.z);
  popMatrix();
}

void drawDestination() {
  pushMatrix();
  translate(SCREEN_WIDTH/2, SCREEN_HEIGHT/2); //center the drawing coordinates to the center of the screen
  rotate(radians(DESTINATION_ROTATION));
  fill(DESTINATION_COLOR);
  rect(0, 0, DESTINATION_SIZE, DESTINATION_SIZE);
  popMatrix();
}

void updateInputs() {
  boolean[] results = checkForSuccesses(true);
  xInput.draw(results[0]);
  yInput.draw(results[1]);
  zInput.draw(results[2]);
  rInput.draw(results[3]);
  rectMode(CENTER);

  Target t = targets.get(trialIndex);
  t.x = map(xInput.val(), xInput.min, xInput.max, MIN_X, MAX_X);
  t.y = map(yInput.val(), yInput.min, yInput.max, MIN_Y, MAX_Y);
  t.z = map(zInput.val(), zInput.min, zInput.max, MIN_Z, MAX_Z);
  t.r = map(rInput.val(), rInput.min, rInput.max, 0, 360);
}

int clickCount = 0;
void mouseReleased() {
  if (userDone || !checkForSuccess(true) || clickCount++ < 1) return;
  checkForSuccess(false); // Print debug output just in case
  nextTrial();
  clickCount = 0;
  // check to see if user clicked middle of screen and is accurate enough
  // if so, then go to the next trial
  // if (dist(width/2, SCREEN_HEIGHT/2, mouseX, mouseY) < inchesToPixels(0.5f) && checkForSuccess(false))
}

void nextTrial() {
  if (trialIndex >= NUM_TRIALS) {
    userDone = true;
    finishTime = millis();
    return;
  }

  trialIndex++;
  xInput.val(map(targets.get(trialIndex).x, MIN_X, MAX_X, xInput.min, xInput.max));
  yInput.val(map(targets.get(trialIndex).y, MIN_Y, MAX_Y, yInput.min, yInput.max));
  zInput.val(map(targets.get(trialIndex).z, MIN_Z, MAX_Z, zInput.min, zInput.max));
  rInput.val(map(targets.get(trialIndex).r, 0, 360, rInput.min, rInput.max));
}

boolean checkForSuccess(boolean dryRun) {
  boolean[] results = checkForSuccesses(dryRun);
  return results[0] && results[1] && results[2] && results[3];
}

boolean[] checkForSuccesses(boolean dryRun) {
  Target t = targets.get(trialIndex);
  float x = abs(t.x);
  float y = abs(t.y);
  float z = abs(t.z - DESTINATION_SIZE);
  float r = angleDist(t.r, DESTINATION_ROTATION);
  boolean withinX  = x <  inchesToPixels(.05f); // has to be within .1"
  boolean withinY  = y <  inchesToPixels(.05f); // has to be within .1"
  boolean withinZ  = z <  inchesToPixels(.05f); // has to be within .1"
  boolean withinR  = r <= 5;                    // has to be within 5*

  if (!dryRun) {
    println("Close Enough X: " + withinX + " (dist=" + x/DPI + "in)");
    println("Close Enough Y: " + withinY + " (dist=" + y/DPI + "in)");
    println("Close Enough R: " + withinZ + " (dist=" + z/DPI + "in)");
    println("Close Enough Z: " + withinR + " (dist=" + r     + "deg)");
  }

  boolean[] results = { withinX, withinY, withinZ, withinR };
  return results;
}

float angleDist(float a1, float a2) {
  float diff = abs(a1 - a2);
  diff %= 90;
  if (diff > 45) return 90 - diff;
  else return diff;
}

static float inchesToPixels(float inch) { return inch * DPI; }

class Target {
  float x;
  float y;
  float z;
  float r;

  Target() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.r = 0;
  }

  Target(float x, float y, float z, float r) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.r = r;
  }
}

class Scrollbar {
  float barX, barY;                   // Position of the bar
  int barWidth, barHeight;            // Height and width of the bar
  float sliderPos, newSliderPos;      // Position of slider
  float targetPos;
  float min, max;                     // Max and min slider positions
  boolean orientation;                // Vertical = true, horizontal = false
  boolean hovered;                    // Is mouse over slider?
  boolean stillScroll;                // Continue scrolling?

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
  }

  private void update() {
    hovered = orientation
      ? (barX <= mouseX && mouseX <= barX + barWidth && sliderPos <= mouseY && mouseY <= sliderPos + barWidth)
      : (barY <= mouseY && mouseY <= barY + barHeight && sliderPos <= mouseX && mouseX <= sliderPos + barHeight);
    if (mousePressed && hovered) stillScroll = true;
    if (!mousePressed) stillScroll = false;
    if (stillScroll) newSliderPos = constrain(orientation ? mouseY-barWidth/2 : mouseX-barHeight/2, min, max);
    else newSliderPos = sliderPos;
    if (abs(newSliderPos - sliderPos) > 1) sliderPos += (newSliderPos - sliderPos);
  }

  void draw(boolean onTarget) {
    update();

    rectMode(CORNER);
    noStroke();
    fill(SCROLLBAR_BG_COLOR);
    rect(barX, barY, barWidth, barHeight);

    float offset = 0;
    if (orientation) {
      // Draw target
      stroke(TARGET_COLOR);
      strokeWeight(4);
      noFill();
      rect(barX, targetPos, barWidth, barWidth);
      noStroke();

      // Draw scroller
      fill(onTarget ? SUCCESS_COLOR : (hovered || stillScroll ? SCROLLBAR_HL_COLOR : SCROLLBAR_FG_COLOR));
      if (false && stillScroll) offset = 50 * (barX < SCREEN_WIDTH/2 ? 1 : -1);
      rect(barX + offset, sliderPos, barWidth, barWidth);
    } else {
      // Draw target
      stroke(TARGET_COLOR);
      strokeWeight(4);
      noFill();
      rect(targetPos, barY, barHeight, barHeight);
      noStroke();

      // Draw scroller
      fill(onTarget ? SUCCESS_COLOR : (hovered || stillScroll ? SCROLLBAR_HL_COLOR : SCROLLBAR_FG_COLOR));
      if (false && stillScroll) offset = 50 * (barY < SCREEN_HEIGHT/2 ? 1 : -1);
      rect(sliderPos, barY + offset, barHeight, barHeight);
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
