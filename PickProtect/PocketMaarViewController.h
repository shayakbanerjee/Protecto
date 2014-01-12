//
//  PocketMaarViewController.h
//  PocketMaar
//
//  Created by Shak on 10/28/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BLEDevice.h"
#import "BLEUtility.h"
#import "Sensors.h"
#import "SensorHistoryData.h"

#define PM_PERIOD 1.00f
#define MAX_AVAILABLE_DEVICES 15

@interface PocketMaarViewController : UITableViewController <AVAudioPlayerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, UIAlertViewDelegate>

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) BLEDevice *d;
@property (strong,nonatomic) NSMutableArray *availableDevices;   // This contains the BLEDevice objects

@property NSTimer *ppTimer;
@property (strong,nonatomic) NSMutableArray *devUUIDs;
@property (strong,nonatomic) NSMutableArray *devNames;
@property (strong,nonatomic) NSMutableArray *devTypes;
@property (strong,nonatomic) NSMutableArray *devRanges;
@property (strong,nonatomic) NSMutableDictionary *devLookup;   //Key is UUID, Value is the index of the device in self.availableDevices
@property NSString* deviceFileName;

@property NSInteger rSSI;
@property NSInteger prevRSSI;
@property NSInteger thresholdRSSI;

@property bool isPocketMaarEnabled;
@property bool isDisplayingWarning;

@property (strong,nonatomic) AVAudioPlayer *audioPlayer;
-(id) init:(NSString*)devFileName;

@end
