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
    if(self)
        self.d = nil;

    return self;
}

-(id) init:(NSString*) devFileName {
    self = [super init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Initialize variables to contain details
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.deviceFileName = devFileName;
    self.devUUIDs = [[NSMutableArray alloc] init];
    self.devNames = [[NSMutableArray alloc] init];
    self.devRanges = [[NSMutableArray alloc] init];
    self.devTypes = [[NSMutableArray alloc] init];
    self.devLookup = [[NSMutableDictionary alloc] initWithCapacity:MAX_AVAILABLE_DEVICES];
    self.availableDevices = [[NSMutableArray alloc] init];

    // Set PickProtect flag and timer
    self.isPocketMaarEnabled = NO;
    self.isDisplayingWarning = NO;
    self.rSSI = 0;
    self.thresholdRSSI = -100;
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
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.m.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    if(self.isPocketMaarEnabled) {
        for(BLEDevice* dev in self.availableDevices) dev.manager.delegate = nil;
        self.isPocketMaarEnabled = NO;
    }
    [self.m stopScan];
    self.m.delegate = nil;
    [self.ppTimer invalidate];
}

-(void)viewDidDisappear:(BOOL)animated {
    if(self.isPocketMaarEnabled) {
        self.d.manager.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView reloadData];
}

-(void)refreshDeviceList {
    [self.devUUIDs removeAllObjects];
    [self.devNames removeAllObjects];
    [self.devRanges removeAllObjects];
    [self.devTypes removeAllObjects];
    [self.availableDevices removeAllObjects];
    [self.devLookup removeAllObjects];
    
    // Scan for peripherals and re-read from file
    [self.m scanForPeripheralsWithServices:nil options:nil];
    [self readPeripheralsFromFile];
    [self.tableView reloadData];
}

- (void)loadRSSILabel:(UITableViewCell*)cell inSection:(NSInteger)section
{
    CGFloat btX = cell.bounds.origin.x + 0.80*cell.bounds.size.width;
    CGFloat btY = cell.bounds.origin.y;
    CGFloat btW = 0.20*cell.bounds.size.width;
    CGFloat btH = cell.bounds.size.height;
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(btX,btY,btW,btH)];
    sliderLabel.numberOfLines = 0;
    sliderLabel.lineBreakMode = NSLineBreakByWordWrapping;
    sliderLabel.text = [NSString stringWithFormat:@"RSSI = %d dB",self.rSSI];
    sliderLabel.backgroundColor = [UIColor whiteColor];
    sliderLabel.textColor = [UIColor blackColor];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    sliderLabel.layer.borderColor = [UIColor blackColor].CGColor;
    sliderLabel.layer.borderWidth = 1.0f;
    
    sliderLabel.tag = 6600+10*section+2;
    [cell.contentView addSubview:sliderLabel];
    
}

-(void) loadThresholdSelect:(UITableViewCell*)cell inSection:(NSInteger)section
{
    CGFloat slX = cell.bounds.origin.x;
    CGFloat slY = cell.bounds.origin.y;
    CGFloat slW = 0.8*cell.bounds.size.width;
    CGFloat slH = 0.5*cell.bounds.size.height;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(slX,(slY+slH),slW,(cell.bounds.size.height-slH))];
    slider.minimumValue = -110.0;
    slider.maximumValue = -50.0;
    slider.minimumValueImage = [UIImage imageNamed:@"math-minus-icon.png"];
    slider.maximumValueImage = [UIImage imageNamed:@"Sign-Add-icon.png"];
    slider.continuous = YES;
    slider.value = (float)self.thresholdRSSI;
    slider.tag = 6600+10*section+3;
    [slider addTarget:self action:@selector(updateThreshold:) forControlEvents:UIControlEventValueChanged];
    slider.layer.borderWidth = 1.0f;
    slider.layer.borderColor = [UIColor blackColor].CGColor;
    
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(slX,slY,slW,slH)];
    sliderLabel.text = [NSString stringWithFormat:@"Threshold Set to (%d)",self.thresholdRSSI];
    sliderLabel.backgroundColor = [UIColor whiteColor];
    sliderLabel.textColor = [UIColor blackColor];
    sliderLabel.font = [UIFont systemFontOfSize:16.0];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    sliderLabel.tag = 6600+10*section+4;
    sliderLabel.layer.borderWidth = 1.0f;
    sliderLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    [cell.contentView addSubview:slider];
    [cell.contentView addSubview:sliderLabel];
}

-(IBAction)updateThreshold:(UISlider*)sender {
    self.thresholdRSSI = (NSInteger)sender.value;
    NSInteger section = (NSInteger)(sender.tag-6603)/10;
    UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:(6600+10*section+4)];
    sliderLabel.text = [NSString stringWithFormat:@"Threshold Set to (%d)",self.thresholdRSSI];
}

-(void)displayPMWarning:(NSInteger)section
{
    NSIndexPath* ixPath = [NSIndexPath indexPathForRow:0 inSection:section];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:ixPath];
    CGFloat btX = cell.bounds.origin.x+0.25*cell.bounds.size.width;
    CGFloat btY = cell.bounds.origin.y;
    CGFloat btW = 0.25*cell.bounds.size.width;
    CGFloat btH = 0.75*cell.bounds.size.height;
    
    UIImageView* warnIm = [[UIImageView alloc] initWithFrame:CGRectMake(btX, btY, 0.5*btW, 0.8*btH)];
    warnIm.image = [UIImage imageNamed:@"Alert-Icon-.png"];
    UILabel* warnLb = [[UILabel alloc] initWithFrame:CGRectMake(btX+0.4*btW, btY, 0.7*btW, btH)];
    warnLb.textColor = [UIColor redColor];
    warnLb.backgroundColor = [UIColor clearColor];
    warnLb.text = @"Alert!";
    warnLb.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:16.0];
    warnIm.tag = 6600+10*section+5;
    warnLb.tag = 6600+10*section+6;
    [cell.contentView addSubview:warnIm];
    [cell.contentView addSubview:warnLb];
    
    // Sound the alarm
    [self.audioPlayer play];
    [self.audioPlayer setNumberOfLoops:32]; // for continuous play
}

-(void)removePMWarning:(NSInteger)section
{
    [self.audioPlayer stop];
    [[self.view viewWithTag:(6600+10*section+5)] removeFromSuperview];
    [[self.view viewWithTag:(6600+10*section+6)] removeFromSuperview];
}

-(void)loadAlarmSetButton:(UITableViewCell*)cell forSection:(NSInteger)section
{
	CGFloat btX = cell.bounds.origin.x + 0.5*cell.bounds.size.width;
    CGFloat btY = cell.bounds.origin.y;
    CGFloat btW = 0.5*cell.bounds.size.width;
    CGFloat btH = cell.bounds.size.height;
    UISwitch* onoffswitch=[[UISwitch alloc]initWithFrame:(CGRectMake(btX+btW/3.0,btY+0.1*btH,btW/3.0,0.8*btH))];
    UIImageView* offIm = [[UIImageView alloc] initWithFrame:(CGRectMake(btX+0.2*btW/3.0,btY,0.8*btW/3.0,btH))];
    offIm.image = [UIImage imageNamed:@"1389563609_lock-unlock_blue.png"];
    //offIm.contentMode = UIViewContentModeScaleAspectFill;
    //offIm.clipsToBounds = YES;
    UIImageView* onIm = [[UIImageView alloc] initWithFrame:(CGRectMake(btX+2.0*btW/3.0,btY,0.8*btW/3.0,btH))];
    onIm.image = [UIImage imageNamed:@"1389563845_lock_blue.png"];
    //onIm.contentMode = UIViewContentModeScaleAspectFill;
    //onIm.clipsToBounds = YES;
    onoffswitch.tag = 6600+10*section+1;
    [onoffswitch addTarget:self action: @selector(enablePocketMaar:) forControlEvents:UIControlEventValueChanged];

    UILabel* offLab = [[UILabel alloc] initWithFrame:(CGRectMake(btX,btY,btW/3.0,btH))];
    offLab.backgroundColor = [UIColor whiteColor];
    offLab.text = @"OFF";
    offLab.textColor = [UIColor redColor];
    offLab.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:16.0];
    UILabel* onLab = [[UILabel alloc] initWithFrame:(CGRectMake(btX+2.0*btW/3.0,btY,btW/3.0,btH))];
    onLab.backgroundColor = [UIColor whiteColor];
    onLab.text = @"ON";
    onLab.textColor = [UIColor greenColor];
    onLab.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:16.0];
    onLab.textAlignment = NSTextAlignmentCenter;
    
    // Set title label
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, 0.5*cell.bounds.size.width, cell.bounds.size.height)];
    titleLab.text = @"Set Protecto";
    titleLab.textColor = [UIColor blackColor];
    titleLab.textAlignment = NSTextAlignmentLeft;
    titleLab.backgroundColor = [UIColor clearColor];
    titleLab.font = [UIFont fontWithName:@"AmericanTypeWriter" size:16.0];
    
    [cell addSubview:titleLab];
    [cell addSubview:onoffswitch];
    [cell addSubview:onIm];
    [cell addSubview:offIm];
    //[cell addSubview:onLab];
    //[cell addSubview:offLab];
}

-(IBAction)enablePocketMaar:(id)sender {
    UISwitch* sw = (UISwitch*)sender;
    NSInteger section = (NSInteger)((sw.tag-6601)/10);
    NSString* devUID = [self.devUUIDs objectAtIndex:section];
    if([self.devLookup objectForKey:devUID]==nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Device Not in Range" message:@"The Protecto Device was not found. Please make sure it is in range and powered on" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [sw setOn:NO animated:NO];
    }
    else {
        self.d = [self.availableDevices objectAtIndex:[[self.devLookup objectForKey:devUID] unsignedIntegerValue]];
    }
    if(self.isPocketMaarEnabled && [sender isOn]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Protect One at a Time" message:@"Sorry, this version of the app only allows you to Protect one device at a time!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [sw setOn:NO animated:NO];
    } else {
        if([sw isOn]) {
            self.isPocketMaarEnabled = YES;
            self.thresholdRSSI = [[self.devRanges objectAtIndex:section] integerValue];
            if (!self.d.p.isConnected) {
                self.d.manager.delegate = self;
                [self.d.manager connectPeripheral:self.d.p options:nil];
            } else { self.d.p.delegate = self; }
            self.ppTimer = [NSTimer scheduledTimerWithTimeInterval:PM_PERIOD target:self selector:@selector(ppDisplay:) userInfo:[NSNumber numberWithInteger:section] repeats:YES];
        } else {
            self.isPocketMaarEnabled = NO;
            [self removePMWarning:section];
            if (self.d.p.isConnected) {
                [self.d.manager cancelPeripheralConnection:self.d.p];
            } else { self.d.p.delegate = nil; }
            [self.ppTimer invalidate];
        }
    }
}

- (void)updateRSSILabel:(NSInteger)section
{
	UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:(6600+10*section+2)];
    sliderLabel.text = [NSString stringWithFormat:@"RSSI = %d dB",self.rSSI];
}

-(void)ppDisplay:(NSTimer*) timer {
    // Just read the peripheral's RSSI value and display it
    [self.d.p readRSSI];
    NSInteger section = [timer.userInfo integerValue];
    //[self updateRSSILabel:section];
    
    // Check to see if peripheral got disconnected somehow. If so, reconnect
    if (!self.d.p.isConnected) {
        [self.d.manager connectPeripheral:self.d.p options:nil];
    }
    
    // RSSI based logic
    if((self.rSSI==0 || (!self.d.p.isConnected)) && self.isPocketMaarEnabled ) {
        if(!self.isDisplayingWarning) [self displayPMWarning:section];
        self.isDisplayingWarning = YES;
    } else if(self.rSSI<=self.thresholdRSSI && self.prevRSSI<=self.thresholdRSSI && self.isPocketMaarEnabled) {
        if(!self.isDisplayingWarning) [self displayPMWarning:section];
        self.isDisplayingWarning = YES;
    } else {
        if(self.isDisplayingWarning) [self removePMWarning:section];
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

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        NSLog(@"CB Central Manager now powered on -- scanning for peripherals...");
        [central scanForPeripheralsWithServices:nil options:nil];
        [self readPeripheralsFromFile];
        [self.tableView reloadData];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Found a peripheral with UUID %@",[peripheral.identifier UUIDString]);
    // Setting up the connection to devices here
    BLEDevice *b = [[BLEDevice alloc] init];
    b.manager = self.m;
    b.p = peripheral;
    b.setupData = [self makeSensorTagConfiguration];
    [self.availableDevices addObject:b];
    
    // See if UUID is already stored in data
    for(NSString* uid in self.devUUIDs) {
        NSString* periID = [[peripheral.identifier UUIDString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([periID isEqualToString:uid]) {
            [self.devLookup setObject:[NSNumber numberWithUnsignedInteger:([self.availableDevices count]-1)] forKey:uid];
            break;
        }
    }
    [self.tableView reloadData];
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

-(void)readPeripheralsFromFile {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent:self.deviceFileName];
    
    if ([filemgr fileExistsAtPath:dataFile]) {
        NSError *err;
        NSArray *storedList = [[NSString stringWithContentsOfFile:dataFile encoding:NSUTF8StringEncoding error:&err] componentsSeparatedByString:@"\n"];
        if(err) {
            NSLog(@"Error encountered in reading device list: %@",err);
            return;
        }
        for (NSString *peripheral in storedList) {
            NSArray *periDetails = [peripheral componentsSeparatedByString:@","];
            if([periDetails count]>1) NSLog(@"Peripheral Read: Name=%@, Type=%@, UUID=%@",[periDetails objectAtIndex:3],[periDetails objectAtIndex:4],[periDetails objectAtIndex:2]);
            else continue;
            
            [self.devUUIDs addObject:[periDetails objectAtIndex:2]];
            [self.devNames addObject:[periDetails objectAtIndex:3]];
            [self.devTypes addObject:[periDetails objectAtIndex:4]];
            [self.devRanges addObject:[periDetails objectAtIndex:5]];
        }
        NSLog(@"Finished reading list of stored Protecto devices");
    } else { NSLog(@"No devices are currently stored!"); }
}

#pragma mark - SensorTag configuration

-(NSMutableDictionary *) makeSensorTagConfiguration {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    // First we set ambient temperature
    [dic setValue:@"1" forKey:@"Ambient temperature active"];
    // Then we set IR temperature
    [dic setValue:@"1" forKey:@"IR temperature active"];
    // Append the UUID to make it easy for app
    [dic setValue:@"F000AA00-0451-4000-B000-000000000000"  forKey:@"IR temperature service UUID"];
    [dic setValue:@"F000AA01-0451-4000-B000-000000000000" forKey:@"IR temperature data UUID"];
    [dic setValue:@"F000AA02-0451-4000-B000-000000000000"  forKey:@"IR temperature config UUID"];
    // Then we setup the accelerometer
    [dic setValue:@"1" forKey:@"Accelerometer active"];
    [dic setValue:@"16" forKey:@"Accelerometer period"];
    [dic setValue:@"F000AA10-0451-4000-B000-000000000000"  forKey:@"Accelerometer service UUID"];
    [dic setValue:@"F000AA11-0451-4000-B000-000000000000"  forKey:@"Accelerometer data UUID"];
    [dic setValue:@"F000AA12-0451-4000-B000-000000000000"  forKey:@"Accelerometer config UUID"];
    [dic setValue:@"F000AA13-0451-4000-B000-000000000000"  forKey:@"Accelerometer period UUID"];
    
    //Then we setup the rH sensor
    [dic setValue:@"1" forKey:@"Humidity active"];
    [dic setValue:@"F000AA20-0451-4000-B000-000000000000"   forKey:@"Humidity service UUID"];
    [dic setValue:@"F000AA21-0451-4000-B000-000000000000" forKey:@"Humidity data UUID"];
    [dic setValue:@"F000AA22-0451-4000-B000-000000000000" forKey:@"Humidity config UUID"];
    
    //Then we setup the magnetometer
    [dic setValue:@"1" forKey:@"Magnetometer active"];
    [dic setValue:@"16" forKey:@"Magnetometer period"];
    [dic setValue:@"F000AA30-0451-4000-B000-000000000000" forKey:@"Magnetometer service UUID"];
    [dic setValue:@"F000AA31-0451-4000-B000-000000000000" forKey:@"Magnetometer data UUID"];
    [dic setValue:@"F000AA32-0451-4000-B000-000000000000" forKey:@"Magnetometer config UUID"];
    [dic setValue:@"F000AA33-0451-4000-B000-000000000000" forKey:@"Magnetometer period UUID"];
    
    //Then we setup the barometric sensor
    [dic setValue:@"1" forKey:@"Barometer active"];
    [dic setValue:@"F000AA40-0451-4000-B000-000000000000" forKey:@"Barometer service UUID"];
    [dic setValue:@"F000AA41-0451-4000-B000-000000000000" forKey:@"Barometer data UUID"];
    [dic setValue:@"F000AA42-0451-4000-B000-000000000000" forKey:@"Barometer config UUID"];
    [dic setValue:@"F000AA43-0451-4000-B000-000000000000" forKey:@"Barometer calibration UUID"];
    
    [dic setValue:@"1" forKey:@"Gyroscope active"];
    [dic setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [dic setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [dic setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];
    
    NSLog(@"Finished setting up SetupData");
    return dic;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.devNames count]+1;   // The +1 is for the refresh button
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section<[self.devNames count]) return 1;  // Change to 2 to get the threshold slider and RSSI label
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d_%d_Cell",indexPath.row,indexPath.section]];
    cell.backgroundColor = [UIColor whiteColor];
    if(indexPath.section<[self.devNames count]) {
        cell.layer.borderColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
        cell.layer.borderWidth = 1.0f;
        if(indexPath.row==0) {
            [self loadAlarmSetButton:cell forSection:indexPath.section];
        } else {
            [self loadRSSILabel:cell inSection:indexPath.section];
            [self loadThresholdSelect:cell inSection:indexPath.section];
        }
    } else {
        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.2*cell.bounds.size.width,0,0.6*cell.bounds.size.width,cell.bounds.size.height)];
        startLabel.text = @"Tap to Refresh";
        startLabel.textAlignment = NSTextAlignmentCenter;
        startLabel.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:16.0];
        startLabel.shadowColor = [UIColor blackColor];
        startLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        startLabel.layer.cornerRadius = 8;
        startLabel.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
        startLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:startLabel];
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:self.tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) { return nil; }
    if (section==[self.devNames count]) {
        UILabel *blankView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 20.0)];
        blankView.backgroundColor = [UIColor whiteColor];
        UIView *view = [[UIView alloc] init];
        [view addSubview:blankView];
        return view;
    }
    
    // Draw a label with the name and type of device
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 40.0)];
    label.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont fontWithName:@"AmericanTypeWriter" size:16.0];
    label.text = sectionTitle;
    
    //Draw a label with whether device is available or not
    UIImageView *avail = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.bounds.size.width-32.0, 8.0, 24.0, 24.0)];
    NSString* uid = [self.devUUIDs objectAtIndex:section];
    if([self.devLookup objectForKey:uid] != nil) avail.image = [UIImage imageNamed:@"1389564606_circle_green.png"];
    else  avail.image = [UIImage imageNamed:@"1389564581_circle_red.png"];
    avail.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    [view addSubview:avail];
    return view;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section<[self.devNames count]) return [NSString stringWithFormat:@"%@ (%@)",[self.devNames objectAtIndex:section],[self.devTypes objectAtIndex:section]];
    else return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == [self.devNames count]) return 20.0;
    else return 40.0;
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==[self.devNames count]) {  // This is the section with the refresh button
        if(self.isPocketMaarEnabled) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Can't Refresh While Active" message:@"Turn off Protecto devices before refreshing" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            [self refreshDeviceList];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
