#include <Wire.h>

int fear_array[9] = {0,0,0,0,0,0,0,0,0};
int fear_average = 0;
int counter = 0;

unsigned int x,y,x2,y2;
unsigned int difference_x, difference_y;

unsigned int anger_x = 0;
unsigned int anger_y = 0;
int anger = 0;

int count = 0;

void setup() {
  // initialize serial communication:
  Serial.begin(9600);
  
  Wire.begin(2);                // join i2c bus with address #2
  Wire.onRequest(requestEvent); // register event
}

void loop()
{
  fear_array[counter] = fear_val(7);
  
  x = analogRead(0);       // read analog input pin 0
  y = analogRead(1);       // read analog input pin 1
 
  if(counter < 10){
    counter += 1;
  }else{
    counter = 0;
    for(int i = 0; i < 10; i++)
    {
      fear_average += fear_array[i]; 
    }
    fear_average / 10;
  }
  
  delay(30);
  
  x2 = analogRead(0);       // read analog input pin 0
  y2 = analogRead(1);       // read analog input pin 1  
  
  difference_x = x - x2;
  difference_y = y - y2;
 
  if(difference_x <= 50){
    anger_x = map(difference_x, 0, 50, 0, 5);
  }

  if(difference_y <= 50){
    anger_y = map(difference_y, 0, 50, 0, 5);
  }
 
  anger = anger_x + anger_y;
  
  Serial.print("Fear Average: ");
  Serial.print(fear_average);
  Serial.print(",  Anger Average: ");
  Serial.println(anger);
  
  //delay(50);
}

int fear_val(int pingPin)
{
  // establish variables for duration of the ping,
  // and the distance result in inches and centimeters:
  long duration, inches, cm;

  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);

  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);

  // convert the time into a distance
  inches = microsecondsToInches(duration);
  cm = microsecondsToCentimeters(duration);
  
  unsigned int fear = map(inches, 50, 0, 0, 7);
  
  if(fear > 7){
    fear =  0;
  }
 
  return fear;
   
}

long microsecondsToInches(long microseconds)
{
  // According to Parallax's datasheet for the PING))), there are
  // 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
  // second).  This gives the distance travelled by the ping, outbound
  // and return, so we divide by 2 to get the distance of the obstacle.
  // See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
  return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds)
{
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}

// function that executes whenever data is requested by master
// this function is registered as an event, see setup()
void requestEvent()
{
  if(count == 0){
    Wire.send(fear_average); 
    count += 1;
  }else if (count == 1){
    Wire.send(anger); 
    count = 0;
  }
}
