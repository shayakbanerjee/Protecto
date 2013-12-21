/*
*  Sensors.h
*
* Created by Ole Andreas Torvmark on 10/2/12.
* Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
* ALL RIGHTS RESERVED
*/

#import <Foundation/Foundation.h>

#define QUATERNION_RANGE 16384.0f
#define ACC_RANGE (32768.0 / 16.0)    //+/-8g (reason for multiplication by 0.5 is unknown)
#define GYRO_RANGE (32768.0 / 500.0 )   // +/-500 degrees per sec

@interface  sensorC953A: NSObject

///Calibration values unsigned
@property UInt16 c1,c2,c3,c4;
///Calibration values signed
@property int16_t c5,c6,c7,c8;

-(id) initWithCalibrationData:(NSData *)data;

-(int) calcPressure:(NSData *)data;
-(float) calcQy:(NSData *)data;
-(float) calcQz:(NSData *)data;

@end



@interface sensorIMU3000: NSObject

@property float lastX,lastY,lastZ;
@property float calX,calY,calZ;

#define IMU3000_RANGE 500.0

-(id) init;

-(void) calibrate;
-(float) calcXValue:(NSData *)data;
-(float) calcYValue:(NSData *)data;
-(float) calcZValue:(NSData *)data;
-(float) calcGyroX:(NSData *)data;
-(float) calcGyroY:(NSData *)data;
-(float) calcGyroZ:(NSData *)data;
+(float) getRange;

@end

@interface sensorKXTJ9 : NSObject

#define KXTJ9_RANGE 4.0

+(float) calcXValue:(NSData *)data;
+(float) calcYValue:(NSData *)data;
+(float) calcZValue:(NSData *)data;
+(float) getRange;

@end

@interface sensorMAG3110 : NSObject

@property float lastX,lastY,lastZ;
@property float calX,calY,calZ;

#define MAG3110_RANGE 2000.0

-(id) init;
-(void) calibrate;
-(float) calcXValue:(NSData *)data;
-(float) calcYValue:(NSData *)data;
-(float) calcZValue:(NSData *)data;
-(float) calcAccX:(NSData *)data;
-(float) calcAccY:(NSData *)data;
-(float) calcAccZ:(NSData *)data;
+(float) getRange;

@end

@interface sensorTMP006 : NSObject



+(float) calcTAmb:(NSData *)data;
+(float) calcTAmb:(NSData *)data offset:(int)offset;
+(float) calcTObj:(NSData *)data;
@end

@interface sensorSHT21 : NSObject

+(float) calcPress:(NSData *)data;
+(float) calcTemp:(NSData *)data;
+(float) calcQw:(NSData *)data;
+(float) calcQx:(NSData *)data;

@end



@interface sensorTagValues : NSObject

@property float tAmb;
@property float tIR;
@property float press;
@property float humidity;
@property float accX;
@property float accY;
@property float accZ;
@property float gyroX;
@property float gyroY;
@property float gyroZ;
@property float magX;
@property float magY;
@property float magZ;
@property float quatw;
@property float quatx;
@property float quaty;
@property float quatz;
//@property NSString *timeStamp;
@property double timeStamp;

@end