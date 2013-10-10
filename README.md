Phoenix
=======
Arduino_Hex_Emotion is kurts ported version of the phoenix code; I added emotion support.  
The code is still missing the piece to execute a gp sequence in response to it's emotions.

Emotion_Engine_R2 is the emotion engine and will communicate with the other microcontroller
to read the sensors vales.

EmotionInputs polls/scales the sensor data and will send it to the emotion engine upon request.

Both the Emotion_Engine & EmotionInputs programs communicate with each other over I2C.

Everyting was compiled using arduino ide 00021; in the libraries folder you will find a single
directory called WorldMood.  You will want to download this library and place it in your libraries
directory of your Arduino installation.  



