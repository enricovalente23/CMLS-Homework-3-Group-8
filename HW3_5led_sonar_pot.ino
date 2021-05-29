#include <IRremote.h>

#define PIN_LED1 2
#define PIN_LED2 7
#define PIN_LED3 11
#define PIN_TRIGGER 9
#define PIN_ECHO 10
//#define MASSIMO 200
#define PIN_RECEIVER 13 
#define PIN_BUTTON 5
#define PIN_POT1 A0
#define PIN_POT2 5
#define PIN_PHOTO A3


//frequencies of the IR buttons
#define IRLED1 4261543680
#define IRLED2 4177985280
#define IRLED3 4127850240
#define IRLED4 4278255360
#define IRLED5 3910598400
#define IROFF 4111138560


float duration; // variable for the duration of sound wave travel
float distance; // variable for the distance measurement

int buttonState = 0;  
int sonarplay = 0;
int sonardrum = 0;
int playing = 0;
int prevpot1Value = 0;
int pot1Value = 0;
int prevpot2Value = 0;
int pot2Value = 0;
int prevphotoValue = 0;
int photoValue = 0;




void setup() {
  
  // initialize serial communication:
  Serial.begin(9600);
  
  pinMode(PIN_LED1,OUTPUT);
  pinMode(PIN_LED2,OUTPUT);
  pinMode(PIN_LED3,OUTPUT);
  pinMode(PIN_RECEIVER, INPUT);
  pinMode(PIN_TRIGGER, OUTPUT); // Sets the PIN_TRIGGER as an OUTPUT
  pinMode(PIN_ECHO, INPUT); // Sets the PIN_ECHO as an INPUT
  pinMode(PIN_BUTTON, INPUT);// initialize the pushbutton pin as an input:
  
  IrReceiver.begin(PIN_RECEIVER, ENABLE_LED_FEEDBACK);
}



void loop() {

  //check if the pushbutton is pressed. If it is, the buttonState is HIGH:
  buttonState = digitalRead(PIN_BUTTON);
  
  if (buttonState==LOW && sonarplay==0) {
  sonarplay=1;
  }
    
  else if (buttonState==LOW && sonarplay==1) {
  sonarplay=0;
  }


  //Serial.println(sonarplay);
   

  //reading the value from the photoresistor
  photoValue =  analogRead(PIN_PHOTO);
  
  if(abs(prevphotoValue-photoValue)>(prevphotoValue*20/100))
  {
  Serial.print("f");
  Serial.print(photoValue,  DEC);
  Serial.print("t");
  }
  prevphotoValue=photoValue;
  

  //IR signals receiver
   if (IrReceiver.decode())
   { 
       if (IrReceiver.decodedIRData.decodedRawData == IRLED1 )  
       {    
         digitalWrite( PIN_LED1, HIGH );
         digitalWrite( PIN_LED2, LOW );
         digitalWrite( PIN_LED3, LOW );
         if(sonarplay==0)
         {Serial.write("d1t");}
         else
         {sonardrum=1;}
       }
       else if (IrReceiver.decodedIRData.decodedRawData == IRLED2 )
       {
         digitalWrite( PIN_LED1, LOW );
         digitalWrite( PIN_LED2, HIGH );
         digitalWrite( PIN_LED3, LOW );
         if(sonarplay==0)
         {Serial.write("d2t");}
         else
         {sonardrum=2;}
       }
       else if (IrReceiver.decodedIRData.decodedRawData == IRLED3 )
       {
         digitalWrite( PIN_LED1, LOW );
         digitalWrite( PIN_LED2, LOW );
         digitalWrite( PIN_LED3, HIGH );
         if(sonarplay==0)
         {Serial.write("d3t");}
         else
         {sonardrum=3;}
       }
       else if (IrReceiver.decodedIRData.decodedRawData == IRLED4 )
       {
         digitalWrite( PIN_LED1, LOW );
         digitalWrite( PIN_LED2, LOW );
         digitalWrite( PIN_LED3, HIGH );
         if(sonarplay==0)
         {Serial.write("d4t");}
         else
         {sonardrum=4;}
       }
       else if (IrReceiver.decodedIRData.decodedRawData == IRLED5 )
       {
         digitalWrite( PIN_LED1, LOW );
         digitalWrite( PIN_LED2, LOW );
         digitalWrite( PIN_LED3, HIGH );
         if(sonarplay==0)
         {Serial.write("d5t");}
         else
         {sonardrum=5;}
       }
       else if (IrReceiver.decodedIRData.decodedRawData == IROFF )
       {
         digitalWrite( PIN_LED1, LOW );
         digitalWrite( PIN_LED2, LOW );
         digitalWrite( PIN_LED3, LOW );
       }                
       
   IrReceiver.resume();        // prepare to receive the next value
   }


  //script that prints distance from the sonar
  digitalWrite(PIN_TRIGGER, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIGGER, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIGGER, LOW);
  duration = pulseIn(PIN_ECHO, HIGH);
  distance = (duration*.0343)/2;
  //Serial.print("s");
  //Serial.print(distance);
  //Serial.print("t");
  delay(50);



  //if in sonar mode the distance is under 15cm play the selected drum
  if(distance<15 && playing==0 && sonarplay==1 && sonardrum!=0)
    {
      if(sonardrum==1)
      Serial.write("d1t");
      else if(sonardrum==2)
      Serial.write("d2t");
      else if(sonardrum==3)
      Serial.write("d3t");
      else if(sonardrum==4)
      Serial.write("d4t");
      else if(sonardrum==5)
      Serial.write("d5t");

      playing=1;      
    }
  else
  playing=0;
  
  delay(50);

     

  //reading and printing the value of potentiometers
  pot1Value = analogRead(PIN_POT1);
  if(abs(prevpot1Value-pot1Value)>(prevpot1Value*20/100))
  {
  Serial.print("p");
  Serial.print(pot1Value);
  Serial.print("t");
  }
  prevpot1Value=pot1Value;
  
  pot2Value = analogRead(PIN_POT2);
  if(abs(prevpot2Value-pot2Value)>(prevpot2Value*20/100))
  {
  Serial.print("k");
  Serial.print(pot2Value);
  Serial.print("t");
  }
  prevpot2Value=pot2Value;
  
  delay(50);

  
}
