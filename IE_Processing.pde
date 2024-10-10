/* Processing code used for Designing Interactive Experiences
 The code communicates with an Arduino which reads RFID tags. 
 Based on the tag, a movie starts to play in this file. 
 Written by Anouk de Graaf 
 17-06-2021*/

//Connect to the Serial port
import processing.serial.*;
Serial myPort;  // The serial port

//Make first contact
boolean firstContact = false;
boolean clientContact = true;

//Detect if fruit is found
boolean carrot = false;
boolean apple = false;
boolean potato = false;
boolean water = false;
boolean fish = false; 
boolean start = false;
boolean startOver = true;

String inString; //input we give
String outString = "0,0,0"; //output we write

//Get the movies working
import processing.video.*;

Movie myMovie[];
float t0;
float t;
float objectTimer;
float lastObject = 0;
float timeToCollect = 10;
float startCollect = 0;
int index = 0;

boolean getCarrot = false;
boolean getPotato = false;
boolean getWater = false;
boolean getFish = false;

boolean wait2min = false;
boolean wait3min = false;
boolean wait5min = false;

boolean wrongItem = false;

boolean potato2 = false;

float carrotTime;
float appleTime;
float potatoTime;
float fishTime;
float waterTime;
float startTime;

boolean gotCarrot = false;
boolean gotApple = false;

void setup() {
  size(800, 450);
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n'); //buffer untill carriage return is found

  //Load all movies
  myMovie = new Movie[29];

  myMovie[0]  = new Movie(this, "(0.0)blinking.mov");
  myMovie[1]  = new Movie(this, "(1)+(2)+(3).mov");
  myMovie[2]  = new Movie(this, "(4)putontrunk.mov");
  myMovie[3]  = new Movie(this, "(5.0)endthanksfruit.mov");
  myMovie[4]  = new Movie(this, "(6)bringpotato.mov");
  myMovie[5]  = new Movie(this, "(7)eatingpotato.mov");
  myMovie[6]  = new Movie(this, "(8)sad-tired.mov");
  myMovie[7]  = new Movie(this, "(9)bringfish.mov");
  myMovie[8]  = new Movie(this, "(10)fisheating.mov");
  myMovie[9]  = new Movie(this, "(11)getwater.mov");
  myMovie[10]  = new Movie(this, "(12)drinkwater.mov");
  myMovie[11]  = new Movie(this, "(13)t-m(15).mov");
  myMovie[12]  = new Movie(this, "askagaincarrot.mov");
  myMovie[13]  = new Movie(this, "askagainfish.mov");
  myMovie[14]  = new Movie(this, "askagainpotato.mov");
  myMovie[15]  = new Movie(this, "askagainwater.mov");
  myMovie[16]  = new Movie(this, "Apple_extra.mov");
  myMovie[17]  = new Movie(this, "carrot_extra.mov");
  myMovie[18]  = new Movie(this, "fish_extra.mov");
  myMovie[19]  = new Movie(this, "potato_extra.mov");
  myMovie[20]  = new Movie(this, "water_extra.mov");
  myMovie[21]  = new Movie(this, "potato_extra.mov");
  myMovie[22]  = new Movie(this, "waiting2min.mov");
  myMovie[23]  = new Movie(this, "waiting3min.mov");
  myMovie[24]  = new Movie(this, "waiting5min.mov");
  myMovie[25] = new Movie(this, "potato_extra2.mov"); 
  myMovie[26] = new Movie(this, "(5.1)eatcarrot.mov"); 
  myMovie[27] = new Movie(this, "(5.2)eatapple.mov"); 
  myMovie[28] = new Movie(this, "(0)begin_button.mov"); 

  for (int i = 0; i < myMovie.length; i++) {
    myMovie[i].pause();
  }
  index = 28;
  myMovie[28].loop();
}

void draw() {
  background(0);
  playMovies();
  extraMovies();
}


void serialEvent( Serial myPort) {
  println(firstContact);
  //put the incoming data into a String - 
  //the '\n' is our end delimiter indicating the end of a complete packet
  inString = myPort.readStringUntil('\n');
  //make sure our data isn't empty before continuing
  if (inString != null) { 
    //trim whitespace and formatting characters (like carriage return)
    inString = trim(inString);
    println(inString);

    if (inString.equals("start")) {
      if (startOver) {
        start = true;
        println("start is true");
        startTime = millis()/1000;
        startOver = false;
      }
    }

    if (inString.equals("carrot")) {
      if (t > timeToCollect + carrotTime) {
        carrot = true;
        println("carrot is true");
        carrotTime = millis()/1000;
      }
    }

    if (inString.equals("fish")) {
      if (t > timeToCollect + fishTime) {
        fish = true;
        println("fish is true");
        fishTime = millis()/1000;
      }
    }
    if (inString.equals("apple")) {
      if (t > timeToCollect + appleTime) {
        apple = true;
        println("apple is true");
        appleTime = millis()/1000;
      }
    }
    if (inString.equals("water")) {
      if (t > timeToCollect + waterTime) {
        water = true;
        println("water is true");
        waterTime = millis()/1000;
      } else {
        water = false;
      }
    }
    if (inString.equals("potato")) {
      if (t > timeToCollect + potatoTime) {
        potato = true;
        println("potato is true");
        potatoTime = millis()/1000;
      } else {
        potato = false;
      }
    }

    //look for our 'A' string to start the handshake
    //if it's there, clear the buffer, and send a request for data
    if (firstContact == false) {
      if (inString.equals("A")) {
        myPort.clear();
        firstContact = true;
        myPort.write("A");
        println("contact");
      }
      //  } else { //if we've already established contact, keep getting and parsing data

      //    //write to client(s)

      //    if (clientContact ==true) {
      //      myPort.write(outString);
      //      println("Client" + outString);
      //    }
    }
  }
}

void playMovies() {

  if (myMovie[index].available() ) {
    myMovie[index].read();
  }
  image(myMovie[index], 0, 0, width, height);

  if (startOver) { 
    //movie to look at button
    index = 28;
    myMovie[28].loop();
  }
  if (start) { 
    //Start if a button is pressed
    //Play introduction
    myMovie[0].pause();
    myMovie[1].jump(0);
    myMovie[1].play();
    index = 1;
    t0 = millis()/1000;
    start = false; 
    getCarrot = true;
    println("get Carrot");
    startCollect = millis()/1000;
  }
  if (!startOver) {
    if (t > myMovie[index].duration() + t0) {
      if (index == 1) {
        myMovie[0].pause();
        myMovie[2].jump(0);
        myMovie[2].play();
        index = 2;
        t0 = millis()/1000;
        getCarrot = true;
      } else if (getCarrot) {
        //Play thanks for the movie
        vegetableTimer();
        extraMovies();
        wrongItem();
        if (wrongItem) {
          if (t > myMovie[index].duration() + t0) {
            myMovie[0].pause();
            myMovie[12].jump(0);
            myMovie[12].play();
            index = 12;
            t0 = millis()/1000;
            wrongItem = false;
            return;
          }
        } else if (carrot) {
          myMovie[0].pause();
          myMovie[26].jump(0);
          myMovie[26].play();
          index = 26;
          t0 = millis()/1000;
          gotCarrot = true;
          carrot = false;
          return;
        } else if (apple) {
          myMovie[0].pause();
          myMovie[27].jump(0);
          myMovie[27].play();
          index = 27;
          t0 = millis()/1000;
          gotApple = true;
          apple = false;
          return;
        } else {
          index = 0;
          myMovie[0].loop();
        }
        if (gotApple && gotCarrot) {
          println("Dit is waar");
          myMovie[0].pause();
          myMovie[3].jump(0);
          myMovie[3].play();
          index = 3;
          t0 = millis()/1000;
          carrot = false;
          apple = false;
          getCarrot = false;
          gotApple = false;
          gotCarrot = false;
          return;
        }
      } else if (index == 3) {
        println("Speel video 3");
        myMovie[0].pause();
        myMovie[4].jump(0);
        myMovie[4].play();
        index = 4;
        t0 = millis()/1000;
        getPotato = true;
        return;
      } else if (getPotato) {
        //Play thanks for the movie
        vegetableTimer();
        extraMovies();
        wrongItem();
        if (wrongItem) {
          if (t > myMovie[index].duration() + t0) {
            myMovie[0].pause();
            myMovie[14].jump(0);
            myMovie[14].play();
            index = 14;
            t0 = millis()/1000;
            wrongItem = false;
            return;
          }
        } else if (potato) {
          println("potato is waar");
          myMovie[0].pause();
          myMovie[5].jump(0);
          myMovie[5].play();
          index = 5;
          t0 = millis()/1000;
          potato = false;
          getPotato = false;
          return;
        } else {
          index = 0;
          myMovie[0].loop();
        }
      } else if (index == 5) {
        myMovie[0].pause();
        myMovie[7].jump(0);
        myMovie[7].play();
        index = 7;
        t0 = millis()/1000;
        getFish = true;
        return;
      } else if (getFish) {
        //Play thanks for the movie
        vegetableTimer();
        extraMovies();
        wrongItem();
        if (wrongItem) {
          if (t > myMovie[index].duration() + t0) {
            myMovie[0].pause();
            myMovie[13].jump(0);
            myMovie[13].play();
            index = 13;
            t0 = millis()/1000;
            wrongItem = false;
            return;
          }
        } else if (fish) {
          println("fish is waar");
          myMovie[0].pause();
          myMovie[8].jump(0);
          myMovie[8].play();
          index = 8;
          t0 = millis()/1000;
          fish = false;
          getFish = false;
          return;
        } else {
          index = 0;
          myMovie[0].loop();
        }
      } else if (index == 8) {
        myMovie[0].pause();
        myMovie[9].jump(0);
        myMovie[9].play();
        index = 9;
        t0 = millis()/1000;
        getWater = true;
        return;
      } else if (getWater) {
        //Play thanks for the movie
        vegetableTimer();
        extraMovies();
        wrongItem();
        if (wrongItem) {
          if (t > myMovie[index].duration() + t0) {
            myMovie[0].pause();
            myMovie[15].jump(0);
            myMovie[15].play();
            index = 15;
            t0 = millis()/1000;
            wrongItem = false;
            return;
          }
        } else if (water) {
          println("water is waar");
          myMovie[0].pause();
          myMovie[10].jump(0);
          myMovie[10].play();
          index = 10;
          t0 = millis()/1000;
          water = false;
          getWater = false;
          return;
        } else {
          index = 0;
          myMovie[0].loop();
        }
      } else if (index == 10) {
        myMovie[0].pause();
        myMovie[11].jump(0);
        myMovie[11].play();
        index = 11;
        t0 = millis()/1000;
        return;
      } else if (index == 11) {
        startOver = true;
        return;
      } else {
        index = 0;
        myMovie[0].loop();
      }
    }
  }
  t  = millis()/1000;
}

void vegetableTimer() {
  if (t > myMovie[index].duration() + 300 && t < myMovie[index].duration() + 302) {
    wait5min = true;
  } else if (t > myMovie[index].duration() + 180 && t < myMovie[index].duration() + 182) {
    wait3min = true;
  } else if (t > myMovie[index].duration() + 120 && t < myMovie[index].duration() + 122) {
    println("Sloompie");
    wait2min = true;
  }
}


void wrongItem() {
  if (!getPotato) {
    if (potato) {
      if (potato2) {
        myMovie[0].pause();
        myMovie[25].jump(0);
        myMovie[25].play();
        index = 25;
        t0 = millis()/1000;
      } else {
        myMovie[0].pause();
        myMovie[19].jump(0);
        myMovie[19].play();
        index = 19;
        t0 = millis()/1000;
        potato2 = true;
      }
      wrongItem = true;
      potato = false;
    }
  }
  if (!getFish) {
    if (fish) {
      myMovie[0].pause();
      myMovie[18].jump(0);
      myMovie[18].play();
      index = 18;
      t0 = millis()/1000;
      wrongItem = true;
      fish = false;
      println("wrong item" + wrongItem);
    }
  }
  if (!getCarrot) {
    if (carrot) {
      myMovie[0].pause();
      myMovie[17].jump(0);
      myMovie[17].play();
      index = 17;
      t0 = millis()/1000;
      wrongItem = true;
      carrot = false;
    }
    if (apple) {
      myMovie[0].pause();
      myMovie[16].jump(0);
      myMovie[16].play();
      index = 16;
      t0 = millis()/1000;
      wrongItem = true;
      apple = false;
    }
  }
  if (!getWater) {
    if (water) {
      myMovie[0].pause();
      myMovie[20].jump(0);
      myMovie[20].play();
      index = 20;
      t0 = millis()/1000;
      wrongItem = true;
      water = false;
    }
  }
}

void extraMovies() {
  if (t > myMovie[index].duration() + t0) {
    if (wait2min) {
      myMovie[0].pause();
      myMovie[22].jump(0);
      myMovie[22].play();
      index = 22;
      t0 = millis()/1000;
      wait2min=false;
    }
    if (wait3min) {
      myMovie[0].pause();
      myMovie[23].jump(0);
      myMovie[23].play();
      index = 23;
      t0 = millis()/1000;
      wait3min=false;
    }
    if (wait5min) {
      myMovie[0].pause();
      myMovie[24].jump(0);
      myMovie[24].play();
      index = 24;
      t0 = millis()/1000;
      wait5min = false;
    }
  }
}

void keyPressed() {
  if (key == '0') {
    myMovie[0].loop();
    index = 0;
    t0 = millis()/1000;
  }
  if (key == '1') {
    myMovie[0].pause();
    myMovie[1].jump(0);
    myMovie[1].play();
    index = 1;
    t0 = millis()/1000;
  }

  if (key == '2') {
    myMovie[0].pause();
    myMovie[2].jump(0);
    myMovie[2].play();
    index = 2;
    t0 = millis()/1000;
  }
  if (key == '3') {
    myMovie[0].pause();
    myMovie[3].jump(0);
    myMovie[3].play();
    index = 3;
    t0 = millis()/1000;
  }
  if (key == '4') {
    myMovie[0].pause();
    myMovie[4].jump(0);
    myMovie[4].play();
    index = 4;
    t0 = millis()/1000;
  }

  if (key == '5') {
    myMovie[0].pause();
    myMovie[5].jump(0);
    myMovie[5].play();
    index = 5;
    t0 = millis()/1000;
  }
  if (key == '6') {
    myMovie[0].play();
    myMovie[6].jump(0);
    myMovie[6].play();
    index = 6;
    t0 = millis()/1000;
  }
  if (key == '7') {
    myMovie[0].pause();
    myMovie[7].jump(0);
    myMovie[7].play();
    index = 7;
    t0 = millis()/1000;
  }
  if (key == '8') {
    myMovie[0].pause();
    myMovie[8].jump(0);
    myMovie[8].play();
    index = 8;
    t0 = millis()/1000;
  }

  if (key == '9') {
    myMovie[0].pause();
    myMovie[9].jump(0);
    myMovie[9].play();
    index = 9;
    t0 = millis()/1000;
  }
  if (key == 'q') {
    myMovie[0].pause();
    myMovie[10].jump(0);
    myMovie[10].play();
    index = 10;
    t0 = millis()/1000;
  }
  if (key == 'w') {
    myMovie[0].pause();
    myMovie[11].jump(0);
    myMovie[11].play();
    index = 11;
    t0 = millis()/1000;
  }

  if (key == 'e') {
    myMovie[0].pause();
    myMovie[12].jump(0);
    myMovie[12].play();
    index = 12;
    t0 = millis()/1000;
  }
  if (key == 'r') {
    myMovie[0].pause();
    myMovie[13].jump(0);
    myMovie[13].play();
    index = 13;
    t0 = millis()/1000;
  }
  if (key == 't') {
    myMovie[0].pause();
    myMovie[14].jump(0);
    myMovie[14].play();
    index = 14;
    t0 = millis()/1000;
  }
  if (key == 'y') {
    myMovie[0].pause();
    myMovie[15].jump(0);
    myMovie[15].play();
    index = 15;
    t0 = millis()/1000;
  }

  if (key == 'u') {
    myMovie[0].pause();
    myMovie[16].jump(0);
    myMovie[16].play();
    index = 16;
    t0 = millis()/1000;
  }
  if (key == 'i') {
    myMovie[0].pause();
    myMovie[17].jump(0);
    myMovie[17].play();
    index = 17;
    t0 = millis()/1000;
  }
  if (key == 'o') {
    myMovie[0].pause();
    myMovie[18].jump(0);
    myMovie[18].play();
    index = 18;
    t0 = millis()/1000;
  }
  if (key == 'p') {
    myMovie[0].pause();
    myMovie[19].jump(0);
    myMovie[19].play();
    index = 19;
    t0 = millis()/1000;
  }
  if (key == 'a') {
    myMovie[0].pause();
    myMovie[20].jump(0);
    myMovie[20].play();
    index = 20;
    t0 = millis()/1000;
  }
  if (key == 's') {
    myMovie[0].pause();
    myMovie[21].jump(0);
    myMovie[21].play();
    index = 21;
    t0 = millis()/1000;
  }
  if (key == 'd') {
    myMovie[0].pause();
    myMovie[22].jump(0);
    myMovie[22].play();
    index = 22;
    t0 = millis()/1000;
  }
  if (key == 'f') {
    myMovie[0].pause();
    myMovie[23].jump(0);
    myMovie[23].play();
    index = 23;
    t0 = millis()/1000;
  }
  if (key == 'g') {
    myMovie[0].pause();
    myMovie[24].jump(0);
    myMovie[24].play();
    index = 24;
    t0 = millis()/1000;
  }
  if (key == 'h') {
    myMovie[0].pause();
    myMovie[25].jump(0);
    myMovie[25].play();
    index = 25;
    t0 = millis()/1000;
  }
  if (key == 'j') {
    myMovie[0].pause();
    myMovie[26].jump(0);
    myMovie[26].play();
    index = 26;
    t0 = millis()/1000;
  }
  if (key == 'k') {
    myMovie[0].pause();
    myMovie[27].jump(0);
    myMovie[27].play();
    index = 27;
    t0 = millis()/1000;
  }
  if (key == 'l') {
    myMovie[0].pause();
    myMovie[28].jump(0);
    myMovie[28].play();
    index = 28;
    t0 = millis()/1000;
  }
  if (key == 'x') {
    for (int i = 0; i < myMovie.length; i++) {
      myMovie[i].pause();
      startOver = true;
    }
  }
}
