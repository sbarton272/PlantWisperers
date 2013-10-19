import oscP5.*;
import netP5.*;
import java.util.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float average;


Graph MyArduinoGraph = new Graph(150, 80, 500, 300, color (200, 20, 20));
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

float[][] gesturePoints = new float[4][2];
float[] gestureDist = new float[4];
String[] names = {
  "Nothing", "Touch", "Grab", "In water"
};

int streamSize = 2;
LinkedList <Float> pastXVals;
LinkedList <Float> pastYVals;

//SETUP*************************************************************************
void setup() {
  
  //initialize value streams
  pastXVals = new LinkedList <Float> ();
  pastYVals = new LinkedList <Float> ();
  
  
  // fill value streams with zeros
  for(int i=0;i<streamSize;i++){
    pastXVals.add(0.0); 
    pastYVals.add(0.0);
  }

  oscP5 = new OscP5(this, 5001);
  myRemoteLocation = new NetAddress("127.0.0.1", 5002);
  oscP5.plug(this, "average", "/average");
  oscP5.plug(this, "maxPoint", "/maxPoint");
  //oscP5.plug(this, "velocity", "/velocity");

  size(1000, 500); 

  MyArduinoGraph.xLabel="Readnumber";
  MyArduinoGraph.yLabel="Amp";
  MyArduinoGraph.Title=" Graph";  
  noLoop();
  PortSelected=4;      /* ====================================================================
   adjust this (0,1,2...) until the correct port is selected 
   In my case 2 for COM4, after I look at the Serial.list() string 
   println( Serial.list() );
   [0] "COM1"  
   [1] "COM2" 
   [2] "COM4"
   ==================================================================== */
  SerialPortSetup();      // speed of 115200 bps etc.
}

//DRAW*************************************************************************
void draw() {

  background(255);

  /* ====================================================================
   Print the graph
   ====================================================================  */

  if ( DataRecieved3 ) {
    float avg = averageValue(Voltage3, Voltage3.length);
    pushMatrix();
    pushStyle();
    MyArduinoGraph.yMax=500;      
    MyArduinoGraph.yMin=-200;      
    MyArduinoGraph.xMax=int (max(Time3));
    MyArduinoGraph.DrawAxis();    
    MyArduinoGraph.smoothLine(Time3, Voltage3);
    MyArduinoGraph.drawAverage(avg);
    popStyle();
    popMatrix();
    
    pastXVals.add((float)MyArduinoGraph.maxI); //Frequency w/ max voltage
    pastYVals.add(Voltage3[MyArduinoGraph.maxI]);
    
    float xVel = get1DVelocity(pastXVals);
    float yVel = get1DVelocity(pastYVals);
    
    pastXVals.remove(); //removes first element from queue
    pastYVals.remove();
    
    
    println("xVel =" + xVel);
    println("yVel =" + yVel);

    OscMessage myMessage = new OscMessage("/average");
    OscMessage maxPoint = new OscMessage("/maxPoint");
   

    myMessage.add(avg); // add an int to the osc message
    maxPoint.add(MyArduinoGraph.maxI);
<<<<<<< HEAD
    maxPoint.add(Voltage3[MyArduinoGraph.maxI]);
 
  // send the message
=======
    maxPoint.add(xVel);
    maxPoint.add(yVel);

    // send the message
>>>>>>> 9254d2463aa31c46cc7c52bcd1506a4f9059ecb8
    oscP5.send(maxPoint, myRemoteLocation); 
    oscP5.send(myMessage, myRemoteLocation); 

    float gestureOneDiff =0;
    float gestureTwoDiff =0;
    float gestureThreeDiff =0;

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    float totalDist = 0;
    int currentMax = 0;
    float currentMaxValue = -1;
    for (int i = 0; i < 4;i++)

    {

      //  gesturePoints[i][0] = 
      if (mousePressed && mouseX > 750 && mouseX<800 && mouseY > 100*(i+1) && mouseY < 100*(i+1) + 50)
      {
        fill(255, 0, 0);

        gesturePoints[i][0] = Time3[MyArduinoGraph.maxI];
        gesturePoints[i][1] = Voltage3[MyArduinoGraph.maxI];
      }
      else
      {
        fill(255, 255, 255);
      }

      //calucalte individual dist
      gestureDist[i] = dist(Time3[MyArduinoGraph.maxI], Voltage3[MyArduinoGraph.maxI], gesturePoints[i][0], gesturePoints[i][1]);
      totalDist = totalDist + gestureDist[i];
      if (gestureDist[i] < currentMaxValue || i == 0)
      {
        currentMax = i;
        currentMaxValue =  gestureDist[i];
      }
    }
    totalDist=totalDist /3;

    for (int i = 0; i < 4;i++)
    {
      float currentAmmount = 0;
      currentAmmount = 1-gestureDist[i]/totalDist;
      if (currentMax == i)
      {
        fill(0, 0, 0);
        //       text(names[i],50,450);
        fill(currentAmmount*255.0f, 0, 0);
      }
      else
      {
        fill(255, 255, 255);
      }

      stroke(0, 0, 0);
      rect(750, 100 * (i+1), 50, 50);
      fill(0, 0, 0);
      textSize(30);
      text(names[i], 810, 100 * (i+1)+25);

      fill(255, 0, 0);
      //   rect(800,100* (i+1), max(0,currentAmmount*50),50);
    }
  }
}



void stop()
{
  myPort.stop();
  super.stop();
}

public float averageValue(float[] Values, int max) {
  float sum=0;
  // ensure no grabbing invalid values
  if (Values.length < max) { 
    max = Values.length;
  }

  for (int i=0; i < max; i++) {
    sum+=Values[i];
  }
  return sum/max;
}



float get1DVelocity(LinkedList <Float> stream,int streamSize) {
  //uses five-point stencil finite difference http://en.wikipedia.org/wiki/Five-point_stenci
//  float x0 = (float) stream.get(0);
//  float x1 = (float) stream.get(1);
//  float x3 = (float) stream.get(3);
//  float x4 = (float) stream.get(4);
//  return (-x4+8*x3-8*x1+x0)/12;
    
    float x0 = (float) stream.get(0);
    float x1 = (float) stream.get(1);
    
    return (x0-x1)/2;
