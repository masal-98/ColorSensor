//we can control each detection/calibration operation by using
//processing application with the buttons on the screen
//references:
//https://www.instructables.com/Using-an-RGB-LED-to-Detect-Colours/
//https://hackaday.io/project/10269-color-sensor
//https://www.youtube.com/watch?v=tOa-qc9cvak&ab_channel=TechMaker%5BItalianTechProject%5D

//serial.println("xxx") send to processing the string "xxx\n"
//serial.print("xxx") send to processing the string "xxx"
//(serial communication on the arduino USB port)

//we can't use the serialEvent() isr function in our micro arduino given by professor
//https://www.arduino.cc/reference/en/language/functions/communication/serial/serialevent/

int photodiode = A5;                     //photodiode to pin A5
int ledArray[] = {2,3,4};                //led array in D2, D3, D4
String rgbArray[]={"r","g","b"};         //used in serial communication
float reading;                           //used in getReading()
String string;                           //used for reading messages from processing
int avgRead;                             //temporary variable during sampling

//floats to hold colour arrays
//when we print the result we transform these as int variable
double colourArray[] = {0,0,0};
int whiteArray[] = {748,733,740};//white memory of the program
int blackArray[] = {12,12,12};//black memory of the program
int greyDiff[] = {whiteArray[0] - blackArray[0], whiteArray[1] - blackArray[1],
  whiteArray[2] - blackArray[2]};//range for values
  
//calibration regression coefficients
double arrayX1[] = {2.2194214917, 2.1882544837, 2.1099261184};
double arrayX2[] = {-0.0081525719, -0.0083532605, -0.0081855873};
double arrayX3[] = {0.0000132053, 0.0000144655, 0.0000150248};

//variable declared
float timeRead=0.1; //time delay between each reading
int nRead=200;      //numbers of readings in getReading() function
int ohm=300;        //time delay for 2 opamp circuit
int wait=50;        //time delay beetween 2 different serial messages arduino-->processing
int rest=2000;      //rest time after detection or white calibration



void setup(void){
  //setup the outputs for the colour sensor
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(photodiode, INPUT);
  Serial.begin(9600);
}

void loop(void){
  //receive serial messages from Processing
  if(Serial.available()){
    string = Serial.readStringUntil('\n');//read serial message from processing
    if(string == "COLOR"){                  //until the end character "\n"
      string="";
      checkColour();
      printColour();
    }
  }
}



//colour detection
void checkColour(){
  Serial.println("colorStart");
  for(int i=0; i<=2; i++){
    delay(wait);                                //delay to avoid serial messages errors
    digitalWrite(ledArray[i],HIGH);             //turn on one led at a time
    Serial.println(rgbArray[i]);                //Processing will colours the graphic led
    delay(ohm);                                 //delay for the photodiode time response
    getReading(nRead);                          //nRead is the number of readings
    colourArray[i] = avgRead;                   //save average reading in the array

    //calculating the colour outcome
    colourArray[i] = (colourArray[i] - blackArray[i])/(greyDiff[i])*255;
    colourArray[i] = arrayX1[i]*colourArray[i] + arrayX2[i]*colourArray[i]*colourArray[i]
      + arrayX3[i]*colourArray[i]*colourArray[i]*colourArray[i];
    
    if(colourArray[i]>255) colourArray[i]=255;  //avoid sensor errors
    if(colourArray[i]<0) colourArray[i]=0;
    digitalWrite(ledArray[i],LOW);              //turn off the current LED
    Serial.println("f");                        //turn off the graphic led on processing
  }
  delay(wait);
  Serial.println("colorDone");
}

//send to Processing colour outcomes
void printColour(){
  Serial.print(round(colourArray[0]));      //transform float value in int
  Serial.print(",");
  Serial.print(round(colourArray[1]));
  Serial.print(",");
  Serial.print(round(colourArray[2]));
  for(int i=0; i<=2; i++){
    delay(rest/3);
    if(i==0) Serial.println("zz");          //second "Z"
    else if(i==1) Serial.println("zzz");    //third "Z"
    else if(i==2) Serial.println("zzzEnd"); //rubber the led graphic
  }
}

//take times reading and calculate avgRead
void getReading(int times){
  reading=0;                  //inizialize reading
  for(int j=0; j<times; j++){
    reading += analogRead(photodiode);
    delay(timeRead);          //timeRead for each reading
  }
  avgRead = (reading/times);  //calculate the average and set it
}
