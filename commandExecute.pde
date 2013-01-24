import java.awt.AWTException;
import java.awt.Robot;

Robot robot;

HashMap keyStrokes = new HashMap();
String commandStr = "join";
String execute = "return";
int lenStr = commandStr.length();
int enterVal = 13;

float pauseTime = 1000;
float currTime;
float startTime;
int e  = 90;

void setup() {
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

  //size(400, 400);
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  startTime = millis();
}

void draw() {
  currTime = millis();
  if (currTime-startTime > pauseTime) {
    rhinoCommand("join");
    robot.keyPress(KeyEvent.VK_ENTER);
    robot.keyRelease(KeyEvent.VK_ENTER);
    println("fired");
    startTime = currTime;
  }
}

void keyPressed() {
  if (key == 'g') {

    println("asdfasdf!!");
  }
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
      println(currLetter + " = " + value);
    }
  }
}

