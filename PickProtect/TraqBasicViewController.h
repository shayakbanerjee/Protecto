//
//  RunReadPNGFirstViewController.h
//  PickProtect
//
//  Created by Shak on 10/4/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "Sensors.h"
#import "SensorHistoryData.h"

#define PP_PERIOD 0.050f
#define ACCELEROMETER_PERIOD 0.010f    // Can be a minimum of 10ms


@interface TraqBasicViewController : UIViewController
    
@property (strong,nonatomic) BLEDevice *d;
@property NSMutableArray *sensorsEnabled;
@property (strong,nonatomic) sensorMAG3110 *magSensor;
@property (strong,nonatomic) sensorC953A *baroSensor;
@property (strong,nonatomic) sensorIMU3000 *gyroSensor;
@property NSTimer *ppTimer;

@property (strong,nonatomic) sensorTagValues *currentVal;
@property (strong,nonatomic) sensorTagValues *prevVal;
@property (strong,nonatomic) NSMutableArray *vals;
@property NSInteger rSSI;

@property float sensorGx, sensorGy, sensorGz;

@property bool isPickProtectEnabled;

@property (strong,nonatomic) SensorHistoryData *sensorHistory;
@property (nonatomic,retain) CMMotionManager *devMotionManager;

-(id) init:(BLEDevice *)andSensorTag;
    
-(void) configureSensorTag;
-(void) deconfigureSensorTag;

@end
