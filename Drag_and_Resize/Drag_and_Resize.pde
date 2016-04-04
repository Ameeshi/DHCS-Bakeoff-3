ClassRect lines [] = new ClassRect [1];  
 
boolean take1, take2, take3, take4, take5; 
float oldMouseX1, oldMouseY1;

void setup()
{
  size(640, 560);
  background(111);
  lines [0] = new ClassRect  (  111, 111, 222, 222  );
}
 
void draw()
{ 
  background(111);
 
  stroke(0);
 
  text ("upper left corner: drag the box around \n"
    +"Lower right corner: resize ", 30, 30);
 
  lines [0].draw();
  
 //if inside the circle, then we will just drag the square
 if(take1){
 lines[0].x1 = lines[0].x1 + (mouseX-oldMouseX1); 
 lines[0].y1 = lines[0].y1 + (mouseY-oldMouseY1); 
 oldMouseX1 = mouseX; 
 oldMouseY1 = mouseY; 
 }
 
 //if we clicked on the lower right corner
 if (take2) {
    lines[0].rectWidth=mouseX-lines[0].x1;
    lines[0].rectHeight=mouseX-lines[0].x1;
    //println("rectWidth: ", lines[0].rectWidth , "rectHeight",  lines[0].rectHeight); 
  }
  
  //if we clicked on the lower left corner
 if (take3) {
    lines[0].rectWidth=  lines[0].rectWidth+(lines[0].x1 - mouseX); 
    lines[0].rectHeight= lines[0].rectWidth+(lines[0].x1 - mouseX); 
    lines[0].x1 = mouseX; 
  }
 
 //if we clicked on the upper right corner
 if (take4) {
    lines[0].rectWidth=  lines[0].rectWidth+(lines[0].y1 - mouseY); 
    lines[0].rectHeight= lines[0].rectWidth+(lines[0].y1 - mouseY); 
    lines[0].y1 = mouseY; 
  }
  
 //if we clicked on the upper left corner
 if (take5) {
    lines[0].rectWidth=  lines[0].rectWidth+(lines[0].x1 - mouseX); 
    lines[0].rectHeight= lines[0].rectWidth+(lines[0].x1 - mouseX); 
    lines[0].x1 = mouseX;
    lines[0].y1 = mouseY; 
  }
 
  /*
  if (take1) {
    lines[0].x1=mouseX;
    lines[0].y1=mouseY;
  }
  */
  
 // ellipse(lines[0].x1+(lines[0].rectWidth)/2, lines[0].y1+(lines[0].rectWidth)/2, lines[0].rectWidth-5, lines[0].rectWidth-5);
} // func 
 
void mousePressed() {
 
  //if inside the circle 
  if(sq(mouseX- (lines[0].x1 + lines[0].rectWidth/2)) + sq(mouseY- (lines[0].y1 + lines[0].rectWidth/2)) < sq(lines[0].rectWidth/2))
  {
    take1=true;
    oldMouseX1 = mouseX; 
    oldMouseY1 = mouseY; 
  }
  
  // Lower right corner 
  else if (dist (lines[0].x1+lines[0].rectWidth, 
  lines[0].y1+lines[0].rectHeight, mouseX, mouseY) < 40) {
    take2=true;
  }
  
  // Lower left corner 
  else if (dist (lines[0].x1, 
  lines[0].y1+lines[0].rectHeight, mouseX, mouseY) < 40) {
    take3=true;
  }
  
  // upper right corner 
  else if (dist (lines[0].x1+lines[0].rectWidth, 
  lines[0].y1, mouseX, mouseY) < 40) {
    take4=true;
  }
  
   // upper left corner 
  else if (dist (lines[0].x1, 
  lines[0].y1, mouseX, mouseY) < 40) {
    take5=true;
  }
  
  /*
  // upper left corner 
  if (dist (lines[0].x1, 
  lines[0].y1, mouseX, mouseY) < 12) {
    take1=true;
  }
  */
}
 
void mouseReleased() {
  take1=false; // around the center of the square 
  take2=false; // lower right corner 
  take3=false; // lower left corner
  take4=false; // upper right corner
  take5=false; // lower left corner
}
 
// =======================================
 
class ClassRect {
 
  float x1, y1, // POS 
  rectWidth, rectHeight;       // SIZE 
 
  ClassRect (float x1_, float y1_, 
  float rectWidth_, float rectHeight_) 
  {
    // constr 
    x1=x1_;
    y1=y1_;
 
    rectWidth=rectWidth_;
    rectHeight=rectHeight_;
  } // constr
 
  void draw() {
    rect(x1, y1, rectWidth, rectHeight);
  }// method
} 