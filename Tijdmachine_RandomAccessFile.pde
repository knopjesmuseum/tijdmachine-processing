import java.io.RandomAccessFile;
import java.io.IOException;

RandomAccessFile file;

int w = 432;
int h = 192;
int bpp = 3;
int frameSize = w*h*bpp;
byte frame[] = new byte[frameSize];
int numFrames = 0;
boolean redraw = true;
int frameIndex;
int pframeIndex;
int speed = 1;
PImage img;
int leftFrame = 0;
int rightFrame = 0; //numFrames
Table config;
int curRow = 0;
boolean flip = true;

void setup() {
  size(384, 384);
  frameRate(30);
  config = loadTable("config.csv", "header");
  img = createImage(w, h, RGB);

  try {
    file = new RandomAccessFile(new File("/Volumes/tijdmachine/zaagsel.rgb"), "r");
    numFrames = getNumFrames();
    //println("numFrames: " + numFrames);
    rightFrame = numFrames;
    readFrame(0);
    drawFrame();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
  
  loadRow(0);
}

int getNumFrames() {
  try {
    long fileSize = file.length();
    return (int)(fileSize / frameSize);
  } 
  catch (IOException e) {
    e.printStackTrace();
    return 0;
  }
}

void readFrame(int frameIndex) {
  if (frameIndex<0 || frameIndex>=numFrames) return;
  try {
    long pos = (long)frameIndex * (long)frameSize;
    file.seek(pos);    
    file.read(frame);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}

void drawFrame() {
  int i=0;
  for (int y=0; y<h; y++) {
    for (int x=0; x<w; x++) {
      img.set(x, y, color(frame[i++] & 255, frame[i++] & 255, frame[i++] & 255));
    }
  }

  pushMatrix();
  translate(0, height);
  rotate(-PI/2);
  image(img, 0, 0);
  scale(1, -1);
  if (flip) image(img, 0, -height);
  popMatrix();
}

void draw() {
  frameIndex += speed;

  if (frameIndex<leftFrame+1) {
    frameIndex=leftFrame+1;
    speed = abs(speed);
    //println("bounce left, speed=" + speed);
  }

  if (frameIndex>=rightFrame) {
    frameIndex = rightFrame-1;
    speed = -abs(speed);
    //println("bounce right, speed=" + speed);
  }

  if (frameIndex!=pframeIndex) {
    readFrame((int)frameIndex);
    saveFrame();
    pframeIndex = frameIndex;
  }

  background(0);
  drawFrame();
  drawTimeline();
  drawTimeline();
  drawTimeline();  
}

void drawTimeline() {
  noStroke();
  fill(255,40);
  rect(0,8,width,1);
  fill(255);
  rect(toPixels(leftFrame),5,1,7);
  rect(toPixels(rightFrame),5,1,7);
  rect(toPixels(frameIndex)-1,5,1,7);
  stroke(255);
  line(toPixels(leftFrame),8,toPixels(rightFrame),8);
  //scale(1.2);
  text(abs(speed) + "x @ " + frameIndex,10,25);
  //text(abs(speed) + "x @ " + frameIndex,10,25);
}

float toPixels(int frame) {
  return map(frame, 0, numFrames, 0, width-1);
}

int toFrames(int pixel) {
  return (int)map(pixel, 0, width, 0, numFrames);
}

void mouseMoved() {
  pframeIndex = frameIndex;
  frameIndex = (int)map(mouseX, 0, width, 0, numFrames);
}

void mousePressed() {
  if (mouseButton==LEFT) leftFrame = (int)map(mouseX, 0, width, 0, numFrames);
  if (mouseButton==RIGHT) rightFrame = (int)map(mouseX, 0, width, 0, numFrames);
}

void mouseDragged() {
  mousePressed();
}

void keyPressed() {
  pframeIndex = frameIndex;
  if (key==',' || key=='-' || keyCode==LEFT) speed/=2;
  if (key=='.' || key=='=' || key=='+' || keyCode==RIGHT) { 
    if (speed<1 && speed>-1) speed=speed<0?-1:1 ; 
    else speed*=2;
  }
  if (key=='[') leftFrame=frameIndex;
  if (key==']') rightFrame=frameIndex;
  if (key=='r') speed*=-1; 
  if (key=='s') save();
  if (key=='n') loadRow(curRow+1);
  if (key>='0' && key<='9') loadRow(key-'0');
  if (key=='f') flip=!flip;
  //println("frameIndex: " + frameIndex);
  //println("speed: " + speed);
}

void loadRow(int index) {
  if (index>=config.getRowCount()) return;
  curRow = index;
  //println("loadRow " + index); 
  TableRow row = config.getRow(index);
  leftFrame = row.getInt("leftFrame");
  rightFrame = row.getInt("rightFrame");
  speed = row.getInt("speed");
  //println("leftFrame " + leftFrame);
  //println("rightFrame " + rightFrame);
  //frameIndex = constrain(frameIndex,leftFrame,rightFrame);
  //startTween();
}

void save() {
 TableRow row = config.addRow();
 row.setInt("leftFrame", leftFrame);
 row.setInt("rightFrame", rightFrame);
 row.setInt("speed", speed);
 saveTable(config, "config.csv");
 println("save");
}