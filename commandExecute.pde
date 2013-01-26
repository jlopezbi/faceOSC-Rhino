import java.awt.AWTException;
import java.awt.Robot;
import oscP5.*;
OscP5 oscP5;

Robot robot;

HashMap keyStrokes = new HashMap();

int rowCodeInt;
int numCommands = 1; //start with join
int numTriggers = 1; //start with eyebrowLeft;
float commandTime = 100;
float[][] timeEvents = new float[numTriggers][4]; 
//[0] -> upTime, [1] -> downTime, [2]->threshold, [3] ->ranCommand(1.0 or -1.0)
 boolean[][] template = {
  {
    true
  }
  , 
  {
    false
  }
};
boolean[] triggers = new boolean[numTriggers];
float[] faceParamValue = new float[numTriggers];
float[] thresholds = new float[numTriggers];

// num faces found
int found;
// pose
PVector poseOrientation = new PVector();
// gesture
/*float eyeLeft;
 float thresholdEL;
 float eyebrowLeft;
 float thresholdEBL = 8.8;*/
 
 
//-----------------------------------------------------
void setup() {
  oscP5 = new OscP5(this, 8338);
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
  //INTIALIZE VALUES IN ARRAYS
  timeEvents[0][2] = 8.8;
  timeEvents[0][3] = -1.0;
 

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
  if (found>0) {
    triggers = checkTriggers(timeEvents, faceParamValue);
    rowCodeInt = compareTriggerToTemplate(triggers,template);
    switch (rowCodeInt){
      case 0:
      rhinoCommand("join");
      break;
      case 1:
      break;
    }
    
    println(rowCodeInt);
  }
}





//--------------------------------------------------------

int compareTriggerToTemplate(boolean[] triggers, boolean[][]template) {
  // need to test
  // compares trigger array to template array, in which each row index
  // corresponds to a command.
  // input: array of booleans (triggers) and compares them
  // ouput: int that is the index of the match, or -1 if no match

  int indexOfMatch = -1;
  int i = 0;
  boolean lookingForMatch = true;
  
  assert(triggers.length == template[0].length);
  
  while (lookingForMatch) {
    if (i>numCommands) {
     break;
    }
    
    int j=0;
    boolean isMatching = true;
    while (isMatching) {
      if (triggers[j] != template[i][j]) {
        //println("i= " +i+ "j= "+ j);
        //println("!equal "+triggers[j]+" != "+template[i][j]);
        isMatching = false;
      } 
      else {
        j+=1;
      }
      if (j==numTriggers) {
        //found match!
        indexOfMatch = i;
        return indexOfMatch;
      }
    }
    i+=1;
  }
  return indexOfMatch;
}


boolean[] checkTriggers(float[][] timeEvents, float[]faceParamValue) { 
  //input: array called timeEvents 
  //for row: [0]->upTime,[1]->downTime,[2]->threshold,[3]-> (-1 or 1)
  //output: array called triggers[] which contains booleans for
  //for each trigger
  boolean[] triggers = new boolean[numTriggers];

  for (int i =0; i< numCommands; i++) {
    float threshold = timeEvents[i][2];
    if (faceParamValue[i] >= threshold) {
      //upTime
      timeEvents[i][0] = millis();
    }
    else {
      //downTime
      timeEvents[i][1] = millis();
    }
    boolean run = wasTrigger(timeEvents[i][0], timeEvents[i][1], timeEvents[i][3],i);
    if (run) {
      triggers[i] = true;
    }
    else {
      triggers[i] = false;
    }
  }
  return triggers;
}

boolean wasTrigger(float upTime, float downTime, float ranC, int i ) {
  //checks two times, one for the time when the signal went above a threshold, 
  //one for the time when the signal went below the threshold, and outputs boolean
  //based on if it can be considerred a trigger. by default returns false

  float tDiff = downTime-upTime;
  if (tDiff>0 && tDiff < commandTime) {
    if (ranC < 0 ) {
      timeEvents[i][3] = 1.0;
      return true;
    }
    else {
      return false;
    }
  }
  else if (tDiff > commandTime) {
    timeEvents[i][3] = -1.0;
    return false;
  }
  return false;
}

void rhinoCommand(String commandStr) {
  //works fine
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
  faceParamValue[0] = f;
}
public void eyeLeftReceived(float f) {
  //println("eye left: " + f);
  //eyeLeft = f;
}

