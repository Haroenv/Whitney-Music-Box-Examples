// Whitney Music Box - Jim Bumgardner
//
// Processing+Beads implementation jbum 9/25/2011
//

import beads.*;

// Play with these...
int   nbrPoints = 48;         // Number of notes - current patch has 16 voice polyphony
float cycleLength = 1 * 60;   // Length of the full cycle in seconds
float durRange = cycleLength*1000/nbrPoints;        // Duration range
float minDur = durRange/2;    // Minimum duration
float baseFreq = 30;          // Minimum frequency
float baseNoteNbr = 32;        // Minimum note number (for chromatic)

int   kWidth = 500;             // width of graphics
int   kHeight = 500;            // height of graphics

int   cx = kWidth/2,cy = kHeight/2;          // center coordinates
float circleRadius;  
float[] tines;        // keeps track of current position of note, by angle
long[] lastSound;     // keeps track of time last note sounded
boolean isMute = false;

float ampScale = 2;

AudioContext ac = new AudioContext();
WavePlayer[] wp = new WavePlayer[nbrPoints];
Envelope[] env = new Envelope[nbrPoints];
Gain[] gain = new Gain[nbrPoints];


void setup() {
  size(kWidth,kHeight);
  circleRadius = (min(width,height)/2) * 0.95;
  noStroke();
  smooth();
  colorMode(HSB,1);
  background(0);
  
  tines = new float[nbrPoints];
  lastSound = new long[nbrPoints];

  for (int i = 0; i < nbrPoints; ++i)
  {
    tines[i] = -10;
    lastSound[i] = millis();
    // Harmonic
    wp[i] = new WavePlayer(ac, baseFreq+i*baseFreq, Buffer.SINE);
    // Chromatic
    // wp[i] = new WavePLayer(ac, baseNoteNbr*(pow(2,i/12.0)), Buffer.SINE);
    env[i] = new Envelope(ac, 0.0);
    gain[i] = new Gain(ac, 1, env[i]);
    gain[i].addInput(wp[i]);
    ac.out.addInput(gain[i]);
  }
  ac.start();
}

void draw()
{
  background(0);

  stroke(.2);
  line(cx,cy,width,cy); // delete this line of code to get rid of the graphical line

  float mx = mouseX/(float)width;
  float my = mouseY/(float)height;
  float speed = (2*PI*nbrPoints) / cycleLength;

  long cMillis = millis();
  float timer = cMillis*.001*speed;

  float pi2 = 2*PI;
  noStroke();
  
  float durIncrement = (durRange/nbrPoints);

  for (int i = 0; i < nbrPoints; ++i)
  {
    float r = (i+1)/(float)nbrPoints;

    float a = timer * r;
    float len = circleRadius * (1 + 1.0 /nbrPoints - r);

    if ((int) (a/pi2) != (int) (tines[i]/pi2))
    {
      // Sound Note Here...
      if (!isMute) {
        int ii = (nbrPoints-1)-i;
        // Chromatic Mapping
        float duration = minDur+durRange - i*durIncrement;
        if (duration < 100) {
          duration = 100;
        }
        env[i].addSegment(ampScale/nbrPoints, 50);
        env[i].addSegment(0, duration-50);
      }
      lastSound[i] = millis();
    }

    // swap sin & cos here if you want the notes to sound on the top or bottom, instead of left or right
    // use -cos or -sin to flip the bar from right to left, or bottom to top
    
    float x = (cx + cos(a)*len);
    float y = (cy + sin(a)*len);
    float minRad = 20-r*16;
    float radv = max( (minRad+6)-6*(cMillis-lastSound[i])/500.0 , minRad);

    float huev = r;
    float satv = min(.5, (cMillis-lastSound[i])/1000.0);
    float valv = 1;
    
    fill(color(huev,satv,valv));
    ellipse(x,y,radv,radv);

    tines[i] = a;
  }
  timer -= speed;

}


void mousePressed() 
{
}


void keyPressed() {
  if (key == ' ') 
  {
    isMute = !isMute;
    println("MUTE " + (isMute? "ON" : "OFF"));
  }
}


