/*
left-right keys for switching presentations (different 4-ish second exposures
up-down for modulating playback speed, press t to reset to real time
numbers 1-5 for choosing different data sets. give it a second to process when you switch.

right click a cell to disable it and recalculate the brightness range. useful when one or two cells are much brighter than the rest and limit the range.
right clicking again will re-enable it, or press r to enable all cells

left click any cell to highlight it and open a graph pane displaying its levels. graph has three modes; toggle with m. modes are:
	1. absolute axes: maximum y-val is the maximum fluorescence of any cell at any time in this particular presentation
	2. relative axes: same maximum y-val, but now the minimum y-val is the lowest fluorescence of any cell instead of 0
	3. self-relative axes: uses local y-max and min. good for seeing detail.
there aren't any units displayed because the measurement doesn't have units, apparently

press g to disable the graph again.

while the graph pane is open, you can click in it to scrub through different samples. 

I don't know if this produces any useful data or understanding.

*/

class Tuple<T> {
  T x;
  T y;
  public Tuple(T i, T j) {
    x = i;
    y = j;
  }
}

color graphBG = color(160);

Table clusters;
int maxClusters = 7;
color[] clusterColors = { color(130, 43, 102), color(170, 118, 57), color(40, 84, 108), color(131, 161, 54), color(78, 146, 49), color(138, 46, 96), color(255) };

int maxX = 0;
int maxY = 0;
float xScale;
float yScale;

int indicatorLen = 10;
color indicatorColor = color(255,0,0);

Table fluor;
Table[] presentations;

String[] dataNames = {"140718b", "140722", "140723", "140724", "140726"};
int dataIdx = 0;

String dataName = "140718b";
Tuple<Integer> xy[];
boolean enabled[];

boolean graph = false;

enum GraphMode { ABSOLUTE, RELATIVE, SELF;
  GraphMode getNext() { return values()[(ordinal() + 1) % values().length]; }
}

float spacer = 1.1;
int graphSpacer = 100;
int graphIdx;
int graphMin;
int graphMax;
GraphMode graphMode = GraphMode.ABSOLUTE;

int present = 0;
double frameIdx = 0;
double frameStep = .7;
double frameStepMax = 1.5;
double realTimeFrameStep;

int maxFluor = 0;
int minFluor = Integer.MAX_VALUE;

int maxWidth = 10;

void setup() {
  size(800,600);
  loadData();
  ellipseMode(CENTER);
  recalc();
}

void loadData() {
  graph = false;
  String temp[] = loadStrings(dataNames[dataIdx] + "/xy.txt");
  if (dataNames[dataIdx] == "140718b") clusters = loadTable(dataNames[dataIdx] + "/" + "clusters.csv", "csv");
  xy = new Tuple[temp.length];
  enabled = new boolean[temp.length];
  maxX = 0;
  maxY = 0;
  for (int i = 0; i < xy.length; i++) {
    enabled[i] = true;
    xy[i] = new Tuple<Integer>(Integer.parseInt(temp[i].split(",")[0]), Integer.parseInt(temp[i].split(",")[1]));
    if (xy[i].x > maxX) maxX = xy[i].x;
    if (xy[i].y > maxY) maxY = xy[i].y;
  }
  fluor = new Table();
  fluor = loadTable(dataNames[dataIdx] +"/" + dataNames[dataIdx] + "F.txt", "csv");
  presentations = new Table[fluor.getRow(fluor.getRowCount()-1).getInt(0)];
  for (int i = 0; i < presentations.length; i++) presentations[i] = new Table();
  for (TableRow t : fluor.rows()) {
    presentations[t.getInt(0)-1].addRow(t);
  }
}

void recalc() {
  maxFluor = 0;
  minFluor = Integer.MAX_VALUE;
  Table t = presentations[present];
  for (TableRow tr : t.rows()) {
    for (int i = 2; i < tr.getColumnCount(); i++) {
      if (!enabled[i-2]) continue;
      int temp = tr.getInt(i);
      if (temp > maxFluor) maxFluor = temp;
      if (temp < minFluor) minFluor = temp;
    }
  }
  
  realTimeFrameStep = t.getRow(t.getRowCount()-1).getDouble(1) * 60 / t.getRowCount();
  
  xScale = ((float) width)/(maxX * spacer);
  if (graph) yScale = ((float) height - graphSpacer)/(maxY * spacer);
  else yScale = ((float) height)/(maxY * spacer);
  
  regraph();
  //minFluor /= 2; //fuck it
}

void reset() {
  // actually just resets draw status of all cells
  for (int i = 0; i < enabled.length; i++) enabled[i] = true;
  recalc();
}

void graph(int idx) {
  graphIdx = idx;
  graph = true;
  graphMax = 0;
  graphMin = Integer.MAX_VALUE;
  Table t = presentations[present];
  for (int i = 0; i < t.getRowCount(); i++) {
    int temp = t.getRow(i).getInt(idx + 2); // this offset really pisses me off
    if (temp > graphMax) graphMax = temp;
    if (temp < graphMin) graphMin = temp;
  }
}

void regraph() {
  if (graph) graph(graphIdx);
}


void draw() {
  background(0);
  // INPUT DETECTION SHIT BEGINS
  if (keyPressed) {// Right and left arrows change presentation number; up and down changes playback speed 
     if (key == CODED) {
       switch(keyCode) {
        case RIGHT: if (present < presentations.length - 1) present++;
                    else present = 0;
                    recalc();
                    frameIdx = 0;
                    keyPressed = false;
                    break;
        case LEFT:  if (present > 0) present--;
                    else present = presentations.length - 1;
                    recalc();
                    frameIdx = 0;
                    keyPressed = false;
                    break;
        case DOWN:  if (frameStep - .1 >= 0) frameStep -= .1;
                    else frameStep = 0;
                    keyPressed = false;
                    break;
        case UP:    if (frameStep + .1 <= frameStepMax) frameStep += .1;
                    else frameStep = frameStepMax;
                    keyPressed = false;
                    break;
      }
    } else {
      switch(key) {
        case 'r':
        case 'R': reset();
                  break;
        case 't':
        case 'T': frameStep = realTimeFrameStep;
                  break;
        case 'g':
        case 'G': graph = false;
                  recalc();
                  break;
        case 'm':
        case 'M': graphMode = graphMode.getNext();
                  keyPressed = false;
                  break;
        case '1':
        case '2':
        case '3':
        case '4':
        case '5': dataIdx = Integer.parseInt(key + "") - 1; // how 2 parse int from char
                  loadData();
                  keyPressed = false;
                  break;
      }
    }
  }
  
  if (mousePressed) { //wtf right button and right arrow are the same code?!?!?!?!?
    if (graph && mouseY > height - graphSpacer) { //scrubbbbbbbbbbb
      frameIdx = min(width, max(mouseX, 0)) * (presentations[present].getRowCount() - 1) / width;
    }
    for (int i = 0; i < xy.length; i++) {
      if (Math.sqrt(Math.pow((xy[i].x * xScale) - mouseX, 2) + Math.pow((xy[i].y * yScale) - mouseY, 2)) < 10) {
        if (mouseButton == RIGHT) {
          enabled[i] = !enabled[i];
        } else if (mouseButton == LEFT) {
          enabled[i] = true;
          graph(i);
        }
        recalc();
        mousePressed = false;
        break;
      }
    }
  }
  // INPUT DETECTION ENDS
  
  stroke(indicatorColor);
  strokeWeight(1);
  if (graph) drawGraph();
  else line(width * (float)frameIdx / presentations[present].getRowCount(), height - indicatorLen, width * (float)frameIdx / presentations[present].getRowCount(), height);
  
  
  fill(255);
  textSize(25);
  text(present + 1, 5, 30);
  //if (!graph) text((float)frameIdx, 0, height- 10);
  //else text((float)frameIdx, 0, height - (graphSpacer + 10)); 
  // exchanged for indicator line
  
  textSize(15);
  text(dataNames[dataIdx], width - 70, 20);
  
  
  for (int i = 0; i < xy.length; i++) {
    double temp = .5;
    if (!enabled[i]) {
      stroke(color(255,0,0));
    } else {
      temp = ((double)presentations[present].getRow((int)frameIdx).getInt(i + 2) - minFluor)/(maxFluor - minFluor);
      //println(temp);
      if (dataNames[dataIdx] == "140718b") {
        fill(color(clusterColors[clusters.getInt(present, i)]), (int)(255*temp));
        stroke(color(clusterColors[clusters.getInt(present, i)]), (int)(255*temp));
      } else {
        fill((int)(255*temp));
        stroke((int)(255 * temp));
      }
    }
    ellipse(xy[i].x * xScale, xy[i].y * yScale, (int)(temp * maxWidth), (int)(temp * maxWidth));
    //point(xy[i].x * xScale, xy[i].y * yScale);
    //point(xy[i].x, xy[i].y);
    //line(xy[i].x, xy[i].y, xy[i].x * xScale, xy[i].y * yScale);
  }
  if (frameIdx < presentations[present].getRowCount() - frameStep) frameIdx += frameStep;
  else frameIdx = 0;
}

void drawGraph() {
  stroke(graphBG);
  fill(graphBG);
  rect(0, height - graphSpacer, width, graphSpacer);
  strokeWeight(1);
  stroke(0);
  Table t = presentations[present];
  
  int min;
  int max;
  if (graphMode == GraphMode.ABSOLUTE) {
    max = maxFluor;
    min = 0;
  } else if (graphMode == GraphMode.RELATIVE) {
    max = maxFluor;
    min = minFluor;
  } else {
    max = graphMax;
    min = graphMin;
  }
  
  for (int i = 1; i < t.getRowCount(); i++) {
    line((float)width * (i-1) / t.getRowCount(), height - (((float)t.getRow(i-1).getInt(graphIdx + 2) - min) * graphSpacer/(max - min)), (float)width * i / t.getRowCount(), height - (((float)t.getRow(i).getInt(graphIdx + 2) - min) * graphSpacer/(max - min)));
    //if (graphMode == GraphMode.ABSOLUTE) line((float)width * (i-1) / t.getRowCount(), height - ((float)t.getRow(i-1).getInt(graphIdx + 2) * graphSpacer/maxFluor), (float)width * i / t.getRowCount(), height - ((float)t.getRow(i).getInt(graphIdx + 2) * graphSpacer/maxFluor));
    //else if (graphMode == GraphMode.RELATIVE) line((float)width * (i-1) / t.getRowCount(), height - (((float)t.getRow(i-1).getInt(graphIdx + 2) - minFluor) * graphSpacer/(maxFluor - minFluor)), (float)width * i / t.getRowCount(), height - (((float)t.getRow(i).getInt(graphIdx + 2) - minFluor) * graphSpacer/(maxFluor - minFluor)));
    //else
  }
  fill(color(0,0,255));
  stroke(color(0,0,255));
  ellipse(xy[graphIdx].x * xScale, xy[graphIdx].y * yScale, maxWidth * 1.5, maxWidth * 1.5);
  stroke(indicatorColor);
  line(width * (float)frameIdx / t.getRowCount(), height - graphSpacer, width * (float)frameIdx / t.getRowCount(), height);
}