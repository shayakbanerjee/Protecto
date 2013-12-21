//
//  PocketMaarViewController.h
//  PocketMaar
//
//  Created by Shak on 10/28/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "Sensors.h"
#import "SensorHistoryData.h"

#define PM_PERIOD 0.500f

@interface PocketMaarViewController : UIViewController

@property (strong,nonatomic) BLEDevice *d;
@property NSMutableArray *sensorsEnabled;
@property NSTimer *ppTimer;

@property (strong,nonatomic) NSMutableArray *vals;
@property NSInteger rSSI;
@property NSInteger prevRSSI;
@property NSInteger thresholdRSSI;

@property bool isPocketMaarEnabled;
@property bool isDisplayingWarning;

@property (nonatomic,retain) CMMotionManager *devMotionManager;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
-(id) init:(BLEDevice *)andSensorTag;

@end
