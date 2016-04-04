import java.util.ArrayList;
import java.util.Collections;

static final int DPI = 276;
static final int NUM_TRIALS = 20; // this will be set higher for the bakeoff
static final float BORDER = inchesToPixels(.2f); // have some padding from the sides
static final float DESTINATION_SIZE = 50f;
static final float DESTINATION_ROTATION = 0f;
static final int DESTINATION_COLOR = 0x80FFFFFF;
static final int TARGET_COLOR = 0xFFFF0000;
static final int BACKGROUND_COLOR = 0xFF000000;

String transformMode = "";
Target transformDelta = new Target();
ArrayList<Target> targets = new ArrayList<Target>();
int trialIndex = 0;
int errorCount = 0;
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

void setup() {
  surface.setSize(round(DPI * 2), round(DPI * 3.5)); //set this, based on your sceen's PPI to be a 2x3.5" area.

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.15f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this!
  for (int i = 0; i < NUM_TRIALS; i++) {
    Target t = new Target(
      random(-width/2 + BORDER, width/2 - BORDER), //set a random x with some padding
      random(-height/2 + BORDER, height/2 - BORDER), //set a random y with some padding
      ((i % 20) + 1) * inchesToPixels(.15f), //increasing size from .15 up to 3.0"
      random(0, 360) //random rotation between 0 and 360
    );
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }
  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {
  background(0); // background is dark grey
  fill(200);
  noStroke();

  if (startTime == 0) startTime = millis();

  if (userDone) {
    text("User completed " + NUM_TRIALS + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f) * 2);
    text("User took " + (finishTime - startTime) / 1000f / NUM_TRIALS + " sec per target", width/2, inchesToPixels(.2f) * 3);
    return;
  }

  drawTarget();
  drawDestination();

  text("Trial " + (trialIndex + 1) + " of " + NUM_TRIALS, width/2, inchesToPixels(.5f));
}

void drawTarget() {
  Target t = targets.get(trialIndex).add(transformDelta);
  pushMatrix();
  translate(t.x, t.y);
  rotate(radians(t.rotation));
  fill(TARGET_COLOR);
  rect(0, 0, t.z, t.z);
  popMatrix();
}

void drawDestination() {
  pushMatrix();
  translate(width/2, height/2);
  rotate(radians(DESTINATION_ROTATION));
  fill(DESTINATION_COLOR);
  rect(0, 0, DESTINATION_SIZE, DESTINATION_SIZE);
  popMatrix();
}

void mousePressed() {
  loadPixels();
  if (pixels[mouseY * width + mouseX] != color(TARGET_COLOR)) {
    transformMode = "rotate";
  }
}

void mouseDragged() {
  if (transformMode == "rotate") {
    Target t = targets.get(trialIndex).add(transformDelta);
    transformDelta.rotation = degrees(atan2(mouseY - t.y, mouseX - t.x));
  }
}

void mouseReleased() {
  if (userDone) return;
  transformMode = "";

  // check to see if user clicked middle of screen
  if (dist(width/2, height/2, mouseX, mouseY) < inchesToPixels(.5f)) {
    // check for incorrect placement
    if (!checkForSuccess()) errorCount++;

    // move on to next trial
    trialIndex++;
    transformDelta = new Target();

    if (trialIndex >= NUM_TRIALS) {
      userDone = true;
      finishTime = millis();
    }
  }
}

static float inchesToPixels(float inch) { return inch * DPI; }

boolean checkForSuccess() {
  Target t = targets.get(trialIndex);
  float d = dist(t.x + transformDelta.x, t.y + transformDelta.y, width/2, height/2);
  float r = angleDist(t.rotation + transformDelta.rotation, DESTINATION_ROTATION);
  float z = abs(t.z + transformDelta.z - DESTINATION_SIZE);
  boolean withinDistance  = d <= inchesToPixels(.05f); // has to be within .1"
  boolean withinRotation  = r <= 5;                    // has to be within 5*
  boolean withinSize      = z <= inchesToPixels(.05f); // has to be within .1"
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
  public float x;
  public float y;
  public float z;
  public float rotation;

  public Target() {
    this.x = 0;
    this.y = 0;
    this.z = 0;
    this.rotation = 0;
  }

  public Target(float x, float y, float z, float r) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.rotation = r;
  }

  public Target add(Target t) {
    return new Target(
      this.x + t.x,
      this.y + t.y,
      this.z + t.z,
      this.rotation + t.rotation
    );
  }
}