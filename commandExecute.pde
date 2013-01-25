import java.awt.AWTException;
import java.awt.Robot;
import oscP5.*;
OscP5 oscP5;

Robot robot;

HashMap keyStrokes = new HashMap();
String commandStr = "join";
String execute = "return";
int lenStr = commandStr.length();
int enterVal = 13;

float commandTime = 100;
float timeAbove;
float timeBelow;
boolean ranCommand = false;

// num faces found
int found;
// pose
PVector poseOrientation = new PVector();
// gesture
float eyeLeft;
float thresholdEL;
float eyebrowLeft;
float thresholdEBL = 8.8;
//-----------------------------------------------------
void setup() {
  oscP5 = new OscP5(this,8338);
  oscP5.plug(this, "found", "/found");
  oscP5.plug(this, "poseOrientation", "/pose/orientation");
  oscP5.plug(this, "eyeLeftReceived", "/gesture/eye/left");
  oscP5.plug(this, "eyebrowLeftReceived", "/gesture/eyebrow/left");
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
  }
  poseOrientation = new PVector();

  keyStrokes.put('a', 65);
  keyStrokes.put('b', 66);
  keyStrokes.put('c', 67);
  keyStrokes.put('d', 68);
  keyStrokes.put('e', 69);
  keyStrokes.put('f', 70);
  keyStrokes.put('g', 71);
  keyStrokes.put('h', 72);
  keyStrokes.put('i', 73);
  keyStrokes.put('j', 74);
  keyStrokes.put('k', 75);
  keyStrokes.put('l', 76);
  keyStrokes.put('m', 77);
  keyStrokes.put('n', 78);
  keyStrokes.put('o', 79);
  keyStrokes.put('p', 80);
  keyStrokes.put('q', 81);
  keyStrokes.put('r', 82);
  keyStrokes.put('s', 83);
  keyStrokes.put('t', 84);
  keyStrokes.put('u', 85);
  keyStrokes.put('v', 86);
  keyStrokes.put('w', 87);
  keyStrokes.put('x', 88);
  keyStrokes.put('y', 89);
  keyStrokes.put('z', 90);

}

//--------------------------------------------------------
void draw() {
  //currTime = millis();
  if(found>0){
    if(eyebrowLeft >= thresholdEBL){
      timeAbove = millis();
    } else if (eyebrowLeft < thresholdEBL){
      timeBelow = millis();
    }
    float timeDiff = timeBelow-timeAbove;
    if(timeDiff > 0 && timeDiff <= commandTime){
      if(!ranCommand){
      println("eyebrowLeft went UP!!!!!!");
      rhinoCommand("join");
      ranCommand = true;
      }
      
    }else if(timeDiff>commandTime){
      ranCommand = false;
    }
    
  }
  
  
  /*if (currTime-startTime > pauseTime) {
    rhinoCommand("explode");
    robot.keyPress(KeyEvent.VK_ENTER);
    robot.keyRelease(KeyEvent.VK_ENTER);
    println("fired");
    startTime = currTime;
  }*/
}

void rhinoCommand(String commandStr) {
  int lenStr = commandStr.length();
  for (int i = 0; i<lenStr; i++) {
    int value;
    char currLetter = commandStr.charAt(i);
    if (keyStrokes.containsKey(currLetter)) {
      Integer j = (Integer) keyStrokes.get(currLetter);
      value = j.intValue();
      robot.keyPress(value);
      robot.keyRelease(value);
      //println(currLetter + " = " + value);
    }
  }
  robot.keyPress(KeyEvent.VK_ENTER);
  robot.keyRelease(KeyEvent.VK_ENTER);
}
//OSC CALLBACK FUNCTIONS

public void found(int i) {
  //println("found: " + i);
  found = i;
}
public void eyebrowLeftReceived(float f) {
  //println("eyebrow left: " + f);
  eyebrowLeft = f;
}
public void eyeLeftReceived(float f) {
  println("eye left: " + f);
  eyeLeft = f;
}

