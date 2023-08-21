import processing.serial.*;

PFont fontA;                        //text font dim 35
PFont fontB;                        //for colour button
int wRed=255, wGreen=255, wBlue=255;//starting from white
int x1=650;                         //coordinate for detection messages
int y1=102;                         //coordinate for detection messages
int x2=750;                         //coordinate for colour detected rgb
int y2=650;                         //coordinate for colour detected rgb                    
int off1=50;                        //space beetween two text rows messages
int off2=50+17;                     //space beetween two text rows detection rgb
int count1=0;                       //count variable for rubberMsg() function
int count2=0;                       //count variable for rubberRGB() function
int rest2=0;                        //rest variable for rubberRGB() function
int ri=30, ro=250;                  //internal and external radius of the wheel

int x_center_res=1425;              //reset button dimensions
int y_center_res=925;
int radius_res=50;

//colour button
int height_c=6;
int color_transparency=170;
int y=155;
  
Serial port;
String arduinoMsg;                  //reads all messages from arduino
String instruction;                 //saves "menu changes"
String RGB_components;              //saves RGB values

int i;         //for() cycles

/*
float w;       //used in colourWheel()
*/

float abs,s;   //used for the rect under the wheel
color col;     //used for the rect under the wheel

color c;       //used for draw the wheel
float H,S,B;   //hue, saturation, brightness for small circle in the wheel

PImage wheel;  //colour's wheel

boolean buttonFlag=false;           //blocks the user during functions



void setup(){ 
  size(1500,1000);                //window dimension
  port = new Serial(this, "COM6", 9600);
  background(wRed,wGreen,wBlue);  //colour the background of the window
  fontA = loadFont("SansSerif.plain-35.vlw");
  fontB = loadFont("FranklinGothic-Book-45.vlw");
  wheel = loadImage("wheel.jpg");
  textFont(fontA);                //Set the font
  colourButton(true);
  resetButton(true);
  fill(50);                       //colour with the 50th shade of grey
  led();
  arduinoMsg();
  detected();
} 

void draw(){
  if(port.available()>0) getInstruction();  //getting serial messages from arduino
  
  //highlight the button if we pass the mouse over it
  if(mouseX>300 && mouseX<500 && mouseY>80 && mouseY<180) colourButton(false);
  else colourButton(true);
  if((y_center_res+sqrt(sq(radius_res/2)-sq(mouseX-x_center_res)))>=mouseY && 
    (y_center_res-sqrt(sq(radius_res/2)-sq(mouseX-x_center_res)))<=mouseY)
      resetButton(false);
  else resetButton(true);
}

void mousePressed(){ 
  if(!buttonFlag){
    if(mouseX>300 && mouseX<500 && mouseY>80 && mouseY<180){
      port.write("COLOR\n");
      buttonFlag=true;
    }
    else if((y_center_res+sqrt(sq(radius_res/2)-sq(mouseX-x_center_res)))>=mouseY && 
      (y_center_res-sqrt(sq(radius_res/2)-sq(mouseX-x_center_res)))<=mouseY) reset();
  }
}



void getInstruction(){   
  arduinoMsg = port.readString(); //reads all "menu changes" + RGB components detection
  instruction = trim(split(arduinoMsg, '\n')[0]);  //get only "menu changes"
  
  if(instruction!=null){
    if(instruction.equals("colorDone")){         //colour detection finished
      RGB_components = trim(split(arduinoMsg, '\n')[1]);  //RGB numerical values
      rubberMsg();                               //rubber function messages
      fill(0,170,0);
      text("The colour detection is done", x1,y1);
      y1=y1+off1;                                //add space before next row
      wRed = int(split(RGB_components,',')[0]);  //taking RGB values
      wGreen = int(split(RGB_components,',')[1]);
      wBlue = int(split(RGB_components,',')[2]);
      detected();                            //draw new colour in the detecting zone
      rubberRGB();                           //rubber function colour detected
      fill(127);
      text("R:"+wRed, x2, y2-10);            //-10 to center the text with colour rect
      text("G:"+wGreen, x2+150, y2-10);
      text("B:"+wBlue, x2+300, y2-10);
      fill(wRed,wGreen,wBlue);
      rect(x2+450, y2-50+5, 150, 50-5, 10);  //colour rectangle next to RGB values
      y2=y2+off2;
      restLed(1);
    }
    else if(instruction.equals("f")){               //graphic led off
      fill(50);
      led();
    }
    else if(instruction.equals("r")){               //graphic led red
      fill(255,0,0);
      led();
    }
    else if(instruction.equals("g")){               //graphic led green
      fill(0,255,0);
      led();
    }
    else if(instruction.equals("b")){               //graphic led blue
      fill(0,0,255);
      led();
    }
    else if(instruction.equals("zz")) restLed(2);   //graphic led rest zz
    else if(instruction.equals("zzz")) restLed(3);  //graphic led rest zzz
    else if(instruction.equals("zzzEnd")){          //graphic led rest off
      restLed(0);
      buttonFlag=false;
    }
    else if(instruction.equals("colorStart")){
      rubberMsg();
      fill(70);
      text("The colour detection is started", x1, y1);
      y1=y1+off1;
    }
  }
}

//"delete" the past words and writes new one
void detected(){
  colourWheel();
  
  //draw the detection circle in the wheel
  translate(width/4, 520);
  c = color(wRed,wGreen,wBlue);
  H = hue(c);
  S = saturation(c);
  B = brightness(c);
  rotate(TWO_PI/255*H);
  fill(c);
  strokeWeight(3);
  circle(float(ro-ri)/255*B+ri,0,25);
  strokeWeight(1);
  rotate(-TWO_PI/255*H);
  translate(-width/4,-520);
  
  //detected colour zone (vertical RGB + detected colour big rect)
  fill(wRed,wGreen,wBlue);
  rect(1125, 300, 300, 255, 10);  //rect of the detected colour
  fill(255);
  noStroke();                     //starting eliminate the stroke
  rect(725,250,350,300+25);       //rubber for rgb vertical rects
  fill(0);
  text(wRed, 725, 280); 
  text(wGreen, 850, 280);
  text(wBlue, 975, 280);
  fill(235);
  rect(750,300,6,255);            //RGB verical rects
  rect(875,300,6,255);
  rect(1000,300,6,255);
  fill(255,80,80);
  rect(750,555-wRed,6,wRed);      //red cursor
  circle(753,555-wRed,20);
  fill(80,255,80);
  rect(875,555-wGreen,6,wGreen);  //green cursor
  circle(878,555-wGreen,20);
  fill(80,120,255);
  rect(1000,555-wBlue,6,wBlue);   //blue cursor
  circle(1003,555-wBlue,20);
  
  //colour the rect under the wheel
  abs = 500.0/255.0;              //500 is the width of the rectangle
  i = 0;
  colorMode(HSB);
  for (s = 0; s <= 255; s++) {
    col = color(H,s,B);
    stroke(col);
    fill(col);
    rect(125 + i*abs, 880, abs, 30);
    i++;
  }
  colorMode(RGB);
  
  //draw the triangle used as a pointer
  stroke(50);                    //return to stroke
  fill(60);
  triangle(125+abs*S,874, 125+abs*S-8,860, 125+abs*S+8,860);
}

//reset processing
void reset(){
  //erase colour detected hystory
  fill(255);
  noStroke();
  rect(750,600+3,620,325);//delete colour detected hystory
  stroke(50);
  count2=0;
  
  //erase arduino messages
  arduinoMsg();
  count1=0;
  y1=102;
  
  //resetting from the beginning
  wRed=255; wGreen=255; wBlue=255;
  detected();
}

//erase messages in the upper right when it's needed
void rubberMsg(){
  count1++;
  if(count1>2){
    arduinoMsg();
    count1=1;
    y1=102;
  }
}

//erase messages of RBG hystory
void rubberRGB(){
  count2++;
  rest2=count2%5;
  if(rest2==1) y2=650;   //when i need to start from the first row
  fill(255);
  noStroke();
  rect(750,y2-50+3,600+3,100+35);
  stroke(50);
}

//draw the "zzz" during the rest phase
void restLed(int mode){
  fill(255);
  noStroke();
  rect(0, 0, 250, 275);//erase led
  stroke(50);
  fill(50);
  led();
  if(mode==1||mode==2||mode==3){
    textFont(fontA,50);
    fill(50);
    text("Z",75,75);
  }
  if(mode==2||mode==3) text("z",45,50);
  if(mode==3){
    textFont(fontA,30);
    text("z",25,30);
    textFont(fontA);
  }
}



//draw the colour wheel and the rectangle below
void colourWheel(){
  fill(255);
  noStroke();
  rect(width/4-ro-25,520-ro-15,550,550);
  image(wheel,width/4-ro,520-ro,500,500);
  /*
  translate(width/4, 520);
  fill(255);
  noStroke();
  rect(-270,-265,540,540);//white rect below the color wheel to erase the last point
  colorMode(HSB, TWO_PI, 100, 100);//start HSB colour mode
  strokeWeight(2);//if not, we will have empty space in the wheel
  for (w = 0; w <= TWO_PI; w +=0.005) {//drawing the wheel
    push();
    rotate(w);
    for (i = ri; i< ro; i++) {
      stroke(w, 100, map(i, ri, ro, 0, 100));
      point(i, 0);
    }
    pop();
  }
  strokeWeight(1);           //return to normal strokeWeight
  colorMode(RGB,255,255,255);//return to RBG colour mode
  translate(-width/4, -520);
  */
  rect(110,855,555,30);      //erase the past triangle cursor on the saturation bar
  stroke(50);
  fill(255);
  rect(120, 875, 510, 40);   //saturation bar initialization
  /*
  fill(0,0);
  circle(125+ro,520,2*ro);   //stroke of the wheel
  */
}

//draw a led on the upper sx side
void led(){
  stroke(50);
  arc(150, 80, 70, 70, -PI, 0);
  noStroke();
  rect(115, 80, 70, 50);
  stroke(50);
  line(115, 80, 115, 130);
  line(185, 80, 185, 130);
  rect(100, 130, 100, 20);
  fill(127);
  rect(130, 150, 10, 100);
  rect(160, 150, 10, 80);
}

void resetButton(boolean over){
  if(over) fill(255,0,0);//normal button
  else fill(225,0,0);
  circle(x_center_res, y_center_res, radius_res);
}

void arduinoMsg(){
  fill(255);
  rect(600,50,820,130,20);
}

void colourButton(boolean over){
  if(over) fill(255);//normal button
  else fill(240);
  rect(300, 80, 200, 100, 10);
  noStroke();
  fill(255,0,255,color_transparency);//fucsia
  rect(332+1, y, 5, height_c, 5,0,0,5);//first
  fill(192,0,255,color_transparency);//magenta
  rect(332+8, y, 5, height_c);
  fill(128,0,255,color_transparency);//violetto scuro
  rect(332+15, y, 5, height_c);
  fill(0,0,255,color_transparency);//blu
  rect(332+22, y, 5, height_c);
  fill(0,128,255,color_transparency);//blu manganese
  rect(332+29, y, 5, height_c);
  fill(0,192,255,color_transparency);//ceruleo chiaro
  rect(332+36, y, 5, height_c);
  fill(0,255,255,color_transparency);//turchese
  rect(332+43, y, 5, height_c);
  fill(0,255,192,color_transparency);//verde acqua
  rect(332+50, y, 5, height_c);
  fill(0,255,128,color_transparency);//id
  rect(332+57, y, 5, height_c);
  fill(0,255,0,color_transparency);//verde
  rect(332+64, y, 5, height_c);
  fill(128,255,0,color_transparency);//verde foglia
  rect(332+71, y, 5, height_c);
  fill(192,255,0,color_transparency);//giallo acido zolfo
  rect(332+78, y, 5, height_c);
  fill(255,255,0,color_transparency);//giallo
  rect(332+85, y, 5, height_c);
  fill(255,224,0,color_transparency);//senape
  rect(332+92, y, 5, height_c);
  fill(255,192,0,color_transparency);//oro
  rect(332+99, y, 5, height_c);
  fill(255,160,0,color_transparency);//arancio
  rect(332+106, y, 5, height_c);
  fill(255,128,0,color_transparency);//id
  rect(332+113, y, 5, height_c);
  fill(255,96,0,color_transparency);//id
  rect(332+120, y, 5, height_c);
  fill(255,64,0,color_transparency);//pesca scuro
  rect(332+127, y, 5, height_c);
  fill(255,0,0,color_transparency);//rosso
  rect(332+134, y, 5, height_c, 0,5,5,0);//last
  stroke(50);
  fill(70);
  textFont(fontB);
  text("COLOR",333,140);
  textFont(fontA);
}
