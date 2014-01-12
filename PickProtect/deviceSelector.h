/*
 *  deviceSelector.h
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"
#import "PocketMaarViewController.h"
#import "AdditionalDevDataController.h"
#define MAX_SEARCH_TRIES 5

@interface deviceSelector : UITableViewController <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;
@property (strong,nonatomic) NSMutableArray *storedUUIDs;
@property NSTimer *devSearchTimer;
@property NSInteger numberOfSearchTries;
@property (strong, nonatomic) UIActivityIndicatorView* busyIndicator;
@property NSIndexPath* searchButtonIndex;

-(NSMutableDictionary *) makeSensorTagConfiguration;

@end

