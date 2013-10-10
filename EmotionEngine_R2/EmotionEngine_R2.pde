#include <WorldMood.h>
#include <avr/pgmspace.h>
#include <Wire.h>

// delay in ms between fade updates
// max fade time = 255 * 15 = 3.825s
#define fadeDelay (15)

const char* moodNames[NUM_MOOD_TYPES] = {
  "love",
  "joy",
  "surprise",
  "anger",
  "envy",
  "sadness",
  "fear",
};

const char* moodIntensityNames[NUM_MOOD_INTENSITY] = {
  "mild",
  "considerable",
  "extreme",
};

// the long term ratios between tweets with emotional content
// as discovered by using the below search terms over a period of time.
float tempramentRatios[NUM_MOOD_TYPES] = {
  0.13f,
  0.15f,
  0.20f,
  0.14f,
  0.16f,
  0.12f,
  0.10f,
};

// these numbers can be tweaked to get the system to be more or less reactive
// to be more or less susceptible to noise or short term emotional blips, like sport results 
// or bigger events, like world disasters 
#define  emotionSmoothingFactor (0.1f)
#define  moodSmoothingFactor (0.05f)
#define  moderateMoodThreshold (2.0f)
#define  extremeMoodThreshold (4.0f)

float frequency = 0;  //frequency
int EmotionValues[7] = {0,0,0,0,0,0,0};
int output = 0;

void setup()
{
  Serial.begin(9600);
  Wire.begin();
  delay(500);
}

void loop()
{
  // create and initialise the subsystems  
  WorldMood worldMood(Serial, emotionSmoothingFactor, moodSmoothingFactor, moderateMoodThreshold, extremeMoodThreshold, tempramentRatios);

  while (true)
  {
    for (int i = 0; i < NUM_MOOD_TYPES; i++)
    {
      
      //if the loop reaches anger check the sensors and get anger & fear data
      //3 is anger & 6 is fear
      if(i == 3){
        read_sensors(); 
        //if fear is 0 & anger is 0 then joy is 1
        if(EmotionValues[6] == 0  && EmotionValues[3] == 0){
         EmotionValues[1] = 1;
        }
      }
     
      frequency = EmotionValues[i]; 

      // debug code
      //Serial.println("");
      //Serial.print(moodNames[i]);
      //Serial.print(": events per min = ");
      //Serial.println(frequency);
      
      int MoodNumber = 1;
      
      worldMood.RegisterTweets(i, frequency);
    }

    MOOD_TYPE newMood = worldMood.ComputeCurrentMood();
    MOOD_INTENSITY newMoodIntensity = worldMood.ComputeCurrentMoodIntensity();
    

    //Serial.print("Robot Mood : ");
    //Serial.print(moodIntensityNames[(int)newMoodIntensity]);
    //Serial.print(" ");
    //Serial.println(moodNames[(int)newMood]);

    int RobotMood = concatenate(newMoodIntensity, newMood);

    Serial.println(RobotMood);

    delay(300);


  }
}


void read_sensors()
{
  //Read fear
  Wire.requestFrom(2, 1);   // the first byte
  while(Wire.available())
  {
    char received = Wire.receive();
    output = received;
  }

  EmotionValues[6] = output;  
  
  output = 0;
  
  //Read anger 
  Wire.requestFrom(2, 1);   // the first byte
  while(Wire.available())
  {
    char received = Wire.receive();
    output = received;
  }

  EmotionValues[3] = output;  
 
}

unsigned concatenate(unsigned x, unsigned y) {
    unsigned pow = 10;
    while(y >= pow)
        pow *= 10;
    return x * pow + y;        
}


