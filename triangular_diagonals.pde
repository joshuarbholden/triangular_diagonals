// Global parameters //<>// //<>// //<>// //<>//

int blockwidth = 48;
int blockheight = 72;

int numcols = 4;
int radius = 0;
int maxtwist = 4;

int yOffset = 2;

int yLength = 32;

Column[] columns = new Column[numcols];


void setup() {

  smooth();
  // size(384, 864);
  size(3000, 2000);
  //fullScreen();
  imageMode(CORNERS);
  // Parameters go inside the parentheses when the object is constructed.
  for (int i = 0; i < numcols; i = i+1) {
    columns[i] = new Column(i, color(255, 255, 0), color(50, 100, 50), i*blockwidth, (2*numcols-i)*blockwidth, 0, yOffset*blockheight, (yLength+0.5)*blockheight-1);
    println(columns[i].ypos, columns[i].yflipped, columns[i].yend, columns[i].yflippedend);
  }
  noLoop();
}


void draw() {
  for (int i = 0; i < numcols; i = i+1) {
    if ((columns[i].stepnum % 2) == 0) {
      columns[i].setTwist();
    }
    columns[i].step();
    println(columns[i].ypos, columns[i].yflipped, columns[i].yend, columns[i].yflippedend);
    if (columns[i].ypos < columns[i].yend-blockheight) {     
      columns[i].leftDisplay();
      columns[i].rightDisplay();
    } else
    {
      noLoop();
    }
  }
  noLoop();
}

void keyPressed() {
  if (key == 'q') {
    exit();
  } else if (key == 's') {
    noLoop();
  } else
    loop();
}

void parallelogram(float x, float y, float x1, float y1, float x2, float y2) {
  quad(x, y, x+x1, y+y1, x+x1+x2, y+y1+y2, x+x2, y+y2);
}


// Even though there are multiple objects, we still only need one class. 
// No matter how many cookies we make, only one cookie cutter is needed.
class Column { 
  int index;
  int stepnum = 0;
  color BG, FG;  
  float xpos, xflipped, ypos, yflipped;
  float xend, xflippedend, yend, yflippedend;
  int twist;
  int effectiveTwist;
  boolean Zslash;

  // The Constructor is defined with arguments.
  Column(int tempIndex, color tempBG, color tempFG, float tempXpos, float tempXflipped, float tempYpos, float tempYflipped, float tempYend) { 
    index = tempIndex;  
    BG = tempBG;
    FG = tempFG; 
    xpos = tempXpos;
    xflipped = tempXflipped;
    ypos = 2*tempYpos-tempYflipped-blockheight; //backup so that dummy fill doesn't show and one more for fencepost
    yflipped = tempYpos-blockheight; //start dummy fill one before for fencepost
    yflippedend = tempYend - tempYpos + tempYflipped + blockheight; //reverse backup so that dummy fill doesn't show and one more for fencepost
    yend = tempYend + blockheight; //start dummy fill one (reverse before) for fencepost
    twist = 0;
    effectiveTwist = 0;
    while (ypos < tempYpos-blockheight) {
      Zslash = true;
      step();
      rightDisplay();
      println(index, ypos, yflipped, yend, yflippedend);
      Zslash = false;
      step();
      rightDisplay();
      println(index, ypos, yflipped, yend, yflippedend);
    }
  }



  float threshhold(int twistVal) {
    return 0.5-(0.5/maxtwist)*twistVal;
    // return 0;
  }

  int nbhdTwist(int radiusVal) {
    int normTwist =  0;
    for (int i = index - radiusVal; i <= index + radiusVal; i = i+1) {
      normTwist = normTwist + abs(columns[(i % numcols + numcols) % numcols].twist);    // compensate for stupid Java %
    }
    return normTwist*Integer.signum(twist);
  }

  void setTwist() {
    effectiveTwist = nbhdTwist(radius);
    if (random(0, 1)<threshhold(effectiveTwist)) {
      // if (floor(stepnum)/4 % 2 == 0) {  
      Zslash = true;
      twist = twist + 1;
    } else {
      Zslash = false;
      twist = twist - 1;
    }
  }

  void step() {
    ypos = ypos + blockheight;
    yflipped = yflipped + blockheight;
    yend = yend - blockheight;
    yflippedend = yflippedend - blockheight;
    stepnum = stepnum + 1;
    println(Yadjusted(xpos, ypos), Yadjusted(xpos, yend));
  }


  float Xadjusted(float X, float Y) {
    float adjustedHeight = (floor(height/blockheight)-2)*blockheight;
    return X + floor(Y/adjustedHeight) * (2*numcols+1)*blockwidth;
  }

  float Yadjusted(float X, float Y) {
    float adjustedHeight = (floor(height/blockheight)-2)*blockheight;
    return Y % adjustedHeight+1.5*blockheight;
  }

  void twotwoblock(float xpos, float ypos, int xdir, int ydir) {
    strokeWeight(1);
    if (Zslash) {
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(FG);  
        stroke(BG);
      } else {
        fill(BG);
        stroke(FG);
      }
      parallelogram(xpos+xdir*blockwidth/2, ypos+ydir*blockheight/2, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //little 
      parallelogram(xpos+xdir*blockwidth/2, ypos, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //little     
      parallelogram(xpos, ypos, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //little
      //  noStroke();
      // fill(255, 0, 0); // testing
      parallelogram(xpos+xdir*blockwidth/2, ypos+ydir*blockheight, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //background
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(BG);  
        stroke(FG);
      } else {
        fill(FG);
        stroke(BG);
      }
      parallelogram(xpos, ypos+ydir*blockheight/2, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //little 
      //    noStroke();  
      //  fill(255, 0, 0); // testing
      parallelogram(xpos, ypos+ydir*blockheight, xdir*blockwidth/2, ydir*blockheight/2, 0, ydir*blockheight/2); //background
    } else {  //Zslash is false
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(FG);  
        stroke(BG);
      } else {
        fill(BG);
        stroke(FG);
      }
      parallelogram(xpos+xdir*blockwidth/2, ypos+ydir*blockheight/2, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); //little 
      parallelogram(xpos, ypos+ydir*blockheight, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); //little 
      parallelogram(xpos+xdir*blockwidth/2, ypos+ydir*blockheight, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); //little 
      //   noStroke();  
      // fill(255,0,0); // testing
      parallelogram(xpos+xdir*blockwidth/2, ypos+3*ydir*blockheight/2, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); // background 
      //  fill(255,0,0); // testing
      parallelogram(xpos, ypos+3*ydir*blockheight/2, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); // background
      if ((stepnum + index + ((Zslash) ? 1 : 0)) % 2 == 0) {  //cast boolean Zslash to integer
        fill(BG);  
        stroke(FG);
      } else {
        fill(FG);
        stroke(BG);
      }
      parallelogram(xpos, ypos+ydir*blockheight/2, xdir*blockwidth/2, -ydir*blockheight/2, 0, ydir*blockheight/2); //little
    }
  }

  void leftDisplay() {
    float xpos = Xadjusted(this.xpos, this.ypos);
    float ypos = Yadjusted(this.xpos, this.ypos);
    float yend = Yadjusted(this.xpos, this.yend);
    float xflipped = Xadjusted(this.xflipped, this.yflippedend);
    float yflipped = Yadjusted(this.xflipped, this.yflipped);
    float yflippedend = Yadjusted(this.xflipped, this.yflippedend);
    if (this.yend-this.ypos<3*blockheight) {
      clip(0, 0, width, (ypos+yend)/2);
    }
    twotwoblock(xpos, ypos, 1, 1);
    if (this.yend-this.ypos<3*blockheight) {
      clip(0, (yflipped+yflippedend)/2, width, height);
    }
    twotwoblock(xflipped, yflippedend, -1, -1);
    noClip();
    fill(FG);
    textSize(24);  
    //textAlign(LEFT, BOTTOM);
    //text(str(twist), xpos, ypos+blockheight);
    //textAlign(RIGHT, BOTTOM);
    //text(str(effectiveTwist), xpos+blockwidth, ypos+blockheight);
  }

  void rightDisplay() {
    float xpos = Xadjusted(this.xpos, this.yend);
    float ypos = Yadjusted(this.xpos, this.ypos);
    float yend = Yadjusted(this.xpos, this.yend);
    float xflipped = Xadjusted(this.xflipped, this.yflipped);
    float yflipped = Yadjusted(this.xflipped, this.yflipped);
    float yflippedend = Yadjusted(this.xflipped, this.yflippedend);
    if (this.yend-this.ypos<3*blockheight) {
      clip(0, 0, width, (yflipped+yflippedend)/2);
    }
    twotwoblock(xflipped, yflipped, -1, 1);
    if (this.yend-this.ypos<3*blockheight) {
      clip(0, (ypos+yend)/2, width, height);
    }
    twotwoblock(xpos, yend, 1, -1);
    noClip();
  }
}
