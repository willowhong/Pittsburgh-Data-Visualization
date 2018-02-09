import processing.serial.*;
import cc.arduino.*;
import oscP5.*;
import netP5.*;
import controlP5.*;


//PImage map;
int maxFrameCount = 100;
float t;
int col;
int alpha1 = 0;
int alpha2 = 0;
int alpha3 = 0;
int alpha4 = 0;
int alpha5 = 0;
int xshift = 0; // change this number to shift all x, -1000 or 0 
int yshift = 0; // change this number to shift all y, -400 or 0
int xzoom = 20; // change this number to zoom all x, 70 or 20
int yzoom = 20; // change this number to zoom all y, 70 or 20

Table stepstable;
FloatList stepxlist;
FloatList stepylist;
FloatList steplenlist;
float steplatitude;
float steplongitude;
float stepx;
float stepy;
float steplen;

Table wallstable;
FloatList wallxlist;
FloatList wallylist;
FloatList wallheilist;
float walllatitude;
float walllongitude;
float wallx;
float wally;
float wallhei;

Table bridgestable;
FloatList bridgexlist;
FloatList bridgeylist;
FloatList bridgeyrlist;
float bridgelatitude;
float bridgelongitude;
float bridgex;
float bridgey;
float bridgeyr;

Table fishtable;
FloatList fishxlist;
FloatList fishylist;
float fishlatitude;
float fishlongitude;
float fishx;
float fishy;

Table hillstable;
FloatList hillxlist;
FloatList hillylist;
FloatList hillgradelist;
float hilllatitude;
float hilllongitude;
float hillx;
float hilly;
float hillgrade;

void setup() { 
  //map = loadImage("map.jpg");
  size(800, 800);
  frameRate(30);
  colorMode(RGB);
  ellipseMode(CENTER);
  rectMode(CENTER);
  
  stepstable = loadTable("Steps.csv", "header");
  stepxlist = new FloatList();
  stepylist = new FloatList();
  for (TableRow row: stepstable.rows()) {
    steplongitude = Float.parseFloat(row.getString("longitude"));  
    stepx = (steplongitude - (-80.082019))/(2.0*PI);
    while (stepx < 0) {stepx++;}
    while (stepx > 1) {stepx--;}
    stepx = (stepx*1000)*xzoom + xshift;
    stepxlist.append(stepx);
    steplatitude = Float.parseFloat(row.getString("latitude"));
    stepy = ((float)((5.0/4.0) * Math.log(Math.tan((QUARTER_PI + (2.0/5.0) * (double)steplatitude)))))/TWO_PI;
    stepy = ((1 - (stepy+0.5))*1000-263)*yzoom + yshift; 
    stepylist.append(stepy);
  } 
  steplenlist = new FloatList();
  for (TableRow row: stepstable.rows()) {
    steplen = (float)row.getInt("length"); 
    steplen = steplen * 0.1;
    steplenlist.append(steplen);
  }
  
  wallstable = loadTable("Walls.csv", "header");
  wallxlist = new FloatList();
  wallylist = new FloatList();
  for (TableRow row: wallstable.rows()) {
    walllongitude = Float.parseFloat(row.getString("longitude"));  
    wallx = (walllongitude - (-80.082019))/(2.0*PI);
    while (wallx < 0) {wallx++;}
    while (wallx > 1) {wallx--;}
    wallx = (wallx*1000)*xzoom + xshift;
    wallxlist.append(wallx);
    walllatitude = Float.parseFloat(row.getString("latitude"));
    wally = ((float)((5.0/4.0) * Math.log(Math.tan((QUARTER_PI + (2.0/5.0) * (double)walllatitude)))))/TWO_PI;
    wally = ((1 - (wally+0.5))*1000-263)*yzoom + yshift; 
    wallylist.append(wally);
  }
  wallheilist = new FloatList();
  for (TableRow row: wallstable.rows()) {
    wallhei = (float)row.getInt("height"); 
    wallheilist.append(wallhei);
  }
  
    bridgestable = loadTable("Bridges.csv", "header");
    bridgexlist = new FloatList();
    bridgeylist = new FloatList();
    for (TableRow row: bridgestable.rows()) {
    bridgelongitude = Float.parseFloat(row.getString("longitude"));  
    bridgex = (bridgelongitude - (-80.082019))/(2.0*PI);
    while (bridgex < 0) {bridgex++;}
    while (bridgex > 1) {bridgex--;}
    bridgex = (bridgex*1000)*xzoom + xshift;
    bridgexlist.append(bridgex);
    bridgelatitude = Float.parseFloat(row.getString("latitude"));
    bridgey = ((float)((5.0/4.0) * Math.log(Math.tan((QUARTER_PI + (2.0/5.0) * (double)bridgelatitude)))))/TWO_PI;
    bridgey = ((1 - (bridgey+0.5))*1000-263)*yzoom + yshift; 
    bridgeylist.append(bridgey);
  }
  bridgeyrlist = new FloatList();
  for (TableRow row: bridgestable.rows()) {
    bridgeyr = (float)row.getInt("built"); 
    bridgeyrlist.append(bridgeyr);  
}
    
    fishtable = loadTable("Fishfry.csv", "header");
    fishxlist = new FloatList();
    fishylist = new FloatList();
    for (TableRow row: fishtable.rows()) {
    fishlongitude = Float.parseFloat(row.getString("longitude"));  
    fishx = (fishlongitude - (-80.082019))/(2.0*PI);
    while (fishx < 0) {fishx++;}
    while (fishx > 1) {fishx--;}
    fishx = (fishx*1000)*xzoom + xshift;
    fishxlist.append(fishx);
    fishlatitude = Float.parseFloat(row.getString("latitude"));
    fishy = ((float)((5.0/4.0) * Math.log(Math.tan((QUARTER_PI + (2.0/5.0) * (double)fishlatitude)))))/TWO_PI;
    fishy = ((1 - (fishy+0.5))*1000-263)*yzoom + yshift; 
    fishylist.append(fishy);
  }
  
  hillstable = loadTable("Hills.csv", "header");  
  hillxlist = new FloatList();
  hillylist = new FloatList();
  for (TableRow row: hillstable.rows()) {
    hilllongitude = Float.parseFloat(row.getString("longitude"));  
    hillx = (hilllongitude - (-80.082019))/(2.0*PI);
    while (hillx < 0) {hillx++;}
    while (hillx > 1) {hillx--;}
    hillx = (hillx*1000)*xzoom + xshift;
    hillxlist.append(hillx);
    hilllatitude = Float.parseFloat(row.getString("latitude"));
    hilly = ((float)((5.0/4.0) * Math.log(Math.tan((QUARTER_PI + (2.0/5.0) * (double)hilllatitude)))))/TWO_PI;
    hilly = ((1 - (hilly+0.5))*1000-263)*yzoom + yshift; 
    hillylist.append(hilly);
  }  
  hillgradelist = new FloatList();
  for (TableRow row: hillstable.rows()) {
    hillgrade = row.getFloat("grade"); 
    hillgradelist.append(hillgrade);
  }

}


void draw() {
  background(0);
  t = (float)frameCount/maxFrameCount * TWO_PI;
  Step steps = new Step();
  steps.draw();
  Wall walls = new Wall();
  walls.draw();
  Bridge bridges = new Bridge();
  bridges.draw();
  Fishfry fishfry = new Fishfry();
  fishfry.draw();
  Hill hills = new Hill();
  hills.draw();
  
  
  //image(map, 0, -40, width/1.15, height/1.15);
  //filter(BLUR,2);
}

void keyPressed(){
  if(key == 'q'){ //steps
    alpha1 = 50;
  }
  if(key == 'a'){ //steps
    alpha1 = 0;
  }
  if(key == 'w'){ //walls
    alpha2 = 100;
  }
    if(key == 's'){ //walls
    alpha2 = 0;
  }
    if(key == 'e'){ //walls
    alpha3 = 200;
  }
    if(key == 'd'){ //walls
    alpha3 = 0;
    }
    if(key == 'r'){ //walls
    alpha4 = 200;
  }
    if(key == 'f'){ //walls
    alpha4 = 0;
  }
      if(key == 't'){ //walls
    alpha5 = 100;
  }
    if(key == 'g'){ //walls
    alpha5 = 0;
  }
}

class Step{
  void draw(){
  for (int i = 0; i < stepxlist.size(); i=i+1){
    noStroke();
    fill(50,10,150,alpha1);
    float size = map(sin(t),-1,1,steplenlist.get(i),steplenlist.get(i)+20);
    ellipse(stepxlist.get(i),stepylist.get(i), size,size);
    }
  }
}

class Wall{
  void draw(){
 for (int i = 0; i < wallxlist.size(); i=i+1){
    col = (int)(map(sin(t),-1,1,wallheilist.get(i),pow((wallheilist.get(i)),2.5)));
    noStroke();
    fill(25,col+50,150,alpha2);
    ellipse(wallxlist.get(i),wallylist.get(i), 15,15);      
    }
  }
}

class Bridge{
  void draw(){
 for (int i = 0; i < bridgexlist.size(); i=i+1){
   float x1 = bridgexlist.get(i);
   float y1 = bridgeylist.get(i);
   float offset = map(bridgeyrlist.get(i),1886, 2017, 0,2*PI);
   float w1 = map(cos(-t+offset),-1,1,1,30);
   float h1 = 5;
   fill(255,255,0,alpha3);
   rect(x1,y1,w1,h1);
    }
  }
}

class Fishfry{
  void draw(){
 for (int i = 0; i < fishxlist.size(); i=i+1){
   fill(148,0,211, alpha4);
   rect(fishxlist.get(i),fishylist.get(i),10,10);
    }
  }
}

class Hill{
  void draw(){
 for (int i = 0; i < hillxlist.size(); i=i+1){
   fill(214,160,234, alpha5);
   float factor = map(hillgradelist.get(i), 9.52, 37.0, 0, 1);
   float stop = map(sin(t),-1,1,0,factor*HALF_PI);
   arc(hillxlist.get(i),hillylist.get(i),50,50,(-stop),0);
    }
  }
}