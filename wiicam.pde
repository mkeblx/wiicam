/* title: test_ir_cam
 * description: wii ir camera reading test
 */

#include <Wire.h>

#define IR_CAM_ADDR 0xB0
#define DELAY1       100
#define DELAY2       100
#define DELAY3         5
#define LED_PIN       13
#define PWR_PIN        2
#define BUF_SIZE      16
#define NUM_POINTS     4
#define BYTES_PER_PT   4

int slaveAddress;
boolean led = false;
byte buf[BUF_SIZE];
int i;
boolean val;
byte tmp;

//check this vs int
unsigned short pts_x[NUM_POINTS];
unsigned short pts_y[NUM_POINTS];

int s;

void setup()
{
   //setup power for oscillator
   //pinMode(PWR_PIN, OUTPUT);
   //digitalWrite(PWR_PIN, HIGH);
   delay(1000);

    int j;
    slaveAddress = IR_CAM_ADDR >> 1;   // This results in 0x21 as the address to pass to TWI
    Serial.begin(9600);
    pinMode(LED_PIN, OUTPUT); 
    
    Wire.begin();
    // IR sensor initialize
    Write_2bytes(0x30,0x01); delay(10);
    Write_2bytes(0x30,0x08); delay(10);
    Write_2bytes(0x06,0x90); delay(10);
    Write_2bytes(0x08,0xC0); delay(10);
    Write_2bytes(0x1A,0x40); delay(10);
    Write_2bytes(0x33,0x33); delay(10);
    delay(500);
}
void loop()
{
   led = !led;
   val = (led) ? HIGH : LOW;
   digitalWrite(LED_PIN, val);

    //IR sensor read
    Wire.beginTransmission(slaveAddress);
    Wire.send(0x36);
    Wire.endTransmission();

    //null buf contents
    Wire.requestFrom(slaveAddress, BUF_SIZE);
    for (i = 0; i < BUF_SIZE; i++)
    {
      buf[i]=0;
    }
    
    i=0;
    
    //receive
    while (Wire.available() && i < BUF_SIZE)
    { 
        buf[i] = Wire.receive();
        i++;
   }

    //buf filled so pack data
   packData();   
   //and print to serial
   printOutData();   
}

void packData()
{
  int t = 0;
 
 //pack it in nicely
 for (i = 0; i < NUM_POINTS; i++)
 {
   t = (i + 1) * (NUM_POINTS - 1);
   pts_x[i] = buf[t - 2];
   pts_y[i] = buf[t - 1];
   tmp = buf[t];
   pts_x[i] += (tmp & 0x30) << 4;
   pts_y[i] += (tmp & 0xC0) << 2;
 }
}

void printOutData()
{
 Serial.println("---Full Data Set---");
 for (i = 0; i < NUM_POINTS; i++)
 {
   Serial.print("P"); Serial.print(i); Serial.print(":[");
   Serial.print(pts_x[i]); Serial.print(","); 
   Serial.print(pts_y[i]); Serial.print("]");
   Serial.println();
 }
}

void Write_2bytes(byte d1, byte d2)
{
    Wire.beginTransmission(slaveAddress);
    Wire.send(d1); Wire.send(d2);
    Wire.endTransmission();
}
