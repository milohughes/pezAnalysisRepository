// TeensyPEZ.INO
// 20160215 sws ID&F HHMI Janelia
//
// Runs the Fly Pez Board J005412
// Converted from FlyPez3000_gate_hard_WRWversion written for the J001155 Board
//

// #define DEBUG
#define ORIGINALDAC  // enable this if using original DAC (TLV5638)

// VERSIONS
#define VERSION "20231206"

// 20231206 sws
// - R.Hormigo - Reversed shadow thershold array th[i] respect pixel[i] to allow matlab correct visiualization.
//   This works with the array placed with its wiring pads placed towards the top end of the assembly, so wires go across the whole array PCB rear.
//    

// 20230427 sws
// - switch to PWMservo to stop servo jitter

// 20230326 sws
// - Teensy 4.0 is too fast without delays in linear array clock. Add clockDelay
// - set test pin low at end if image acq (was setting high)

// 20230322 sws
// add Y and y comamnds to enable and disable LED power

// 20221115 sws
// - ramp ready to test

// 20221114 sws
// - elapsedMillis pulse routine

// 20221109 sws
//  - start to get pulse and ramp working ("Z" command)
 
// 20221003 sws
// - add in original DAC

// 20220720 sws
// - add median filter

// 20220719 sws
// - add debug to threshold routine

// 20220712 sws
// - comment out testing code from findgate and print statements in threshold routine

// 20220711 sws
// - change sweep delay from 2500 to 100

// 20200117 sws
// - add vibration motor command and control

// 20191114 sws
// - new power board runs ADC off Enable Pin so reararnge code a bit, and power on DAC before writing to it

// 20190626 sws
// - add P command to make pulsed crimson

// 20190625 sws
// - set internal ref each time we write to DAC in case DAC was powered up before CPU

// 20190624 sws
// - add send_now after image/temp transfer
// - add 'i' command to init DAC

// 20190620 sws
// - add 'A' command

// 20190617 sws
// - bring back in lost code - temperature sensor, etc


// 20190614 sws
// - debugging release

// 20190611 sws
// - change DAC

// 20190430 sws
// - add '?' command
// - start to calibrate servos
// - change 't' cimamnd to 'h'
// - use 't' comamd for TMP75 temperature reading

// 20190423 sws
// - getting parts to work
// - added 't' comamnd to get temperature and humidity

// on prototype , original was CHR 1, IR 2
#define CHR 2
#define IR 1

//#include <Servo.h>
#include <PWMServo.h>
#include <SPI.h>
#include <Wire.h>

SPISettings DAC(2000000, MSBFIRST, SPI_MODE2);  

// PINS
#define rxPin       0 // RS232 in from Temp/Humidity
#define timerPin    2 // debug pin for timer (was B.1)
#define peltierPin  4 // PWM control for peltiers
#define wakePin     6 // control for vibration motor
#define enablePin   7 // enables LED and servo powers
#define csPin       8 // CS for LED control
#define sweepPin    9  // servo signal for sweep
#define gatePin     10 // servo signal for gate
#define MOSIPin     11 // MOSI for ADC and DAC
#define SCLKPIn     13 // SCLK pin for ADC and DAC
#define adataPin  A0 // analog signal from linear array
#define asyncPin  15  //sync pin for linear array
#define aclkPin   16  //clk pin for linear array
#define atestPin  17 // test/debug pin
#define monitorPin 23 // monitor crimson


#define PWR_OFF LOW
#define PWR_ON  HIGH

#define TMP75_Address 0x48  // 7 bit address

#define IDLE 0
#define OUT 1
#define IN 2
#define GATEMOTOR 0
#define SWPRMOTOR 1
#define CLOSEDPOS 98//RH was 90 //00//100 //100
#define OPENPOS 75 //default-80/pez1-85/pez2-88/pez3-82/pez4-89
#define BLOCKPOS (CLOSEDPOS - 4) // 94//default-95/pez1-91/pez2-94/pez3-87/pez4-93
#define CLEANING 55//RH was 50 and stuck //default-65/pez1-60/pez2-65/pez3-65/pez4-65
#define SWEEPOFF 180
#define SWEEPEND 70
#define SWEEPCAL 105

//#define GATEMOTOROFF 1700//default-2150/pez1-2150/pez2-1700/pez3-2050/pez4-2150     //adjust to physical location in increments of 50. less makes gate more 'open'
//#define SWPRMOTOROFF 2200//default-2150/pez1-2100/pez2-2200/pez3-2150/pez4-2120     //adjust to physical location. less rotates counter-clockwise, looking down
#define MAXWIDTH 100
#define MAXOFFSET 100
#define GATE1 0                // Fly Filter/Entrance Gate
#define SWEEPER 1               // Fly Sweeper Gate
#define OPENED 0
#define CLOSED 1
#define NUMGATES 1
#define MAXGAPS 35
#define TIMEBETWEENRELEASE 30000               //wait time for gate to open after fly has been released in ms
#define MINGAPWIDTH 3                          //minimum pixel width of a detected gap
#define RUNPULSE 1
#define RUNRAMP 2
#define RUNISOFF 0

//Definitions/Variables for Pulse Generator
#define maxTabSize 30

#define clockDelay  delayNanoseconds(200);  // min hi or lo time for linear array clock (min is actually 50ns)
#define clockHigh  delayNanoseconds(60);

char nUSB; //, Serial;
uint8_t volatile trgMode;
uint16_t i;
//End

uint8_t inputLine[100];       /* Console input buffer */

//uint8_t blinkTimer;
//uint8_t triggerTimer;
//uint8_t motorTimer;
//uint8_t actionTimer;

uint8_t motorState[1];
uint16_t newPosition[1];
uint16_t motorPosition[1];

uint8_t gatePosition;

uint8_t volatile triggerCnt;

//uint16_t seconds;

volatile uint8_t imageCapture;
volatile uint8_t imageTransmit;
//volatile uint8_t tempTransmit;
//volatile uint8_t flyRelease;
volatile uint8_t crFlag;

uint8_t th[128];     //array with shadows (pixels beyond a thershold point)
uint8_t pixel[128];  //Pixel intensity values in the array
uint8_t test;
uint16_t feedback, oldfeedback;
uint16_t itime;
//uint16_t temperature;
//uint16_t frameCount;

int16_t gapStart[32], gapEnd[32], gapCenter[32];
int8_t gapCount;

uint8_t volatile run;
uint16_t * ptr1;
uint16_t * ptr2;
uint16_t volatile tabSize;
uint16_t slope;

uint8_t intercept;

uint16_t volatile ramp_width;
uint16_t volatile duration;
uint16_t volatile maxIntensity;

uint8_t rampReady;
volatile uint16_t rampVal;
volatile uint16_t temp;
//extern volatile RXFIFO rxfifo;

uint8_t c;
    uint8_t idx;

  uint16_t humidity, temperature, oldtemp;
    uint16_t arg1, arg2, arg3, arg4, arg5, arg6;
//    uint8_t b2,b1,b0;
  uint16_t  j;
    int16_t start[1], end[1];
    uint8_t gateOK[1];
    uint8_t flyState[1];
    uint8_t gotFly, flyInFront;
  //  uint8_t gateTimeout[1];
//    uint8_t portValue;
    uint8_t runGates;
  uint16_t open[1], block[1];
//  uint8_t status;
    uint16_t flyCount;
//    uint8_t autoRelease;
    uint8_t countTransmit;
  int fan, gap, shadow, tempCooler, difftemperature;
  uint16_t lightIntensity, coolerIntensity;
  char  *argv[23];
  uint16_t tStamp[23];
  uint16_t state[23];

  boolean binaryImage = true;
  boolean thImage = false;
  #define  GRAYLEVELS 10
  char GRAY2ASCII[] = {' ', '.', ':', '-', '=', '+', '*', '#', '%', '@'};
 
  PWMServo sweep;
  PWMServo gate;

//  IntervalTimer motorTimer;
  IntervalTimer triggerTimer;
  IntervalTimer onePulseTimer;
//  IntervalTimer lightTimer;
 

void xatoi(char * * sp, uint16_t * vp)
{
   *vp = atoi(*sp);
}
 

// =================
// === P A R S E ===
// =================

void parse(char *line, char **argv)
{
int8_t argCount = 0;

  while (*line != '\0')
  {       /* if not the end of line ....... */
    while (*line == ',' || *line == ' ' || *line == '\t' || *line == '\n')
      *line++ = '\0';     /* replace commas and white spaces with 0    */
    *argv++ = line;          /* save the argument position     */
    argCount++;
    if (argCount == 100) break;
    while (*line != '\0' && *line != ',' && *line != ' ' &&
       *line != '\t' && *line != '\n')
     line++;             /* skip the argument until ...    */
  }
  *argv = '\0';                  /*mark the end of argument list  */
}

// ==========================
// === M E D I A N  5 ===
// ==========================

uint8_t median5(int idx)
{
  int i, j;
  uint8_t sorted[5];
  uint8_t swap;
  // local storage of values
  for( i = 0; i < 5; i++)
     sorted[i] = pixel[idx + i];
     
  for (i = 0; i < 4; i++)
  {   // Last i elements are already
      // in place
     for (j = 0; j < 4 - i; j++)
     {
        if (sorted[j] > sorted[j + 1])
        {
            swap = sorted[j];
            sorted[j] = sorted[j + 1];
            sorted[j + 1] = swap;
        }            
     }          
  }  
 
// Serial.println();
//  for( i = 0; i < 5; i++)
//  {
//     Serial.print( sorted[i]);
//     Serial.print(" ");
//  }
//  Serial.println();  
     
  return sorted[2];
}
 
 
// ==========================
// === G E T    I M A G E ===
// ==========================

void getImage(void)
{
  uint16_t i;
//  digitalWriteFast(atestPin, HIGH);
//  
  itime = 0;
  // first reset all cells by doing a dummy read
  digitalWriteFast(asyncPin, HIGH);
  digitalWriteFast(aclkPin, LOW);   // PORTA = 0x80; // SI = 1, CLK = 0
  clockDelay   // min clock time
  digitalWriteFast(aclkPin, HIGH);  // PORTA = 0xc0; // SI = 1, CLK = 1
  clockHigh
  digitalWriteFast(asyncPin, LOW);
  digitalWriteFast(aclkPin, LOW);   // PORTA = 0x00; // SI = 0, CLK = 0
  clockDelay
  for (i=0; i<775; i++)
  {
     digitalWriteFast(aclkPin, HIGH);   //  PORTA = 0x40; // SI = 0, CLK = 1
     clockHigh
     digitalWriteFast(aclkPin, LOW);    //PORTA = 0x00; // SI = 0, CLK = 0
     clockDelay
  }
//  
//  // do the integration pauseH

//  for (i=0; i<itime; i++)
//  {
//    digitalWriteFast(aclkPin, HIGH);  // PORTA = 0x40;
//    clockHigh
//    digitalWriteFast(aclkPin, LOW);   // PORTA = 0x00;
//    clockDelay
//  }

  // read out the image

digitalWriteFast(aclkPin, LOW);    // PORTA = 0x80; // SI = 1, CLK = 0
clockDelay
   
  digitalWriteFast(asyncPin, HIGH);  // PORTA = 0x80; // SI = 1, CLK = 0
  digitalWriteFast(aclkPin, HIGH);   // PORTA = 0xc0; // SI = 1, CLK = 1
  clockHigh
//digitalWriteFast(asyncPin, LOW);   //   PORTA = 0x00; // SI = 0, CLK = 0  
  digitalWriteFast(aclkPin, LOW);    // PORTA = 0x80; // SI = 1, CLK = 0
  clockDelay
  digitalWriteFast(asyncPin, LOW);   //   PORTA = 0x00; // SI = 0, CLK = 0
delayNanoseconds(120); // ADC settling time

  for (i=0; i<128; i++)
  {
    cli();
    uint16_t rawadc =  analogRead(adataPin);
    // mimic original PEZ
//    rawadc = (rawadc >> 3);  // divide by 8
//    rawadc &= 0xff; // truncate top bit
//rawadc = (rawadc >> 4);  // divide by 16
    pixel[i] =  (uint8_t) rawadc;
    // clock out the next pixel
    digitalWriteFast(aclkPin, HIGH);  // PORTA = 0x40; // SI = 0, CLK = 1
    clockHigh
    digitalWriteFast(aclkPin, LOW);  // PORTA = 0x00; // SI = 0, CLK = 0
    delayNanoseconds(120);
    sei();
  }
  // extra clock at the end
  digitalWriteFast(aclkPin, HIGH);   // PORTA = 0x40; // SI = 0, CLK = 1
  clockDelay
  digitalWriteFast(aclkPin, LOW);   // PORTA = 0x00; // SI = 0, CLK = 0
 // clockDelay
 
//  digitalWriteFast(atestPin, LOW);  //PORTB &= 0xfb; //f
   
//  for (i=0; i<123; i++) // filter results - can't do last 5
//  {
//     pixel[i] = median5(i);
//  }
   
}

// ============================
// ===  S E N D  I M A G E ====
// ============================

void sendImage(void)
{
  uint16_t i;
  if (imageTransmit)
  {  
   Serial.print("$ID,"); //  xputs(PSTR("$ID,"));
    for (i=0; i<128; i++)
    {
       if( binaryImage)   // normal image transfer
       {
          if( (pixel[i] == '\n') || (pixel[i] == '\r') )
             Serial.write(pixel[i]+1); //uart_put(pixel[i]+1);
          else
             Serial.write(pixel[i]);  // uart_put(pixel[i]);
       }
       else    
       {
          Serial.print( GRAY2ASCII[pixel[i]/26] );  // image as ASCII art to see it well in terminal program
       }          
      //      uart_put(',');
      //      xitoa((long)pixel[i],16,-2);
    }
    Serial.print("\r\n"); // (xputs(PSTR("\r\n"));
    //    uart_put('$');
    //    uart_put(((uint8_t*)&frameCount)[0]);
    //    uart_put(((uint8_t*)&frameCount)[1]);
    //    for (i=0; i<256; i++) {
      //       uart_put(pixel[i]);
    //    }
    //    imageTransmit = 0;
  }
}

//==========================
// === T H R E S H O L D ===
// =========================

void threshold(uint8_t thValue)
{
  uint16_t i;
  uint8_t gap;
 
  gapCount = 0;        //number of gaps detected
  gap = 0;             //controls whether we are searching for the end of a found gap
 
  for (i = 0; i < 128; i++)
  {  
    if (gap)
    {   //finding the end of a gap
      if (pixel[127-i] >= thValue) //Reversed array by R.Hormigo to follow reversed sensor, needed for matlab to read correctly
      {
        th[i] = 1;               //th[i] set to 1 if pixel is not inside the gap (end boundary is set to 1)
        gapEnd[gapCount] = i;
        if ((gapCount < MAXGAPS) && (gapEnd[gapCount] - gapStart[gapCount] > MINGAPWIDTH))  
          gapCount++;          //search for next gap
        gap = 0;
      }
      else
      {
        th[i] = 0;
      }
    }
    else
    {                     //finding the start of a gap
      if (pixel[127-i] <= (thValue))   //Reversed array by R.Hormigo to follow reversed sensor, needed for matlab to read correctly
      {
        th[i] = 0;        
        gapStart[gapCount] = i;
        gap = 1;               //search for end of gap in next i
      }
      else
      {
        th[i] = 1;            
      }
    }
    if( thImage)  Serial.print(th[i]);
  } // next pixel


//
//  for (int j = 0; j < 128; j++ )
//  {
//    Serial.print(th[j]);
//  }
//  Serial.println();
//  Serial.println(gapCount);
//  Serial.println(gapStart[0]);
//  Serial.println(gapEnd[0]);
 
 
  if (gap)
  {                  //if gap extends to end of array
    gapEnd[gapCount] = i;
    if (gapCount < MAXGAPS)
      gapCount++;
  }
 
  for (i=0; i<gapCount; i++)
  {
    gapCenter[i] = (gapStart[i] + gapEnd[i])>>1;      //add pixel locations, shift operator divides by 2
  }

   if( thImage)  Serial.println(' ');
}

// =====================
// === M O T O R G O ===
// =====================

void motorGo(uint8_t motor, uint8_t position)
{
//digitalWrite(enablePin, PWR_ON);
 
  //motor 0 is JP5 - OCR1A - Gate Motor
  //motor 1 is JP6 - OCR1B - Sweeper Motor
  if (position > 100) //Position has a range of 0-100%
    position = 100;
  if (motor == GATEMOTOR)
  {
    gate.write(position+36); //OCR1A = GATEMOTOROFF + (uint16_t)position * 20;
    //OCR1A = 2000 + (uint16_t)position * 20; //2000 is the initial position of the motor register
    gatePosition = position;
  }
  else if (motor == SWEEPER)
  {
//Serial.println(position);
    if (position == 0)
    {
      //substitute SWPRMOTOROFF for 2000 - no idea why
      sweep.write(SWEEPOFF); // OCR1B = SWPRMOTOROFF + (uint16_t)99 * 20; //added the delays to make sure the sweeper actually sweeps and reaches both positions      
      delay(350); //_delay_ms(2500);          //the delays may interfere with the timers in the program
      sweep.write(SWEEPEND); //SWPRMOTOROFF + (uint16_t)0 * 20); //OCR1B = SWPRMOTOROFF + (uint16_t)0 * 20;
      delay(350); //_delay_ms(2500);
      sweep.write(SWEEPOFF); //SWPRMOTOROFF + (uint16_t)99 * 20); //OCR1B = SWPRMOTOROFF + (uint16_t)99 * 20;
    }
    else if (position == 1)
    {
      sweep.write( SWEEPCAL); //SWPRMOTOROFF + (uint16_t) 20 * 20); // OCR1B = ; //used to be (uint16_t) 10 * 20;        
    }    
  }

//digitalWrite(enablePin, PWR_OFF);  
}

//void motorTimerCB(uint8_t arg) {
//  startTimer(motorTimer, 1, motorTimerCB, 0);
//}



//void actionTimerCB(uint8_t arg) {
//  flyRelease = 1;
//}
//
//void triggerTimerCB(uint8_t arg) {
//  startTimer(triggerTimer, 16, triggerTimerCB, 0);
//  PORTB |= 0x02;
//  triggerCnt++;
//  if (triggerCnt == 3) {
//    triggerCnt = 0;
//    imageCapture = 1;
//  }
//  PORTB &= 0xfd;
//}

// =================================
// === T R I G G E R  T I M E R  ===
// =================================

void triggerTimerCB()
{
static boolean tp = false;
   if( tp )
   {
      digitalWriteFast( timerPin, HIGH);
      tp = false;
   }
   else
   {
      digitalWriteFast( timerPin, LOW);    
      tp = true;
   }
     
   triggerCnt++;
   if( triggerCnt >= 3) //3
   {
      triggerCnt = 0;
      imageCapture = 1;
   }
   
}


// ===========================
// ===  I N I T   D A C  ===
// ===========================


// ===================
// === L I G H T S ===
// ===================
//------------------------IR Lighting Control--------------------------//
// new board (J007944) uses different DAC (AD5624R-3) and LED controller (LDD-1050H-DA) so that brightness goes up as voltage goes up. The LEDs will be off initially.

#ifdef ORIGINALDAC

void initDAC( void)
{
  SPI.beginTransaction(DAC);
  digitalWriteFast(csPin,LOW);   // select DAC  
  SPI.transfer(0x00);   // external reference
  SPI.transfer(0x00);
  digitalWriteFast(csPin,HIGH);   // deselect DAC  
}


//------------------------IR Lighting Control--------------------------//
//using the TLV5638CD DAC, which needs to be reverse logic for the BuckPucks. When it's high the BuckPucks will be off.
//Data is transferred in two Bytes to the TLV5638CD.
void lights(uint8_t status, uint32_t intensity)
{ //status == 1 then front, status == 2 then back
  uint32_t valB, val1, valA, val;
  //intensity = 100-intensity; //block of code that allows outA and outB to be set using a variable intensity set by the user
  //intensity = (100-intensity)*40;
 
//
// intensity = (22.12*(100-intensity)) + 1207;
//  


intensity = constrain( intensity, 0, 100);
if( intensity != 0 )
{
  intensity = 100 - intensity;
  val = intensity * 40;
}
else
{
  val = 4095; // full off
}

//  val = intensity >> 8;
//  val &= 0x0f;
//  valB = val | 0x40;
//  valA = val | 0xc0;
//  val1 = intensity & 0x00ff;

// Serial.print( val, HEX);
// Serial.println(val1, HEX);

  SPI.beginTransaction(DAC);
  digitalWriteFast(csPin,LOW);   // select DAC  
  if (status == 1)
    SPI.transfer((val >> 8) | 0xc0);
  else
    SPI.transfer((val >> 8) | 0x40);
  SPI.transfer(val & 0xff);
  digitalWriteFast(csPin,HIGH);   // deselect DAC  
}  

#else

// AD5624R-3 DAC init

void initDAC( void)
{
   // sw reset
   SPI.beginTransaction(DAC);
   digitalWriteFast(csPin,LOW);   // select DAC  
   SPI.transfer(0x28);            // sw power-on reset
   SPI.transfer16(0x0001);      
   digitalWriteFast(csPin,HIGH);  // stop transmitting  
   SPI.endTransaction();
 
   // turn on internal references on DACs
   SPI.beginTransaction(DAC);
   digitalWriteFast(csPin,LOW);   // select DAC  
   SPI.transfer(0x38);            // enable reference  xx11 1xxx xxxx xxx1
   SPI.transfer16(0x0001);      
   digitalWriteFast(csPin,HIGH);  // stop transmitting  
   SPI.endTransaction();
}

void lights(uint8_t color, uint32_t intensity)
{ //color: 1 = RED, 2 = IR, 3 is aux, intensity is 0-100%
  // but on prototype IR and RED reversed - use defines for CHRimson nd IR
   if( intensity > 100) intensity = 100;
   uint16_t value = (uint16_t)(intensity * 40);  // go from 0-100 to 0-4000 - ok so we lose the top 95.....
   color--;   // DAC channels start at 0
   #ifdef DEBUG
      Serial.print("led:");
      Serial.print(0x18 | color);
      Serial.print(" value:");
      Serial.print(value);
      Serial.print("\r\n");
   #endif      

   // in case DAC was powered on after CPU
      // turn on internal references on DACs
   SPI.beginTransaction(DAC);
   digitalWriteFast(csPin,LOW);   // select DAC  
   SPI.transfer(0x38);            // enable reference  xx11 1xxx xxxx xxx1
   SPI.transfer16(0x0001);      
   digitalWriteFast(csPin,HIGH);  // stop transmitting  
   SPI.endTransaction();
   
   SPI.beginTransaction(DAC);
   digitalWriteFast(csPin,LOW);  // select DAC
   SPI.transfer( 0x18 | color);        // write and update DAC xx01 1aaa                    
   SPI.transfer16( value << 4);      
   digitalWriteFast( csPin,HIGH);  // stop transmitting  
   SPI.endTransaction();

   if( color == (CHR-1))   // crimson monitor
   {
       if( intensity > 0 )
           digitalWrite(monitorPin, HIGH);
       else
           digitalWrite(monitorPin, LOW);    
   }
}

#endif

// ======================================
// === O N E  P U L S E    T I M E R  ===
// ======================================

// end crimson pulse and stop timer
void onePulseTimerCB()
{
   onePulseTimer.end();
   lights(CHR,0);  
}

// ===============================
// === P U L S E    T I M E R  ===
// ===============================

// pulse train and ramp timer
//void lightTimerCB()
//{
//  if (run == RUNPULSE)
//  {
//    tStamp[tPointer] = *(ptr1 + tPointer);
//    state[tPointer] = *(ptr2 + tPointer);
//    tCount++;
//    tempDbl = tCount*tStep;
//    
//    if(tempDbl > tStamp[tPointer])
//    {
//      if(state[tPointer] > 0)
//      {
//        rampVal = state[tPointer];
//      }
//      else
//      {
//        rampVal = 0;
//      }
//      tPointer++;
//    }
//  }
//  else if(run == RUNRAMP)
//  {
//    tempDbl = tCount*tStep;
//    tCount++;
//    temp = slope*10*tempDbl/duration + intercept;
//    //rampVal will be executed with the light function in the main code
//    if(rampVal>maxIntensity) //checks my intensity
//    {
//      rampVal = maxIntensity;
//    }    
//    
//    if(tempDbl < ramp_width)
//    {
//      rampVal = temp;
//    }
//    else
//    {
//      rampVal = 0;
//    }
//  }
//  else
//  {
//    temp = 0;
//    rampVal = 0;
//    tCount = 0;
//    tPointer = 0;
//    tempDbl = 0;
//  }
//  
//  //Check to see if the trigger mode is one-shot or continuous. If it is continuous, at the end of one pulse train,
//  //that is when the pointer is at the end of the look-up table, the trigger pointer is sent back to the beginning
//  //of the look-up table.
//  if((((tPointer > tabSize) || (tPointer > maxTabSize)) && run == 1) || (tempDbl > duration && run == 2))
//  {
//    if(trgMode == 0)
//    {
//      run = RUNISOFF;
//    }
//    else
//    {
//      tCount = 0;
//      tPointer = 0;
//      tempDbl = 0;
//    }
//  }  
     
//}

// ====================================
// === C O O L E R   C O N T R O L  ===
// ====================================

//---------------------------Cooler Control-------------------------------//
//void coolerControl(uint8_t status, uint8_t intensity, uint8_t diffTemp) { //status 1 is on, status 0 is off
//  if (status == 1 && diffTemp <= 30) {
//    OCR2A = ((diffTemp+60)*255/90);
//  } else if (status == 1 && diffTemp > 30) {
//    OCR2A = ((30+60)*255/90);
//  } else if (status == 2 && diffTemp <= 60) {
//    OCR2A = ((60-diffTemp)*255/90);
//  } else if (status == 2 && diffTemp > 60 ) {
//    OCR2A = 0;
//  }
//  
//  feedback = (uint16_t)OCR2A;

void coolerControl(uint8_t status, uint8_t intensity, uint8_t diffTemp)  //status 1 is on, status 0 is off
{
uint16_t peltierPWM = 0;
 
  if (status == 1 && diffTemp <= 30)
  {
     peltierPWM = (diffTemp+60)*255/90;
  }
  else if (status == 1 && diffTemp > 30)
  {
     peltierPWM = (30+60)*255/90;
  }
  else if (status == 2 && diffTemp <= 60)
  {
     peltierPWM = (60-diffTemp)*255/90;
  }
  else if (status == 2 && diffTemp > 60 )
  {
     peltierPWM = 0;
  }
  analogWrite( peltierPin, peltierPWM );
 
  feedback = peltierPWM;
   
  if (status == 1 || status == 2)
  {
    if (feedback != oldfeedback && feedback != 0)
    {
      //xprintf(PSTR("$FB,%u\r\n"), feedback);
      oldfeedback = feedback;
    }
    #ifdef DEBUG
    if( temperature != oldtemp )
    {
       Serial.print( status);
       Serial.print(" s ; diff ");
       Serial.print( diffTemp);
       Serial.print( " PWM:");
       Serial.println(peltierPWM);
    }  
    #endif  
  }
}


// ==========================
// === R E A D   T E M P  ===
// ==========================

// read temperature from TMP75
// from: https://playground.arduino.cc/Main/TMP75I2CThermometerCode/

float readTemp(){
  // Now take a Temerature Reading
  Wire.requestFrom(TMP75_Address,2 );  // Address the TMP75 and set number of bytes to receive
  byte MostSigByte = Wire.read();              // Read the first byte this is the MSB
  byte LeastSigByte = Wire.read();             // Now Read the second byte this is the LSB

  // Being a 12 bit integer use 2's compliment for negative temperature values
  int TempSum = (((MostSigByte << 8) | LeastSigByte) >> 4);
  // From Datasheet the TMP75 has a quantisation value of 0.0625 degreesC per bit
  float temp = (TempSum*0.0625);
//  #ifdef DEBUG
//    Serial.println(MostSigByte, BIN);   // Uncomment for debug of binary data from Sensor
//    Serial.println(LeastSigByte, BIN);  // Uncomment for debug  of Binary data from Sensor
//  #endif  
  return temp;                           // Return the temperature value
}


uint8_t stateTH = 1;
uint8_t indexTH  = 0;
uint8_t buff[64];
uint16_t humidityNow = 0, tempNow = 0;
uint8_t thValid = 0;



int8_t getTH(uint16_t *H, uint16_t *T)
{
   if (thValid)
   {
        *H = humidityNow;
        *T = tempNow;
//      xprintf(PSTR("Humidity/Temp/in = %d %d \n"), humidity, temp);
//      xprintf(PSTR("Humidity/Temp/in = %d %d \n"), H, T);      
        thValid = 0;
      return 0;
    }
    else
    {
        return 1;
    }
}


// =========================================================
// === P R O C E S S   T E M P   A N D   H U M I D I T Y ===
// =========================================================

//void serialEvent1()

void processTH(void)
{
//uint8_t i;
char in = Serial1.read();

    if (in == 'H')
    {
      // new data string from the sensor
      indexTH = 0;
      stateTH = 1;
      buff[indexTH++] = in;
    }
    else if (stateTH > 0)
    {
      if (in == '\r')
      {
        stateTH = 0;
       // process the data (format: Hxxx.x Tsxx.x<cr>)
       // first some sanity checking (pretty lame though, only checks to see if the H & T is in the buffer at the right place)
        if ((buff[0] == 'H') && (buff[7] == 'T'))
        {
          humidityNow = ((buff[2] - 0x30) * 100) + ((buff[3] - 0x30) * 10) + (buff[5] - 0x30);
          tempNow = ((buff[9] - 0x30) * 100) + ((buff[10] - 0x30) * 10) + ((buff[12]) - 0x30);
        // check the sign and flip if needed
          if (buff[8] == '-')
            tempNow = -tempNow;
        // indicate we have valid data
          thValid = 1;
        }
    }
    else
    {
        buff[indexTH++] = in;
        if (indexTH == sizeof(buff))
          indexTH--;
    }
  }    
}

// ==========================
// === F I N D   G A T E  ===
// ==========================

void findGate(void)
{
    gateOK[0] = 0;
    motorGo(GATE1, CLOSEDPOS);
    Serial.print("$GE,1,C\r\n");
    //delay(1000);//pause to make sure gate is physically closed
//   imageTransmit = 1;   // !!!testing
//   boolean binI = binaryImage;  // temp store current setting
//   binaryImage = false;  // show as ASCII
    getImage();
    sendImage();
//   binaryImage = binI;  // back as it was
//   imageTransmit = 0;   // !!!testing
    threshold(shadow);
    start[0] = gapStart[0]-2;//94 //add extra cushion to gate width so we dont trap legs.
    end[0] = gapEnd[0]+2;//114
    Serial.print("$GF,");
    Serial.print(start[0]);
    Serial.print(",");
    Serial.print(end[0]);
    Serial.print(",");
    Serial.print(gap);  
    Serial.print("\r\n");    
   
    //eeprom_write_word(0, start[0]);
    //eeprom_busy_wait();
    //eeprom_write_word(2, end[0]);
    //eeprom_busy_wait();
    flyState[0] = OPENED;    //return to running state
    //gateTimeout[0] = 0;
    motorGo(GATE1, open[0]);
    Serial.print("$GE,1,O\r\n");
    //seconds = 0;
    flyCount = 0;
    //runGates = 1;
}

// ==============================
// === F L Y   R E L E A S E  ===
// ==============================

void flyRelease(void)
{

  int thCnt = 0;
  boolean inGate = false;
  int i;
 
  if (flyState[0] == OPENED)
  {
    for(i = 0; i < start[0]; i++ )
    {
       if( th[i] == 0 ) thCnt ++;
    }
    for( i = start[0]; i < end[0]; i++ )
    {
      if( th[i] == 0 ) inGate = true;
    }

    if( !inGate && (thCnt > 5) ) // no fly in gap and something is above gate
    {
      Serial.print("$TS,1\r\n");
      flyState[0] = CLOSED;
      motorGo(GATE1, block[0]);
      runGates = 0;
      //gateTimeout[0] = 0;
      Serial.print("$GE,1,B\r\n");
      flyCount++;
      if (countTransmit)
      {
        Serial.print("$FC,");
        Serial.print( flyCount);
        Serial.print("\r\n");
      }
    }  
  } // endif fly state opened
}

void flyReleaseORG(void)
{
  if (flyState[0] == OPENED)
  {
    gotFly = 1;   //This is a flag that tells us if there is a fly in the gap.
    for (i=end[0]; i<=end[0]+gap; i++)
    {
      if (th[i] == 1)
      {
        gotFly = 0;
      }        
    }
    if (gotFly == 1)
    {
      Serial.print("$TS,1\r\n");
      flyState[0] = CLOSED;
      motorGo(GATE1, block[0]);
      runGates = 0;
      //gateTimeout[0] = 0;
      Serial.print("$GE,1,B\r\n");
      flyCount++;
      if (countTransmit)
      {
        Serial.print("$FC,");
        Serial.print( flyCount);
        Serial.print("\r\n");
      }
    }  
  } // endif fly state opened
}


void flyReleasePCBC(void)
{
   if (flyState[0] == OPENED)
   {              
      // see if we should close the gate
      for (i=0; i<gapCount; i++)
      {
        if (gapStart[i] > end[0]+gap)
        {
            Serial.println("$TS,1\r\n");              
        // yes, we have something after gate 1 so close gate 1
        // but make sure there is no fly under the gate
            gotFly = 0;
           for (j=start[0]; j<end[0]; j++)
           {
              if (th[j] == 0)
                gotFly = 1;
           }
           if (gotFly == 0)
           {
            // no fly at the gate so close it
              flyState[0] = CLOSED;
              motorGo(GATE1, block[0]);
              //gateTimeout[0] = 0;
              Serial.println("$GE,1,B\r\n");
              flyCount++;
              if (countTransmit)
              {
                 Serial.print("$FC");
                 Serial.println(flyCount);
              }
           }  // endif gotfly
         }  // endif gapstart
      } // end loop gapcount
   } // endif gate opened
}
 



// ==================
// ===  S E T U P ===
// ==================

void setup()
{
    pinMode(enablePin, OUTPUT);  
    digitalWrite(enablePin, PWR_OFF);  // first thing - be sure power is disabled

    pinMode(wakePin, OUTPUT);  
    digitalWrite(wakePin, PWR_OFF);  // first thing - be sure power is disabled
   
    pinMode(csPin, OUTPUT);
    digitalWrite(csPin, HIGH);

    pinMode(asyncPin, OUTPUT);
    digitalWrite(asyncPin, LOW);
   
    pinMode(aclkPin, OUTPUT);
    digitalWrite(aclkPin, LOW);
 
    pinMode(atestPin, OUTPUT);
    digitalWrite(atestPin, LOW);
   
    pinMode(timerPin, OUTPUT);
    digitalWrite(timerPin, LOW);
   
    pinMode(monitorPin, OUTPUT);
    digitalWrite(monitorPin, LOW);

     delay(100);
 //   digitalWrite(enablePin, PWR_OFF);  // first thing - be sure power is disabled  
    SPI.begin();

    initDAC(); // reset DACs  
    lights(IR,0);
    lights(CHR,0);
 //   lights(3,0);

   
   digitalWrite(enablePin, PWR_ON);  // power up LEDs
     
   digitalWriteFast(atestPin, HIGH);  
     
    // initialize the analog input port
    analogReadRes(8);
    analogReadAveraging(4);

      // from: https://playground.arduino.cc/Main/TMP75I2CThermometerCode/

    Wire.begin();
    Wire.beginTransmission(TMP75_Address);       // Address the TMP75 sensor
    Wire.write( 0x01);                           // Address the Configuration register
    Wire.write(0x40); //(B01100000);                       // Set the temperature resolution
    Wire.endTransmission();                      // Stop transmitting    
    Wire.beginTransmission(TMP75_Address);       // Address the TMP75 sensor
    Wire.write(0x00);                            // Address the Temperature register
    Wire.endTransmission();                      // Stop transmitting
   
    sweep.attach(sweepPin);  
    gate.attach(gatePin);

    gate.write(CLOSEDPOS); // OPENPOS);    // GATEMOTOROFF + (uint16_t)OPENPOS * 20;;
    sweep.write(SWEEPOFF); // SWPRMOTOROFF + (uint16_t)99 * 20;

    analogWrite( peltierPin, 0); // TCCR2A = _BV(COM2A1) | _BV(WGM20);  TCCR2B = _BV(CS22) | _BV(CS21)   | _BV(CS20);

     // initialize the serial ports
    Serial.begin(250000);  // uart_init(250000);
    Serial1.begin(9600);   // th_init(9600);

 

// wait for USB connection

    while(!Serial);

//    pixel[0] = 1;
//    pixel[1] = 5;
//    pixel[2] = 8;
//    pixel[3] = 10;
//    pixel[4] = 2;
//    pixel[5] = 20;
//    pixel[6] = 5;
//    pixel[7] = 13;
//    pixel[8] = 14;
//    pixel[9] = 2;
//    pixel[10] = 7;
//    pixel[11] = 9;
//    pixel[12] = 1;
//    pixel[13] = 0;
//    pixel[14] = 8;        
//    pixel[15] = 12;
//
//    for( int i = 0; i < 10; i++ )
//    {
//      Serial.print(pixel[i]);
//      Serial.print(" ");
//      pixel[i] = median(i);
//      Serial.println(pixel[i]);
//    }
//
//    while(1);
     
//    digitalWrite(enablePin, PWR_ON);   // now that outputs are initialized, turn on power
     
    itime = 10000;
    // set up the real time clock
//    timer_init();
 
  triggerCnt = 0;
  //frameCount = 0;
  imageCapture = 0;
  imageTransmit = 0;
  //tempTransmit = 0;
  countTransmit = 0;
  //flyRelease = 0;
  runGates = 0;
  flyCount = 0;
  //autoRelease = 0;
  //seconds = 0;
  fan = 0;
  shadow = 150;  // threshold value (for a shadow be shadow)
  lightIntensity = 0;
  flyInFront=0;
  tempCooler = 220; //temp in Celcius times 10
  difftemperature = 0;
  gap = 35; //defines the space after the gate so it wont crush the fly that has just left.
  coolerIntensity = 50;
  rampVal = 0;
  i = 0;
 
  //Pulse Generator Initiators
  /*****************************************************/
  //run = 0;
  //trgMode = 0;
  for(i=0; i<23; i++)
  {
    argv[i] = 0;
    tStamp[i] = 0;    
    state[i] = 0;
  }
   
   Serial.print("$FR,Fly Sorter - Firmware version: ");
   Serial.print(VERSION);
   Serial.print("\r\n");

   if ( !triggerTimer.begin( triggerTimerCB, 16000) )  // IntervalTimer is in usec
      Serial.print("timer Error\r\n");

   
//  triggerTimer = allocateTimer();
//  startTimer(triggerTimer, 16, triggerTimerCB, 0);
//  motorTimer = allocateTimer();
//  startTimer(motorTimer, 2, motorTimerCB, 0);
//  motorTimer.begin( motorTimerCB, 2000);
 
  ////actionTimer = allocateTimer();
 
 // xfunc_out = (void (*)(char))uart_put;
 
  start[0] = 94;
  end[0] = 114;
  //  xprintf(PSTR("Start = %d \n"), start[0]);
  //  xprintf(PSTR("End = %d \n"), end[0]);  

  //xprintf(PSTR("Open Pos = %d \n"), OPENPOS);
  //xprintf(PSTR("Blocked Pos = %d \n"), BLOCKPOS);
  open[0] = OPENPOS;
  block[0] = BLOCKPOS;

  //set default values on motor positions
  Serial.print("$GS,");
  Serial.print(open[0]);
  Serial.print(",");
  Serial.print(block[0]);
  Serial.print("\r\n");
   
  //start motor in open position
//  flyState[0] = OPENED;
//  motorGo(GATE1, open[0]);  
//  Serial.print("$GE,1,O\r\n");

  flyState[0] = CLOSED;
  motorGo(GATE1, block[0]);  
  Serial.print("$GE,1,B\r\n");

//  sweep.write(60);

//for(uint8_t pos = 10; pos < 170; pos += 1)  // goes from 10 degrees to 170 degrees
//{                                  // in steps of 1 degree
//    sweep.write(pos);              // tell servo to go to position in variable 'pos'
//    delay(10);                       // waits 15ms for the servo to reach the position
//}


//  lightTimer.begin(lightTimerCB, 1024);  // 1.024 msec timer for pulse and ramp
 
 
  //Communication w/ Matlab via characters
  //Enable Interrupt  
  sei();

} // end setup


elapsedMillis nextPulse;
int8_t pulseIndex = 0;
int16_t rampCount = 0;
int16_t intensity;
int16_t lastIntensity;
float fslope;

// ===============
// === L O O P ===
// ===============

void loop()
{

//    if (run != RUNISOFF)
//    {
//      lights(CHR, rampVal);
//    }

    if( run == RUNPULSE )
    {
       if (pulseIndex < tabSize )
       {
          if( nextPulse >= tStamp[pulseIndex])
          {
             lights(CHR, state[pulseIndex]);
//             Serial.print(millis());
//             Serial.print(" ");
//             Serial.print(pulseIndex);
//             Serial.print(" ");
//             Serial.print(tStamp[pulseIndex]);
//             Serial.print(" ");
//             Serial.println(state[pulseIndex]);
             pulseIndex++;
          }                    
       }
       else
       {
          lights(CHR, 0);
//          Serial.println("OFF");
          run = RUNISOFF;
       }
    }
    else if ( run == RUNRAMP )  
    {   // use msec timer.
      if( nextPulse >= 1 )  // check every milli, but other things may slow the loop down
      {                     // (looking at you temp/humidity). That's ok we will use the current
         rampCount += nextPulse;   // value to set the new intensity
         if( rampCount <= ramp_width)  // inc until end of ramp time
         {
            lastIntensity = intensity;
            intensity = intercept + (int16_t)(rampCount*fslope);
            if( intensity != lastIntensity) // only update if things have changed
            {
              if( intensity > maxIntensity )
                lights( CHR, maxIntensity );
              else
                lights( CHR, intensity );  
            }    
         }  
         else if (rampCount >= duration)  // flat area - wait until end, then kill the lights
         {
            lights( CHR, 0 );
            run = RUNISOFF;
         }
         nextPulse = 0;

//         Serial.print(rampCount);
//         Serial.print(" ");
//         Serial.println(intensity);
      }
    }

    while( Serial1.available() ) processTH();

    while( Serial.available())
    {
        c = Serial.read();
        if ((c == '\r') || (c == 0xff)) crFlag = 1;
        if (((c == '\b') || (c == 0x7f)) && (idx > 0))
        {
          idx--;
        }
        else if ((c >= ' ') && (idx < sizeof(inputLine) - 1))
        {
          inputLine[idx++] = c;
        }
    }

    if (crFlag )
    {
      crFlag = 0;
      inputLine[idx] = 0;
      idx  = 0;
      parse((char*)inputLine, argv);
      if (strcmp(argv[0], "Z") == 0)
      {                  
        if (strcmp(argv[1], "p") == 0)
        {
          run = RUNISOFF;
          ptr1 = &tStamp[0];
          ptr2 = &state[0];
          xatoi(&argv[2], &arg1);      
          tabSize = (uint16_t)arg1;              
          //xprintf(PSTR("arg1,%u\r\n"),arg1);
    //      getData(tStamp,state);
         
          for(i=0;i<tabSize;i++)
          {
            xatoi(&argv[i*2+3], &arg2);
            xatoi(&argv[i*2+4], &arg3);
            tStamp[i] = arg2;
            state[i] = arg3;
            //xprintf(PSTR("state,%u\r\n"),state[i]);
          }
          duration = tStamp[tabSize - 1];          
        }
        else if (strcmp(argv[1], "r") == 0)
        {
          run = RUNISOFF;
          xatoi(&argv[2], &arg1); //slope (*100)
          xatoi(&argv[3], &arg2); //intercept
          xatoi(&argv[4], &arg3); //ramp_width
          xatoi(&argv[5], &arg4); //tot_dur
          xatoi(&argv[6], &arg5); //maxIntensity
          slope = arg1;
          intercept = arg2;
          ramp_width = (uint16_t)arg3;
          duration = (uint16_t)arg4;
          maxIntensity = (uint16_t)arg5;
          fslope = ((float) slope)/ 100;

//          Serial.print(fslope);
//          Serial.print(" ");
//          Serial.print(intercept);
//          Serial.print(" ");
//          Serial.print(ramp_width);  
//          Serial.print(" ");
//          Serial.print(duration);
//          Serial.print(" ");
//          Serial.println(maxIntensity);        
                         
          //xprintf(PSTR("%f\r\n"),slope);                            
         /*} else if (strcmp(argv[1], "c") == 0) {
          clearPrg();
         } else if (strcmp(argv[1], "m") == 0) {
          //xatoi(argv[2], &arg1);
          trgMode = 1;*/
        }
        else if (strcmp(argv[1], "v") == 0)
        {
          trgMode = 0;
          Serial.print("on,1\r\n");
          rampCount = 0;      
          run = RUNRAMP;
          lights(CHR, intercept);      // set initial brightness  
          nextPulse = 0;
        }
        else if (strcmp(argv[1], "s") == 0)
        {
          trgMode = 0;
//          Serial.print("on,1\r\n");
          Serial.print("on,1\r\n");
          run = RUNPULSE;
          pulseIndex = 0;
          nextPulse = 0;
        }
        else if (strcmp(argv[1], "t") == 0)
        {
//          Serial.print("off,1\r\n");
          Serial.print("off,1\r\n"); //xprintf(PSTR("off,%u\r\n"),1);
          run = RUNISOFF;
        }
      } // endif Z
      else if (strcmp(argv[0], "R") == 0)                      //Fly release function
      {
        if (runGates == 0)
        {
          flyState[0] = OPENED;
          //gateTimeout[0] = 0;
          motorGo(GATE1, open[0]);
          Serial.print("$GE,1,O\r\n");
          runGates = 1;
        //} else if (flyState[0] == CLOSED) {
          //flyRelease = 1;
          //stopTimer(actionTimer);
        }
      } // endif R
      else if (strcmp(argv[0], "V") == 0)                     //Image transfer
      {  
//?       PORTB |= 0x09;
        imageTransmit = 1;
        binaryImage = true;
//?        PORTB &= 0xfe;
      }
      else if (strcmp(argv[0], "A") == 0)                     //image transfer in ASCII art
      {  
        imageTransmit = 1;
        binaryImage = false;
      }
      else if (strcmp(argv[0], "N") == 0)                     //Stop image transfer
      {  
        imageTransmit = 0;
      }
      else if (strcmp(argv[0], "T") == 0)                     //Fly Count recording
      {  
        //seconds = 0;
        flyCount = 0;
        countTransmit = 1;
      //} else if (strcmp(argv[0], "A") == 0) {   //Auto Release
      //  autoRelease = 1;
      //} else if (strcmp(argv[0], "M") == 0) {   //Turn off auto release
      //  autoRelease = 0;
        //stopTimer(actionTimer);
      }
      else if (strcmp(argv[0], "O") == 0)                     //Opens Gate
      {  
        motorGo(GATE1, open[0]);
        Serial.print("$GE,1,O\r\n");
        runGates = 0;
      }
      else if (strcmp(argv[0], "C") == 0)                      //Closes Gate
      {  
        motorGo(GATE1, CLOSEDPOS);
        Serial.print("$GE,1,C\r\n");
        runGates = 0;
      }
      else if (strcmp(argv[0], "B") == 0)                     //Blocks Gate  
      {  
        motorGo(GATE1, block[0]);
        Serial.print("$GE,1,B\r\n");
        runGates = 0;
      }
      else if (strcmp(argv[0], "H") == 0)                     //Cleaning Gate
      {  
        motorGo(GATE1,CLEANING);
        Serial.print("$GE,1,H\r\n");
        runGates = 0;        
      }
      else if (strcmp(argv[0], "E") == 0)                     //Shadow Threshold for detecting flies from noise
      {  
        xatoi(&argv[1], &arg1);
        shadow = (int8_t)arg1;
      }
      else if (strcmp(argv[0], "K") == 0)                     //Gap Threshold for after the gate to allow fly to escape and not get squished
      {  
        xatoi(&argv[1], &arg1);
        gap = (int8_t)arg1;
      }
      else if (strcmp(argv[0], "Q") == 0)                     //Set Cooler temp trigger
      {  
        xatoi(&argv[1], &arg1);
        tempCooler = (int8_t)arg1*10;
      }
      else if (strcmp(argv[0], "I") == 0)                     //Setting IR  lights
      {  
        xatoi(&argv[1], &arg1);
        lightIntensity = (uint16_t)arg1;  
        lights(IR,lightIntensity);
      }
      else if (strcmp(argv[0], "L") == 0)                      //Setting crimson lights
      {  
        xatoi(&argv[1], &arg1);
        lightIntensity = (uint16_t)arg1;
        lights(CHR,lightIntensity);      
      //} else if (strcmp(argv[0], "G") == 0) {   //Running
        //if (runGates == 0) {
          //flyState[0] = OPENED;
          //gateTimeout[0] = 0;
          //motorGo(GATE1, open[0]);
          //xputs(PSTR("$GE,1,O\r\n"));
          //seconds = 0;
          //flyCount = 0;
        //  runGates = 1;
        //}
      }
      else if (strcmp(argv[0], "S") == 0)                     //Sweeper command
      {  
        motorGo(SWEEPER, 0);
      }
      else if (strcmp(argv[0], "J") == 0)                      //Sweeper calibrate command
      {  
        motorGo(SWEEPER, 1);
      }
      else if( strcmp(argv[0], "w") == 0)
      {
         xatoi(&argv[1], &arg1);
         sweep.write(arg1);
      }
      else if (strcmp(argv[0], "F") == 0)                      //find gate
      {  
          findGate();
      }
      else if (strcmp(argv[0], "D") == 0)                      //set open,blocked with slider
      {  
        xatoi(&argv[1], &arg1);
        xatoi(&argv[2], &arg2);
        if ((arg1 >= 0) && (arg1 <= 100) && (arg2 >= 0) && (arg2 <= 100))
        {
          open[0] = (uint16_t)arg1;
          block[0] = (uint16_t)arg2;
          //eeprom_write_word(12, open[0]);
          //eeprom_busy_wait();
          //eeprom_write_word(18, block[0]);
          //eeprom_busy_wait();
        }
      //} else if (strcmp(argv[0], "gaps") == 0) {
      //  xputs(PSTR("Gaps:\n"));
      //  for (i=0; i<gapCount; i++) {
      //    xprintf(PSTR("  Gap %u: start = %u, end = %u, center = %u\n"), i, gapStart[i], gapEnd[i], gapCenter[i]);
      //  }
      //} else if (strcmp(argv[0], "gates") == 0) {
      //  xputs(PSTR("Gates:\n"));
      //  for (i=0; i<NUMGATES; i++) {
      //    xprintf(PSTR("  Gate %u: start = %u, end = %u, state = %u\n"), i, start[i], end[i], flyState[i]);
      //  }
      //} else if (strcmp(argv[0], "int") == 0) {
      //  xprintf(PSTR("Integration = %u\n"), itime);
      }
      else if (strcmp(argv[0], "G") == 0)
      {
         xatoi(&argv[1], &arg1);
         uint8_t pos = (uint8_t) arg1;
         motorGo(GATE1, pos);
         Serial.print("$GE,1,G\r\n");
         runGates = 0;        
      }
      else if (strcmp(argv[0], "h") == 0)                     // added for temp and humidity debug  
      {
        getTH(&humidity,&temperature);
        if (humidity != 0 && temperature != 0)
        {
          Serial.print("$TD,");
          Serial.print(humidity);
          Serial.print(",");
          Serial.print(temperature);
          Serial.print("\r\n");
        }    
      }  
      else if (strcmp(argv[0], "t") == 0)                     // added for temp and humidity debug  
      {
        float TMP75 = readTemp();
        Serial.print("$TT,");
        Serial.print(TMP75);  
        Serial.print("\r\n");
      }
      else if (strcmp(argv[0], "?") == 0)                     // version and settings
      {
          Serial.print("$FR,Fly Sorter - Firmware version: ");
          Serial.println(VERSION);
          Serial.print("shadow:");
     Serial.println(shadow);
          Serial.print("gap:");
     Serial.println(gap);
          Serial.print("set temp:");
          Serial.println(tempCooler);
          Serial.print("open: ");
          Serial.println(open[0]);              
          Serial.print("block: ");
          Serial.println(block[0]);
          Serial.print("gate at: ");
          Serial.println(gatePosition);
      }
      else if (strcmp(argv[0], "i") == 0)                     // resest and init the light DAC
      {
          initDAC();  
      }
      else if (strcmp(argv[0], "P") == 0)
      {  
     
         xatoi(&argv[1], &arg1);
         lightIntensity = (uint16_t)arg1;
         xatoi(&argv[2], &arg2);
         uint16_t pulseMillis = (uint16_t) arg2;          
         lights(CHR,lightIntensity);
         onePulseTimer.begin( onePulseTimerCB, pulseMillis * 1000 );  // IntervalTimer is in usec
      }    
      else if (strcmp(argv[0], "W") == 0) // run vibration motor
      {
          digitalWrite(wakePin, HIGH);
          delay(200);
          digitalWrite(wakePin, LOW);    
      }
      else if (strcmp(argv[0], "G") == 0)
      {
         xatoi(&argv[1], &arg1);
         motorGo(GATE1, arg1);
         runGates = 0;
      }
      else if (strcmp(argv[0], "X") == 0 )  // binary image (after thresholding)
      {
          thImage = true;
      }
      else if( strcmp(argv[0], "x") == 0 )  // turn off binary image
      {
          thImage = false;
      }
      else if (strcmp(argv[0], "Y") == 0 )  // enable LED power
      {
          digitalWrite(enablePin, PWR_ON);
      }
      else if( strcmp(argv[0], "y") == 0 )  // turn off LED power
      {
          digitalWrite(enablePin, PWR_OFF);
      }
     
           
      // endif checking argv[0]

     
    } // endif got crflag
     
   // getTH(&humidity, &temperature);
    temperature = (int16_t)(readTemp() * 10);
    //xprintf(PSTR("Humidity/Temp = %d %d \n"), humidity, temp);
    //if (temp > tempFan || fan == 1) {

    #ifdef DEBUG
    if( temperature != oldtemp )
    {
       Serial.print( temperature);
       Serial.print( " temp, set: ");
       Serial.print( tempCooler);
       Serial.print( "  ");

    }  
    #endif      
   
    if (temperature >= tempCooler)
    {    
      difftemperature = temperature - tempCooler;
      coolerControl(1,coolerIntensity,difftemperature);
      //xprintf(PSTR("$FB,%u\r\n"),feedback);
    }
    else if (temperature < tempCooler)
    {
      difftemperature = tempCooler - temperature;
      coolerControl(2,coolerIntensity,difftemperature);
    }    
    //} else {
    //  coolerControl(0,coolerIntensity,difftemp);
    //  fan = 0;
    //}
    oldtemp = temperature;
         
    if (imageCapture)
    {
      imageCapture = 0;
      getImage();
      threshold(shadow);
      sendImage();  
      if( binaryImage && imageTransmit ) // don't send this with ASCII art
      {
        getTH(&humidity,&temperature);
        if( (humidity != 0) && (temperature != 0) )
        {
           Serial.print("$TD,");
           Serial.print(humidity);
           Serial.print(",");
           Serial.print(temperature);
           Serial.print("\r\n");
           Serial.send_now();
        }        
      }
      if (runGates)
      {
          flyRelease();        
      }

    } // endif image


}// end loop
