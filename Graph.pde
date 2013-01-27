int recent = 300;
int minAdapt = 2;
int maxAdapt = 100;
int sizeLimit = 30;

class Graph extends ArrayList {
  float maxValue, minValue;
  boolean watching;
  String name;

  float baseLine, relThreshold;
  float maxTriggerTime, minTriggerTime;
  float exitTime, returnTime;
  boolean wasNegative;
  boolean didTrigger = false;


  Graph(String name) {
    this.name = name;
    this.watching = true;
    this.maxValue = Float.NEGATIVE_INFINITY;
    this.minValue = Float.POSITIVE_INFINITY;
  }
  void add(float value) {
    if (watching) {
      if (value == Float.NEGATIVE_INFINITY ||
        value == Float.POSITIVE_INFINITY ||
        value != value)
        return;
      if (value > maxValue)
        maxValue = value;
      if (value < minValue)
        minValue = value;
    }
    super.add(value);
  }
  void keepSize(int sizeLimit) {
    if (size()==sizeLimit) {
      super.remove(0);
    }
  }
  float getFloat(int i) {
    if (size() == 0)
      return 0;
    return ((Float) super.get(i)).floatValue();
  }
  float getLastFloat() {
    return getFloat(size() - 1);
  }
  float getPreviousFloat() {
    if (size()<2) {
      return 0;
    }
    return getFloat(size() - 2);
  }
  float normalize(float x) {
    return constrain(norm(x, minValue, maxValue), 0, 1);
  }
  float getNorm(int i) {
    return normalize(getFloat(i));
  }
  float getLastNorm() {
    return getNorm(size() - 1);
  }
  float getLinear(int i) {
    return sqrt(1. / getNorm(i));
  }
  float getLastLinear() {
    return getLinear(size() - 1);
  }
  float mean() {
    float sum = 0;
    for (int i = 0; i < size(); i++)
      sum += getFloat(i);
    return sum / size();
  }
  float recentMean() {
    float mean = 0;
    int n = min(size(), recent);
    for (int i = 0; i < n; i++)
      mean += getFloat(size() - i - 1);
    return mean / n;
  }
  float recentMedian() {
    float[] recentValues = new float[recent];
    int n = min(size(), recent);
    for (int i=0; i< n;i++) {
      recentValues[i] = getFloat(size()-i-1);
    }
    sort(recentValues);
    return(recentValues[recent/2]);
  }
  void setRelThreshold(float thresh) {
    relThreshold = thresh;
  }

  int inBase(float value) {
    // 0 for in base, 1 for above threshold upper,
    // -1 for below thrshold lower, 5 for error
    float threshold = recentMean()+relThreshold;
    if (abs(value)<threshold) {
      return 0;
    } 
    else if (value>=threshold) {
      return 1;
    } 
    else if (value<=-1.0 * threshold) {
      return -1;
    } 
    else {
      return 5;
    }
  }

  boolean isOutside() {
    float currValDist = abs(getLastFloat()-recentMean());
    return(currValDist > relThreshold);
  }

  void checkSign() {
    float lastFloat = getLastFloat();
    float baseLine = recentMean();
    if (lastFloat<baseLine) {
      wasNegative = true;
    }
    else {
      wasNegative = false;
    }
  }

  void markEnterExitTimes() {
    int currPos = inBase(getLastFloat());
    int prevPos = inBase(getPreviousFloat());
    if (currPos == 0) {
      if (prevPos == 1) {
        returnTime = millis();
        wasNegative = false;
      } 
      else if (prevPos == -1) {
        returnTime = millis();
        wasNegative = true;
      }
    }
    else if (currPos == 1 && prevPos == 0) {
      exitTime = millis();
    }else if (currPos == 1 && prevPos == -1){
      //??
    }
    
    else if(currPos == -1 && prevPos == 1){
      //??
    }
    else if (currPos == -1 && prevPos == 0) {
      exitTime = millis();
    }
  }

  int outputTriggerVal() {
    // -1 for a down trigger, 1 for a up trigger, 0 for no trigger
    float timeDiff = returnTime-exitTime;
    if (millis()-returnTime < 5) {
      if (timeDiff < maxTriggerTime ) {
        didTrigger =true;
        if (wasNegative) {
          return -1;
        }
        else {
          return 1;
        }
      }
      else {
        didTrigger =false;
        return 0;
      }
    }
    else {
      didTrigger =false;
      return 0;
    }
  }



  void draw(int width, int height) {
    float baseLine = recentMean();
    fill(getNorm(size() - 1) * 255);
    //rect(0, 0, width, height);

    fill(0);
    stroke(0);



    //RECENT MEAN IS ORANGE
    textAlign(LEFT, CENTER);
    float rMeanPos = height - normalize(baseLine) * height;  
    text(nf(getLastFloat(), 0, 0) + " " + name, 10, rMeanPos);
    stroke(247, 165, 20);
    line(0, rMeanPos, width, rMeanPos);

    //MEDIAN IS PINK
    /*
    float rMedian = recentMedian();
    float rMedianPos = height-normalize(rMedian) * height;
    text(nf(rMedian, 0, 0) + " " + name, 10, rMedianPos);
    stroke(255, 0, 255);
    line(0,rMedianPos,width,rMedianPos);
*/
    //PINK negative, REd positive
    strokeWeight(4);
    if (wasNegative) {
      stroke(255, 0, 255);
    }
    else {
      stroke(247, 10, 10);
    }



    //GReen for trigger!
    if (didTrigger) {
      fill(97, 232, 2);
    }

    ellipse(10, 10, 35, 35);
    strokeWeight(1);
    
    //DRAW MIN AND MAX TRIGGER TIMES,and refrence line
    float pixPerMilli = .025;
    float xRef = 30;
    stroke(0);
    line(xRef, 0, xRef, height);
    noStroke();
    fill(100, 100, 100, 60);
    rectMode(CORNER);
    rect(xRef+minTriggerTime*pixPerMilli, 0, 
    (maxTriggerTime)*pixPerMilli, height);

    //THRESHOLDS ARE BLUE
    if (relThreshold !=0.0) {
      //println("threshold for " + name+" = "+ threshold);
      stroke(10, 210, 247);
      float threshAbove = baseLine+relThreshold;
      float threshAbovePos = height-normalize(threshAbove)*height;
      line(0, threshAbovePos, width, threshAbovePos);
      float threshBelow = baseLine-relThreshold;
      float threshBelowPos = height-normalize(threshBelow)*height;
      line(0, threshBelowPos, width, threshBelowPos);
    }
    stroke(0);
    textAlign(LEFT, TOP);
    text(nf(minValue, 0, 0), width - 20, height - 20);

    //DRAW GRAPH
    noFill();
    beginShape();
    //vertex(0, height);
    for (int i = 0; i < width && i < size(); i++) {
      stroke(0);
      int position = size() - i - 1;
      vertex(i, height - getNorm(position) * height);
      strokeWeight(1);
      ellipse(i, height - getNorm(position) * height, 5, 5);
    }
    //vertex(width, height);
    endShape();

    fill(0);
    textAlign(LEFT, BOTTOM);
    text(nf(maxValue, 0, 0), width - 20, 20);

    noFill();
    stroke(26, 170, 18);
    if (true) {
      float yPos = height-normalize(0)*height;
      line(0, yPos, width, yPos);
    }
  }
  void save(String filename) {
    String[] out = new String[size()];
    for (int i = 0; i < size(); i++) 
      out[i] = nf(getFloat(i), 0, 0);
    saveStrings(filename + ".csv", out);
  }
}

