import java.awt.AWTException;
import java.awt.Robot;
import oscP5.*;
OscP5 oscP5;

Robot robot;

//addons
Face face = new Face();
PFont font;
Vector<Graph> graphs;
int totalGraphs =3;
int[] triggerVals = new int[totalGraphs];
//addons

HashMap keyStrokes = new HashMap();

int rowCodeInt;
int numCommands = 6; //start with join
int numTriggers = 3; //start with eyebrowLeft;
float commandTime = 100;
float[][] timeEvents = new float[numTriggers][4]; 
//[0] -> exitTime, [1] -> enterTime, [2]->threshold, [3] ->ranCommand(1.0 or -1.0)
int[][] template = {
  {
    0, 0, 1 //join
  }
  , 
  {
    0, 0, -1 //explode
  }
  , {
    0, 1, 0 //group
  }
  , {
    0, -1, 0 //ungroup
  }
  , {
    1, 0, 0 //trim
  }
  , {
    -1, 0, 0 //split
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

  // ---addons
  size(500, 800);
  frameRate(60);


  oscP5 = new OscP5(this, 8338);

  reset();
  // ---addons

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

void reset() {
  graphs = new Vector<Graph>();
  //graphs.add(new Graph("poseScale"));
  //graphs.add(new Graph("mouthWidth"));
  //graphs.add(new Graph("mouthHeight"));
  //graphs.add(new Graph("eyeLeft/Right"));
  //graphs.add(new Graph("eyebrowLeft/Right"));
  //graphs.add(new Graph("jaw"));
  //graphs.add(new Graph("nostrils"));
  //graphs.add(new Graph("posePosition.x"));
  //graphs.add(new Graph("posePosition.y"));
  graphs.add(new Graph("poseOrientation.x"));
  graphs.add(new Graph("poseOrientation.y"));
  graphs.add(new Graph("poseOrientation.z"));

  graphs.get(0).relThreshold = .07;
  graphs.get(0).minTriggerTime = 100;
  graphs.get(0).maxTriggerTime = 2000;

  graphs.get(1).relThreshold = .07;
  graphs.get(1).minTriggerTime = 100;
  graphs.get(1).maxTriggerTime = 2000;

  graphs.get(2).relThreshold = .07;
  graphs.get(2).minTriggerTime = 100;
  graphs.get(2).maxTriggerTime = 2000;
}
//--------------------------------------------------------
void draw() {
  if (face.found > 0) {
    //graphs.get(0).add(face.poseScale);
    //graphs.get(0).add(face.mouthWidth);
    //graphs.get(1).add(face.mouthHeight);
    //graphs.get(0).add(face.eyeLeft + face.eyeRight);
    //graphs.get(1).add(face.eyebrowLeft + face.eyebrowRight);
    //graphs.get(2).add(face.jaw);
    //graphs.get(6).add(face.nostrils);
    //graphs.get(7).add(face.posePosition.x);
    //graphs.get(8).add(face.posePosition.y);
    graphs.get(0).add(face.poseOrientation.x);
    graphs.get(1).add(face.poseOrientation.y);
    graphs.get(2).add(face.poseOrientation.z);
  }

  background(255);  
  for (int i = 0; i < totalGraphs; i++) {
    Graph g = (Graph) graphs.get(i);
    g.keepSize(150); //150 data points for graph
    g.setFloats();
    g.setRecentMean();
    g.checkSign();
    g.markEnterExitTimes();
    triggerVals[i] = g.outputTriggerVal();

    g.draw(width, height / totalGraphs*8/10);
    translate(0, height / totalGraphs);
  }

  rowCodeInt = compareTriggerToTemplate(triggerVals, template);
  switch (rowCodeInt) {
  case 0:
    println("join");
    rhinoCommand("join");
    break;
  case 1:
    println("explode");
    rhinoCommand("explode");
    break;
  case 2:
    println("group");
    rhinoCommand("explode");
    break;
  case 3:
    println("ungroup");
    rhinoCommand("explode");
    break;
  case 4:
    println("trim");
    rhinoCommand("explode");
    break;
  case 5:
    println("split");
    rhinoCommand("explode");
    break;
  }

  //println(rowCodeInt);
}


// OSC CALLBACK FUNCTIONS

void oscEvent(OscMessage m) {
  face.parseOSC(m);
}



//--------------------------------------------------------

int compareTriggerToTemplate(int[] triggers, int[][]template) {
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
    if (i>=numCommands) {
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
      if (j==triggers.length) {
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
  //for row: [0]->exitTime,[1]->enterTime,[2]->threshold,[3]-> (-1 or 1)
  //output: array called triggers[] which contains booleans for
  //for each trigger
  boolean[] triggers = new boolean[numTriggers];

  for (int i =0; i< numCommands; i++) {
    float threshold = timeEvents[i][2];
    if (faceParamValue[i] >= threshold) {
      //exitTime
      timeEvents[i][0] = millis();
    }
    else {
      //enterTime
      timeEvents[i][1] = millis();
    }
    boolean run = wasTrigger(timeEvents[i][0], timeEvents[i][1], timeEvents[i][3], i);
    if (run) {
      triggers[i] = true;
    }
    else {
      triggers[i] = false;
    }
  }
  return triggers;
}

boolean wasTrigger(float exitTime, float enterTime, float ranC, int i ) {
  //checks two times, one for the time when the signal went above a threshold, 
  //one for the time when the signal went below the threshold, and outputs boolean
  //based on if it can be considerred a trigger. by default returns false

  float tDiff = enterTime-exitTime;
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

