//
//  PocketMaarViewController.m
//  PocketMaar
//
//  Created by Shak on 10/28/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "PocketMaarViewController.h"

@interface PocketMaarViewController ()

@end

@implementation PocketMaarViewController

@synthesize d;

-(id) init {
    self = [super init];
}

-(id) init:(BLEDevice *)andSensorTag {
    self = [super init];
    if (self)
        self.d = andSensorTag;
    
    self.vals = [[NSMutableArray alloc]init];
    
    // Set timers to print log and to get update values
    //self.devMotionManager = [[CMMotionManager alloc] init];
    //[self.devMotionManager startAccelerometerUpdates];  // How frequently does this need to update?
    //[self.devMotionManager startMagnetometerUpdates];  // Use devMotionManager.accelerometerUpdateIntervral
    //[self.devMotionManager startDeviceMotionUpdates];
    
    // Enable this line to get tablet heading
    //[self.devMotionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    // Set PickProtect flag and timer
    self.isPocketMaarEnabled = NO;
    self.isDisplayingWarning = NO;
    self.rSSI = 0;
    self.thresholdRSSI = -100;
    self.ppTimer = [NSTimer scheduledTimerWithTimeInterval:PM_PERIOD target:self selector:@selector(ppDisplay:) userInfo:nil repeats:YES];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AlarmEffect" ofType:@"wav"]];
    NSError *error = nil;
    if (error) NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
    else self.audioPlayer.delegate = self;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.audioPlayer prepareToPlay];
    NSLog(@"Enabled PocketMaar Device");
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    self.sensorsEnabled = [[NSMutableArray alloc] init];
    if (!self.d.p.isConnected) {
        self.d.manager.delegate = self;
        [self.d.manager connectPeripheral:self.d.p options:nil];
    } else {
        self.d.p.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    if(self.isPocketMaarEnabled) {
        self.isPocketMaarEnabled = NO;
        //[self.devMotionManager stopDeviceMotionUpdates];
    }
    [self.ppTimer invalidate];
}

-(void)viewDidDisappear:(BOOL)animated {
    if(self.isPocketMaarEnabled) {
        self.sensorsEnabled = nil;
        self.d.manager.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadRSSILabel];
    [self loadThresholdSelect];
    [self loadAlarmSetButton];
}

- (void)loadRSSILabel
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.12*self.view.bounds.size.height;
    CGFloat btW = 1.0*self.view.bounds.size.width;
    CGFloat btH = 0.15*self.view.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.text = [NSString stringWithFormat:@"Received Signal Strength = %d dB",self.rSSI];
    sliderLabel.backgroundColor = [UIColor whiteColor];
    sliderLabel.textColor = [UIColor blackColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    
    sliderLabel.tag = 6604;
    [self.view addSubview:sliderLabel];
    
}

-(void) loadThresholdSelect
{
    CGFloat slX = self.view.bounds.origin.x + 0.1*self.view.bounds.size.width;
    CGFloat slY = self.view.bounds.origin.y + 0.7*self.view.bounds.size.width;
    CGFloat slW = 0.8*self.view.bounds.size.width;
    CGFloat slH = 0.15*self.view.bounds.size.height;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(slX,(slY+slH),slW,slH)];
    //[slider setBackgroundColor:[UIColor blackColor]];
    slider.minimumValue = -110.0;
    slider.maximumValue = -50.0;
    slider.minimumValueImage = [UIImage imageNamed:@"minus_sign.png"];
    slider.maximumValueImage = [UIImage imageNamed:@"plus_sign.png"];
    slider.continuous = YES;
    slider.value = (float)self.thresholdRSSI;
    [slider addTarget:self action:@selector(updateThreshold:) forControlEvents:UIControlEventValueChanged];
    slider.tag = 6607;

    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(slX,slY,slW,slH)];
    sliderLabel.text = [NSString stringWithFormat:@"Set Y Sensitivity (%d)",self.thresholdRSSI];
    sliderLabel.backgroundColor = [UIColor whiteColor];
    sliderLabel.textColor = [UIColor blackColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    sliderLabel.tag = 6608;
    [self.view addSubview:slider];
    [self.view addSubview:sliderLabel];
}

-(IBAction)updateThreshold:(UISlider*)sender {
    self.thresholdRSSI = (NSInteger)sender.value;
    UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6608];
    sliderLabel.text = [NSString stringWithFormat:@"Set Threshold (%d)",self.thresholdRSSI];
}

-(void)displayPMWarning
{
	CGFloat btX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.54*self.view.bounds.size.height;
    CGFloat btW = 0.25*self.view.bounds.size.width;
    CGFloat btH = 0.25*self.view.bounds.size.height;
    CGFloat lbX = self.view.bounds.origin.x + 0.30*self.view.bounds.size.width;
    CGFloat lbW = 0.65*self.view.bounds.size.width;
    UIImageView* warnIm = [[UIImageView alloc] initWithFrame:CGRectMake(btX, btY, btW, btH)];
    warnIm.image = [UIImage imageNamed:@"Alert-Icon-.png"];
    UILabel* warnLb = [[UILabel alloc] initWithFrame:CGRectMake(lbX, btY, lbW, btH)];
    warnLb.textColor = [UIColor redColor];
    warnLb.text = @"PocketMaar Alert!";
    warnLb.font = [UIFont fontWithName:@"Arial" size:18.0];
    warnIm.tag = 6601;
    warnLb.tag = 6602;
    [self.view addSubview:warnIm];
    [self.view addSubview:warnLb];
    
    // Sound the alarm
    [self.audioPlayer play];
    [self.audioPlayer setNumberOfLoops:INT32_MAX]; // for continuous play
}

-(void)removePMWarning
{
    [self.audioPlayer stop];
    [[self.view viewWithTag:6601] removeFromSuperview];
    [[self.view viewWithTag:6602] removeFromSuperview];
}

-(void)loadAlarmSetButton
{
	CGFloat btX = self.view.bounds.origin.x + 0.40*self.view.bounds.size.width;
    CGFloat btY = self.view.bounds.origin.y + 0.32*self.view.bounds.size.height;
    CGFloat btW = 0.55*self.view.bounds.size.width;
    CGFloat btH = 0.10*self.view.bounds.size.height;
    UISwitch* onoffswitch=[[UISwitch alloc]initWithFrame:(CGRectMake(btX+0.2*btW/0.55,btY,0.15*btW/0.55,btH))];
    UIImageView* offIm = [[UIImageView alloc] initWithFrame:(CGRectMake(btX,btY,0.2*btW/0.55,btH))];
    offIm.image = [UIImage imageNamed:@"Lock-Unlock-icon.png"];
    //offIm.contentMode = UIViewContentModeScaleAspectFill;
    //offIm.clipsToBounds = YES;
    UIImageView* onIm = [[UIImageView alloc] initWithFrame:(CGRectMake(btX+0.35*btW/0.55,btY,0.2*btW/0.55,btH))];
    onIm.image = [UIImage imageNamed:@"Lock-Lock-icon.png"];
    //onIm.contentMode = UIViewContentModeScaleAspectFill;
    //onIm.clipsToBounds = YES;
    NSLog(@"%f %f %f %f",onIm.frame.origin.x,onIm.frame.origin.y,onIm.frame.size.width,onIm.frame.size.height);
    NSLog(@"%f %f %f %f",offIm.frame.origin.x,offIm.frame.origin.y,offIm.frame.size.width,offIm.frame.size.height);
    
    [onoffswitch addTarget:self action: @selector(enablePocketMaar:) forControlEvents:UIControlEventValueChanged];
    if(self.isPocketMaarEnabled) [onoffswitch setOn:YES];
    else [onoffswitch setOn:NO];
    CGFloat lbX = self.view.bounds.origin.x + 0.05*self.view.bounds.size.width;
    CGFloat lbW = 0.3*self.view.bounds.size.width;
    UILabel* devLb = [[UILabel alloc] initWithFrame:CGRectMake(lbX, btY, lbW, btH)];
    devLb.text = @"Set Lock";
    devLb.textColor = [UIColor blackColor];
    devLb.adjustsFontSizeToFitWidth = YES;
    devLb.minimumScaleFactor = 0.5;
    devLb.tag = 6605;
    onoffswitch.tag = 6606;
    [self.view addSubview:devLb];
    [self.view addSubview:onoffswitch];
    [self.view addSubview:onIm];
    [self.view addSubview:offIm];
}

-(IBAction)enablePocketMaar:(id)sender {
    if([sender isOn]) self.isPocketMaarEnabled = YES;
    else self.isPocketMaarEnabled = NO;
}

- (void)updateRSSILabel
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:6604];
    sliderLabel.text = [NSString stringWithFormat:@"Received Signal Strength = %d dB",self.rSSI];
}

-(void)ppDisplay:(NSTimer*) timer {
    // Just read the peripheral's RSSI value and display it
    [self.d.p readRSSI];
    [self updateRSSILabel];

    // Check to see if peripheral got disconnected somehow. If so, reconnect
    if (!self.d.p.isConnected) {
        [self.d.manager connectPeripheral:self.d.p options:nil];
    }
    
    // RSSI based logic
    if((self.rSSI==0 || (!self.d.p.isConnected)) && self.isPocketMaarEnabled ) {
        if(!self.isDisplayingWarning) [self displayPMWarning];
        self.isDisplayingWarning = YES;
    } else if(self.rSSI<=self.thresholdRSSI && self.prevRSSI<=self.thresholdRSSI && self.isPocketMaarEnabled) {
        if(!self.isDisplayingWarning) [self displayPMWarning];
        self.isDisplayingWarning = YES;
    } else {
        if(self.isDisplayingWarning) [self removePMWarning];
        self.isDisplayingWarning = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@".");
    for (CBService *s in peripheral.services) [peripheral discoverCharacteristics:nil forService:s];
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@, error = %@",characteristic.UUID, error);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic.UUID,error);
}

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"RSSI Received at %f is %d dB",[[NSDate date] timeIntervalSince1970],[peripheral.RSSI integerValue]);
    self.prevRSSI = self.rSSI;
    self.rSSI = [peripheral.RSSI integerValue];
}

@end
