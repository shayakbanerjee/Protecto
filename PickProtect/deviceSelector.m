/*
 *  deviceSelector.m
 *
 * Created by Ole Andreas Torvmark on 10/2/12.
 * Copyright (c) 2012 Texas Instruments Incorporated - http://www.ti.com/
 * ALL RIGHTS RESERVED
 */

#import "deviceSelector.h"

@interface deviceSelector ()

@end

@implementation deviceSelector
@synthesize m,nDevices,sensorTags;

- (id)initWithStyle:(UITableViewStyle)style
{
    NSLog(@"Starting deviceSelector");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        self.nDevices = [[NSMutableArray alloc]init];
        self.sensorTags = [[NSMutableArray alloc]init];
        self.storedUUIDs = [[NSMutableArray alloc] init];
        //self.title = @"Select Pick Protect Device";
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.tableView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+44.0, self.view.frame.size.width, self.view.frame.size.height-44.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [super viewDidLoad];
    [self.tableView reloadData];
}

-(void)searchForDevice:(NSTimer*) timer {
    [self.m scanForPeripheralsWithServices:nil options:nil];
    self.numberOfSearchTries--;
    if(self.numberOfSearchTries ==0) {
        [self.m stopScan];
        [timer invalidate];
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        [self.tableView deselectRowAtIndexPath:self.searchButtonIndex animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    [self readPeripheralsFromFile];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.m stopScan];
    self.m.delegate = nil;
    self.m = nil;
    [self emptyDeviceList];
    [self.devSearchTimer invalidate];
}

-(void)emptyDeviceList {
    [self.nDevices removeAllObjects];
    [self.storedUUIDs removeAllObjects];
    [self.sensorTags removeAllObjects];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section==0) return 1;
    else return sensorTags.count;   //Add 1 for the first button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(indexPath.section ==0) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d_%d_Cell",indexPath.row,indexPath.section]];
        
        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.2*cell.bounds.size.width,0,0.6*cell.bounds.size.width,cell.bounds.size.height)];
        startLabel.text = @"Tap to Search";
        startLabel.textAlignment = NSTextAlignmentCenter;
        startLabel.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:18.0];
        startLabel.shadowColor = [UIColor grayColor];
        startLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        startLabel.layer.cornerRadius = 8;
        startLabel.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
        startLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:startLabel];
    } else {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%d_%d_Cell",indexPath.row,indexPath.section]];
        CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
        //cell.textLabel.text = [NSString stringWithFormat:@"Protecto Device %d:",(indexPath.row+1)];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",CFUUIDCreateString(nil, p.UUID)];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CGFloat cellX = cell.contentView.frame.origin.x;
        CGFloat cellY = cell.contentView.frame.origin.y;
        CGFloat cellW = cell.contentView.frame.size.width;
        CGFloat cellH = cell.contentView.frame.size.height;
        
        UILabel* headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellX, cellY, 0.8*cellW, 0.7*cellH)];
        UILabel* detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellX, cellY+0.7*cellH, 0.8*cellW, 0.3*cellH)];
        UIImageView* storedImage = [[UIImageView alloc] initWithFrame:CGRectMake(cellW-40.0,cellY+0.1*cellH,32.0,32.0)];
        UILabel* storedLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellX+0.8*cellW,cellY+0.8*cellH,0.2*cellW,0.2*cellH)];
        cell.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
        cell.layer.borderColor = [UIColor blackColor].CGColor;
        cell.layer.borderWidth = 1.0f;
        NSString* uid = [p.identifier UUIDString];
        
        headingLabel.backgroundColor = [UIColor clearColor];
        headingLabel.text = [NSString stringWithFormat:@"Protecto Device %d:",(indexPath.row+1)];
        headingLabel.textColor = [UIColor whiteColor];
        headingLabel.shadowColor = [UIColor blackColor];
        headingLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        headingLabel.font = [UIFont fontWithName:@"AmericanTypeWriter" size:16.0];
        
        detailsLabel.backgroundColor = [UIColor clearColor];
        detailsLabel.text = uid;
        detailsLabel.textColor = [UIColor whiteColor];
        detailsLabel.font = [UIFont fontWithName:@"AmericanTypeWriter" size:12.0];
        detailsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        if([self.storedUUIDs containsObject:uid]) {
            storedImage.image = [UIImage imageNamed:@"tick.png"];
            storedLabel.text = @"STORED";
            storedLabel.textColor = [UIColor yellowColor];
        } else {
            storedImage.image = [UIImage imageNamed:@"add-1.png"];
            storedLabel.text = @"ADD";
            storedLabel.textColor = [UIColor yellowColor];
        }
        storedLabel.textAlignment = NSTextAlignmentCenter;
        storedLabel.shadowColor = [UIColor blackColor];
        storedLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        storedLabel.font = [UIFont fontWithName:@"AmericanTypeWriter" size:12.0];
        storedLabel.backgroundColor = [UIColor clearColor];
        storedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [cell.contentView addSubview:headingLabel];
        [cell.contentView addSubview:detailsLabel];
        [cell.contentView addSubview:storedImage];
        [cell.contentView addSubview:storedLabel];
    }
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section>0){
        if (self.sensorTags.count >= 1 ) return @"Tap to Add Protecto Device";
        else return @"No Protecto Device Found";
    } else { return @"Search for New Protecto Device"; }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section>0) { return 10.0f; }
    else { return 80.0f; }
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0) { return 60.0f; }
    else { return 60.0f; }
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section ==0) {
        self.searchButtonIndex = indexPath;
        self.numberOfSearchTries = MAX_SEARCH_TRIES;
        self.devSearchTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(searchForDevice:) userInfo:nil repeats:YES];
        self.busyIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.busyIndicator.center = [tableView cellForRowAtIndexPath:indexPath].contentView.center;
        [self.busyIndicator setColor:[UIColor blackColor]];
        //[self.view addSubview:self.busyIndicator];
        [[tableView cellForRowAtIndexPath:indexPath].contentView addSubview:self.busyIndicator];
        [self.busyIndicator startAnimating];
    } else {
        CBPeripheral *p = [self.sensorTags objectAtIndex:indexPath.row];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if([self.storedUUIDs containsObject:[p.identifier UUIDString]]) { return; }
        
        BLEDevice *d = [[BLEDevice alloc]init];
        d.p = p;
        d.manager = self.m;
        d.setupData = [self makeSensorTagConfiguration];
        
        AdditionalDevDataController *rrC = [[AdditionalDevDataController alloc] init:d.p];
        [self.navigationController pushViewController:rrC animated:YES];
    }
}




#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
       The reason for this is that the CFUUID .UUID property of CBPeripheral
       here is null the first time an unkown (never connected before in any app)
       peripheral is connected. So therefore we connect to all peripherals we find.
    */
    
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        NSLog(@"Service found : %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]] ||
            [s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA10-0451-4000-B000-000000000000"]])  {
            NSLog(@"This is a Protecto Device!");
            found = YES;
        }
    }
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.sensorTags.count; ii++) {
            CBPeripheral *p = [self.sensorTags objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                    [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                    replace = YES;
                }
            }
        if (!replace) {
            [self.sensorTags addObject:peripheral];
            [self.tableView reloadData];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

# pragma mark - Read Peripherals from File

-(void)readPeripheralsFromFile {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent: @"Protecto_Device_Information.txt"];
    if ([filemgr fileExistsAtPath:dataFile]) {
        NSError *err;
        NSArray *storedList = [[NSString stringWithContentsOfFile:dataFile encoding:NSUTF8StringEncoding error:&err] componentsSeparatedByString:@"\n"];
        if(err) {
            NSLog(@"Error encountered in reading device list: %@",err);
            return;
        }
        for (NSString *peripheral in storedList) {
            NSArray *periDetails = [peripheral componentsSeparatedByString:@","];
            if([periDetails count]>1) {
                NSLog(@"Peripheral Read: Name=%@, Type=%@, UUID=%@",[periDetails objectAtIndex:3],[periDetails objectAtIndex:4],[periDetails objectAtIndex:2]);
                [self.storedUUIDs addObject:[periDetails objectAtIndex:2]];
            }
        }
        NSLog(@"Finished reading list of stored Protecto devices");
    } else {
        NSLog(@"No devices are currently stored!");
    }
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
    
    NSLog(@"%@",dic);
    
    return dic;
}

@end
