ClassRect lines [] = new ClassRect [1];  
 
boolean take1, take2; 
 
void setup()
{
  size(640, 560);
  background(111);
  lines [0] = new ClassRect  (  111, 122, 222, 333  );
}
 
void draw()
{ 
  background(111);
 
  stroke(0);
 
  text ("upper left corner: drag the box around \n"
    +"Lower right corner: resize ", 30, 30);
 
  lines [0].draw();
 
  if (take1) {
    lines[0].x1=mouseX;
    lines[0].y1=mouseY;
  }
 
  if (take2) {
    lines[0].rectWidth=mouseX-lines[0].x1;
    lines[0].rectHeight=mouseY-lines[0].y1;
  }
} // func 
 
void mousePressed() {
  // upper left corner 
  if (dist (lines[0].x1, 
  lines[0].y1, mouseX, mouseY) < 12) {
    take1=true;
  }
  // Lower right corner 
  else if (dist (lines[0].x1+lines[0].rectWidth, 
  lines[0].y1+lines[0].rectHeight, mouseX, mouseY) < 12) {
    take2=true;
  }
}
 
void mouseReleased() {
  take1=false;
  take2=false;
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
} // 
 
//