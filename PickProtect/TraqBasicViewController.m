//
//  RunReadPNGViewController.m
//  Run_Read_PNG
//
//  Created by Shak on 10/08/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "TraqBasicViewController.h"
#import "deviceSelector.h"

@interface TraqBasicViewController ()

@end

@implementation TraqBasicViewController

@synthesize d;
@synthesize sensorsEnabled;
@synthesize sensorHistory;

-(id) init {
    self = [super init];
}

-(id) init:(BLEDevice *)andSensorTag {
    self = [super init];
    if (self)
        self.d = andSensorTag;
    self.magSensor = [[sensorMAG3110 alloc] init];
    self.gyroSensor = [[sensorIMU3000 alloc] init];
    
    self.currentVal = [[sensorTagValues alloc]init];
    self.prevVal = [[sensorTagValues alloc]init];
    self.vals = [[NSMutableArray alloc]init];
    
    // Set timers to print log and to get update values
    self.sensorHistory = [[SensorHistoryData alloc] init:1 withSamples:400];
    //self.devMotionManager = [[CMMotionManager alloc] init];
    //[self.devMotionManager startAccelerometerUpdates];  // How frequently does this need to update?
    //[self.devMotionManager startMagnetometerUpdates];  // Use devMotionManager.accelerometerUpdateIntervral
    //[self.devMotionManager startDeviceMotionUpdates];
    
    // Enable this line to get tablet heading
    //[self.devMotionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    // Set PickProtect flag and timer
    self.isPickProtectEnabled = YES;
    self.ppTimer = [NSTimer scheduledTimerWithTimeInterval:PP_PERIOD target:self selector:@selector(ppDisplay:) userInfo:nil repeats:YES];
    NSLog(@"Enabled TraQ Device");
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.isPickProtectEnabled) {
        self.sensorsEnabled = [[NSMutableArray alloc] init];
        if (!self.d.p.isConnected) {
            self.d.manager.delegate = self;
            [self.d.manager connectPeripheral:self.d.p options:nil];
        } else {
            self.d.p.delegate = self;
            [self configureSensorTag];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    if(self.isPickProtectEnabled) {
        self.isPickProtectEnabled = NO;
        [self deconfigureSensorTag];
        //[self.devMotionManager stopDeviceMotionUpdates];
    }
    [self.ppTimer invalidate];
}

-(void)viewDidDisappear:(BOOL)animated {
    if(self.isPickProtectEnabled) {
        self.sensorsEnabled = nil;
        self.d.manager.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadRSSILabel];
    [self loadQuaternionLabel];
    [self loadGyroLabel];
    [self loadAccLabel];
}

- (void)loadRSSILabel
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.02*self.view.bounds.size.height;
    CGFloat btW = 1.0*self.view.bounds.size.width;
    CGFloat btH = 0.15*self.view.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.text = [NSString stringWithFormat:@"Received Signal Strength = %d dB",self.rSSI];
    sliderLabel.backgroundColor = [UIColor blackColor];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    
    sliderLabel.tag = 6604;
    [self.view addSubview:sliderLabel];
    
}

- (void)loadQuaternionLabel
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.22*self.view.bounds.size.height;
    CGFloat btW = 1.0*self.view.bounds.size.width;
    CGFloat btH = 0.15*self.view.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.text = [NSString stringWithFormat:@"Quaternion: %f %f %f %f",self.currentVal.quatw,self.currentVal.quatx,self.currentVal.quaty,self.currentVal.quatz];
    sliderLabel.backgroundColor = [UIColor blackColor];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    
    sliderLabel.tag = 6605;
    [self.view addSubview:sliderLabel];
    
}

- (void)loadGyroLabel
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.42*self.view.bounds.size.height;
    CGFloat btW = 1.0*self.view.bounds.size.width;
    CGFloat btH = 0.15*self.view.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.text = [NSString stringWithFormat:@"Gyro Data: %f %f %f",self.currentVal.gyroX,self.currentVal.gyroY,self.currentVal.gyroZ];
    sliderLabel.backgroundColor = [UIColor blackColor];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    
    sliderLabel.tag = 6606;
    [self.view addSubview:sliderLabel];
    
}
- (void)loadAccLabel
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.62*self.view.bounds.size.height;
    CGFloat btW = 1.0*self.view.bounds.size.width;
    CGFloat btH = 0.15*self.view.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.text = [NSString stringWithFormat:@"Accel Data: %1.2f %1.2f %1.2f",self.currentVal.accX,self.currentVal.accY,self.currentVal.accZ];
    sliderLabel.backgroundColor = [UIColor blackColor];
    sliderLabel.textColor = [UIColor whiteColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    
    sliderLabel.tag = 6607;
    [self.view addSubview:sliderLabel];
    
}

- (void)updateRSSILabel
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6604];
    sliderLabel.text = [NSString stringWithFormat:@"Received Signal Strength = %d dB",self.rSSI];
}
- (void)updateQuaternionLabel
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6605];
    sliderLabel.text = [NSString stringWithFormat:@"Quaternion: %1.2f %1.2f %1.2f %1.2f",self.currentVal.quatw,self.currentVal.quatx,self.currentVal.quaty,self.currentVal.quatz];
}
- (void)updateGyroLabel
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6606];
    sliderLabel.text = [NSString stringWithFormat:@"Gyro Data: %3.2f %3.2f %3.2f",self.currentVal.gyroX,self.currentVal.gyroY,self.currentVal.gyroZ];
}
- (void)updateAccLabel
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6607];
    sliderLabel.text = [NSString stringWithFormat:@"Accel Data: %1.2f %1.2f %1.2f",self.currentVal.accX,self.currentVal.accY,self.currentVal.accZ];
}

-(void)ppDisplay:(NSTimer*) timer {
    // Just read the peripheral's RSSI value and display it
    [self.d.p readRSSI];
    [self updateRSSILabel];
    [self updateQuaternionLabel];
    [self updateGyroLabel];
    [self updateAccLabel];
    NSLog(@"Vals,%f,%f,%f,%f,%f,%f,%f",self.currentVal.quatw,self.currentVal.quatx,self.currentVal.quaty,self.currentVal.quatz,self.currentVal.accX,self.currentVal.accY,self.currentVal.accZ);
    
    // Check to see if peripheral got disconnected somehow. If so, reconnect
    if (!self.d.p.isConnected) {
        [self.d.manager connectPeripheral:self.d.p options:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) configureSensorTag {
    // Read all the stored values and keys in Sensor Tag
    for(NSString *key in [self.d.setupData allKeys]) {
        NSLog(@"%@",[self.d.setupData objectForKey:key]);
    }
    
    // Configure sensortag, turning on Sensors and setting update period for sensors etc ...
    
    if ([self sensorEnabled:@"Accelerometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer period UUID"]];
        //NSInteger period = [[self.d.setupData valueForKey:@"Accelerometer period"] integerValue];
        //uint8_t periodData = (uint8_t)(period / 10);
        uint8_t periodData = (uint8_t)(ACCELEROMETER_PERIOD*1000);
        NSLog(@"Accelerometer Period = %d",periodData);
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]];
        //[BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
        [self.sensorsEnabled addObject:@"Accelerometer"];
    }
    
    if ([self sensorEnabled:@"Magnetometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer config UUID"]];
        CBUUID *pUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer period UUID"]];
        //NSInteger period = [[self.d.setupData valueForKey:@"Magnetometer period"] integerValue];
        //uint8_t periodData = (uint8_t)(period / 10);
        uint8_t periodData = (uint8_t)250;
        NSLog(@"Magnetometer Period = %d",periodData);
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:pUUID data:[NSData dataWithBytes:&periodData length:1]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Magnetometer"];
    }
    if ([self sensorEnabled:@"Humidity active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity config UUID"]];
        uint8_t data = 0x01;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Humidity"];
    }
    
    if ([self sensorEnabled:@"Barometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer config UUID"]];
        //Issue calibration to the device
        uint8_t data = 0x02;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer calibration UUID"]];
        [BLEUtility readCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID];
        [self.sensorsEnabled addObject:@"Barometer"];
    }
    if ([self sensorEnabled:@"Gyroscope active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x07;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
        [self.sensorsEnabled addObject:@"Gyroscope"];
    }
    [self.d.p readRSSI];
}

-(void) deconfigureSensorTag {
    if ([self sensorEnabled:@"Accelerometer active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Humidity active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Magnetometer active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Gyroscope active"]) {
        CBUUID *sUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]];
        CBUUID *cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope config UUID"]];
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
    }
    if ([self sensorEnabled:@"Barometer active"]) {
        CBUUID *sUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer service UUID"]];
        CBUUID *cUUID = [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer config UUID"]];
        //Disable sensor
        uint8_t data = 0x00;
        [BLEUtility writeCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
        cUUID =  [CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]];
        [BLEUtility setNotificationForCharacteristic:self.d.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
        
    }
}

-(bool)sensorEnabled:(NSString *)Sensor {
    NSString *val = [self.d.setupData valueForKey:Sensor];
    if (val) {
        if ([val isEqualToString:@"1"]) return TRUE;
    }
    return FALSE;
}

-(int)sensorPeriod:(NSString *)Sensor {
    NSString *val = [self.d.setupData valueForKey:Sensor];
    return [val integerValue];
}



#pragma mark - CBCentralManager delegate function

-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

-(void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}


#pragma mark - CBperipheral delegate functions

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"..");
    if ([service.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope service UUID"]]]) {
        [self configureSensorTag];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@".");
    for (CBService *s in peripheral.services) [peripheral discoverCharacteristics:nil forService:s];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@, error = %@",characteristic.UUID, error);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    /*if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Accelerometer data UUID"]]]) {
        //float x = [sensorKXTJ9 calcXValue:characteristic.value];
        //float y = [sensorKXTJ9 calcYValue:characteristic.value];
        //float z = [sensorKXTJ9 calcZValue:characteristic.value];
        //self.currentVal.accX = x;
        //self.currentVal.accY = y;
        //self.currentVal.accZ = z;
        //self.currentVal.timeStamp = [[NSDate date] timeIntervalSince1970];
    }*/
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Magnetometer data UUID"]]]) {
        
        //float x = [self.magSensor calcXValue:characteristic.value];
        //float y = [self.magSensor calcYValue:characteristic.value];
        //float z = [self.magSensor calcZValue:characteristic.value];
        float x = [self.magSensor calcAccX:characteristic.value];
        float y = [self.magSensor calcAccY:characteristic.value];
        float z = [self.magSensor calcAccZ:characteristic.value];
        self.currentVal.accX = x;
        self.currentVal.accY = y;
        self.currentVal.accZ = z;
        //NSLog(@"Accelerometer updated through magnetometer notification");
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Humidity data UUID"]]]) {
        //float rHVal = [sensorSHT21 calcPress:characteristic.value];
        //self.currentVal.humidity = rHVal;
        self.currentVal.quatw = [sensorSHT21 calcQw:characteristic.value];
        self.currentVal.quatx = [sensorSHT21 calcQx:characteristic.value];
        //NSLog(@"Quaternion W,X updated through humidity notification");
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Barometer data UUID"]]]) {
        //int pressure = [self.baroSensor calcPressure:characteristic.value];
        //self.currentVal.press = pressure;
        self.currentVal.quaty = [self.baroSensor calcQy:characteristic.value];
        self.currentVal.quatz = [self.baroSensor calcQz:characteristic.value];
        //NSLog(@"Quaternion Y,Z updated through barometer notification");
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:[self.d.setupData valueForKey:@"Gyroscope data UUID"]]]) {
        //float x = [self.gyroSensor calcXValue:characteristic.value];
        //float y = [self.gyroSensor calcYValue:characteristic.value];
        //float z = [self.gyroSensor calcZValue:characteristic.value];
        float x = [self.gyroSensor calcGyroX:characteristic.value];
        float y = [self.gyroSensor calcGyroY:characteristic.value];
        float z = [self.gyroSensor calcGyroZ:characteristic.value];
        self.currentVal.gyroX = x;
        self.currentVal.gyroY = y;
        self.currentVal.gyroZ = z;
        //NSLog(@"Gyro updated: %f %f %f",x,y,z);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"RSSI Received at %f is %d dB",[[NSDate date] timeIntervalSince1970],[peripheral.RSSI integerValue]);
    self.rSSI = [peripheral.RSSI integerValue];
}

-(void) outputHistory {
    NSLog(@"Outputting sensor history for %d samples, %d measurements",self.sensorHistory.numSamples,self.sensorHistory.numMeasures);
    while(![self.sensorHistory isEmpty]) {
        NSMutableArray *recordMeas = [self.sensorHistory dequeueData];
        NSLog(@"%f",[[recordMeas objectAtIndex:0] integerValue]);
    }
}

@end

