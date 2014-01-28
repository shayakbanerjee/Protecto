//
//  ProtectoSettingsViewController.m
//  Protecto
//
//  Created by Shak on 12/21/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "ProtectoSettingsViewController.h"

@interface ProtectoSettingsViewController ()

@end

@implementation ProtectoSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //Initialize variables to contain details
    self.devDates = [[NSMutableArray alloc] init];
    self.devUUIDs = [[NSMutableArray alloc] init];
    self.devPeriName = [[NSMutableArray alloc] init];
    self.devNames = [[NSMutableArray alloc] init];
    self.devRanges = [[NSMutableArray alloc] init];
    self.devTypes = [[NSMutableArray alloc] init];
    self.sectionToDelete = -1;   // Should cause app to crash if this hasn't been set before deleting a section
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	// Do any additional setup after loading the view.
    [self readPeripheralsFromFile];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	// Do any additional setup after loading the view.
    [self emptyVariables];
}

-(void)emptyVariables {
    [self.devDates removeAllObjects];
    [self.devPeriName removeAllObjects];
    [self.devNames removeAllObjects];
    [self.devRanges removeAllObjects];
    [self.devTypes removeAllObjects];
    [self.devUUIDs removeAllObjects];
}

-(void)refreshDeviceList {
    [self emptyVariables];
    [self readPeripheralsFromFile];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"Number of devices read = %d",[self.devRanges count]);
    [self readPeripheralsFromFile];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) writePeripheralsToFile {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent: @"Protecto_Device_Information.txt"];
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    for(int i=0; i<[self.devNames count]; i++) {
        [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%d,\n",
                    [self.devDates objectAtIndex:i], [self.devPeriName objectAtIndex:i], [self.devUUIDs objectAtIndex:i],
                    [self.devNames objectAtIndex:i], [self.devTypes objectAtIndex:i], [[self.devRanges objectAtIndex:i] integerValue]]];
    }
    // Check if the file already exists
    if (![filemgr isWritableFileAtPath:dataFile] && [filemgr fileExistsAtPath:dataFile]) {
        NSLog(@"Could not write file at path %@",dataFile);
        return;
    } else {
        NSError* error;
        if(![filemgr fileExistsAtPath:dataFile]) {
            NSLog(@"File exists, overwriting ...");
        }
        [writeString writeToFile:dataFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if(error) { NSLog(@"Encountered error on writing file: %@",error); return; }
    }
}

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
            if([periDetails count]>1) NSLog(@"Peripheral Read: Name=%@, Type=%@, UUID=%@",[periDetails objectAtIndex:3],[periDetails objectAtIndex:4],[periDetails objectAtIndex:2]);
            else continue;
            
            // Add to
            [self.devDates addObject:[periDetails objectAtIndex:0]];
            [self.devPeriName addObject:[periDetails objectAtIndex:1]];
            [self.devUUIDs addObject:[periDetails objectAtIndex:2]];
            [self.devNames addObject:[periDetails objectAtIndex:3]];
            [self.devTypes addObject:[periDetails objectAtIndex:4]];
            [self.devRanges addObject:[periDetails objectAtIndex:5]];
        }
    } else { NSLog(@"No devices are currently stored!"); }
}

-(void)loadDateLabel:(UITableViewCell*)cell forSection:(NSInteger)section {
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + 0.36*cell.bounds.size.width, cell.bounds.origin.y, 0.64*cell.bounds.size.width, cell.bounds.size.height)];
    NSString* printDate = [self.devDates objectAtIndex:section];
    dateLabel.text = [NSString stringWithFormat:@"%@",printDate];
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.font = [UIFont fontWithName:@"AmericanTypeWriter" size:14.0];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dateLabel];
}

-(void)loadBatteryIndicator:(UITableViewCell*)cell forSection:(NSInteger)section {
    /*UIProgressView* battLife = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    battLife.frame = CGRectMake(cell.bounds.origin.x + 0.40*cell.bounds.size.width, cell.bounds.origin.y + 0.3*cell.bounds.size.height, 0.40*cell.bounds.size.width, 0.4*cell.bounds.size.height);
    float batteryLife = 85.0/100.0;   // This will have to be read from device eventually
    [battLife setProgress:batteryLife];
    if(batteryLife >0.200) { battLife.progressTintColor = [UIColor greenColor]; }
    else { battLife.progressTintColor = [UIColor orangeColor]; }
    battLife.trackTintColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:battLife];
    */
    float batteryLife = 85.0/100.0;
    BatteryLifeView *battLife = [[BatteryLifeView alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + 0.50*cell.bounds.size.width, cell.bounds.origin.y + 0.3*cell.bounds.size.height, 0.25*cell.bounds.size.width, 0.4*cell.bounds.size.height)];
    battLife.backgroundColor = [UIColor clearColor];
    [battLife setBatteryPercent:batteryLife];
    
    [cell.contentView addSubview:battLife];
    UILabel *battLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.origin.x + 0.80*cell.bounds.size.width,cell.bounds.origin.y,0.20*cell.bounds.size.width,cell.bounds.size.height)];
    battLabel.text = [NSString stringWithFormat:@"(%d%%)",(NSInteger)(batteryLife*100)];
    battLabel.backgroundColor = [UIColor whiteColor];
    battLabel.textColor = [UIColor blackColor];
    battLabel.font = [UIFont systemFontOfSize:16.0];
    battLabel.adjustsFontSizeToFitWidth = YES;
    battLabel.minimumScaleFactor = 0.5;
    battLabel.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:battLabel];
}

-(void) loadRangeSetup:(UITableViewCell*)cell inSection:(NSInteger)section
{
    CGFloat slX = cell.bounds.origin.x+0.35*cell.bounds.size.width;
    CGFloat slY = cell.bounds.origin.y;
    CGFloat slW = 0.65*cell.bounds.size.width;
    CGFloat slH = cell.bounds.size.height;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(slX,slY,0.85*slW,slH)];
    slider.minimumValue = -110.0;
    slider.maximumValue = -70.0;
    slider.minimumValueImage = [UIImage imageNamed:@"math-minus-icon.png"];
    slider.maximumValueImage = [UIImage imageNamed:@"Sign-Add-icon.png"];
    slider.continuous = YES;
    slider.value = (float)[[self.devRanges objectAtIndex:section] integerValue];
    slider.tag = 6700+10*section+3;
    [slider addTarget:self action:@selector(updateThreshold:) forControlEvents:UIControlEventValueChanged];
    //slider.layer.borderWidth = 1.0f;
    //slider.layer.borderColor = [UIColor blackColor].CGColor;
    
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(slX+0.85*slW,slY,0.15*slW,slH)];
    sliderLabel.text = [NSString stringWithFormat:@"(%d)",[[self.devRanges objectAtIndex:section] integerValue]];
    sliderLabel.backgroundColor = [UIColor whiteColor];
    sliderLabel.textColor = [UIColor blackColor];
    sliderLabel.font = [UIFont systemFontOfSize:16.0];
    sliderLabel.adjustsFontSizeToFitWidth = YES;
    sliderLabel.minimumScaleFactor = 0.5;
    sliderLabel.tag = 6700+10*section+4;
    sliderLabel.textAlignment = NSTextAlignmentRight;
    //sliderLabel.layer.borderWidth = 1.0f;
    //sliderLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    [cell.contentView addSubview:slider];
    [cell.contentView addSubview:sliderLabel];
}

-(IBAction)updateThreshold:(UISlider*)sender {
    NSInteger section = (NSInteger)(sender.tag-6703)/10;
    [self.devRanges removeObjectAtIndex:section];
    [self.devRanges insertObject:[NSNumber numberWithInteger:((NSInteger)sender.value)] atIndex:section];
    UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:(6700+10*section+4)];
    sliderLabel.text = [NSString stringWithFormat:@"(%d)",[[self.devRanges objectAtIndex:section] integerValue]];
}

-(IBAction)deleteEntry:(UIButton*)sender {
    NSInteger section = (NSInteger)(sender.tag-6701)/10;
    self.sectionToDelete = section;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Delete"
                                        message:@"Are you sure you want to delete the data for this device?" delegate:self
                                          cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

-(IBAction)saveAllDevices:(UIButton*)sender {
    [self writePeripheralsToFile];
    [self refreshDeviceList];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save Success" message:@"Saved all Protecto device data to file"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)deleteSingleDevice {
    NSInteger section = self.sectionToDelete;
    [self.devDates removeObjectAtIndex:section];
    [self.devPeriName removeObjectAtIndex:section];
    [self.devNames removeObjectAtIndex:section];
    [self.devRanges removeObjectAtIndex:section];
    [self.devTypes removeObjectAtIndex:section];
    [self.devUUIDs removeObjectAtIndex:section];
    [self writePeripheralsToFile];
    [self refreshDeviceList];
    self.sectionToDelete = -1;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Success" message:@"Deleted the selected Protecto Device information"
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex ==1) [self deleteSingleDevice];
}

#pragma mark - Table View delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.devNames count]+1;   // The +1 is for the refresh / save button
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section<[self.devNames count]) return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d_%d_Cell",indexPath.row,indexPath.section]];
    CGFloat cellX = cell.bounds.origin.x;
    CGFloat cellY = cell.bounds.origin.y;
    CGFloat cellW = cell.bounds.size.width;
    CGFloat cellH = cell.bounds.size.height;
    cell.backgroundColor = [UIColor whiteColor];
    if(indexPath.section<[self.devNames count]) {
        //cell.layer.borderColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0].CGColor;
        //cell.layer.borderWidth = 1.0f;
        UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellX, cellY, 0.35*cellW, cellH)];
        if(indexPath.row ==0) titLabel.text = @"Battery Life:";
        else if (indexPath.row ==1) titLabel.text = @"Device Range:";
        titLabel.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:0.7];
        titLabel.textColor = [UIColor whiteColor];
        titLabel.font = [UIFont fontWithName:@"AmericanTypeWriter" size:14.0];
        titLabel.textAlignment = NSTextAlignmentRight;
        titLabel.shadowColor = [UIColor blackColor];
        titLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [cell.contentView addSubview:titLabel];
        //if(indexPath.row ==0) [self loadDateLabel:cell forSection:indexPath.section];
        if(indexPath.row ==0) [self loadBatteryIndicator:cell forSection:indexPath.section];
        else if (indexPath.row ==1) [self loadRangeSetup:cell inSection:indexPath.section];
    } else {
        UIButton *startLabel = [[UIButton alloc] initWithFrame:CGRectMake(0.3*cell.bounds.size.width,0,0.4*cell.bounds.size.width,cell.bounds.size.height)];
        [startLabel setTitle:@"Save" forState:UIControlStateNormal];
        [startLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [startLabel setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        startLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        startLabel.titleLabel.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:16.0];
        startLabel.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        startLabel.layer.cornerRadius = 8;
        startLabel.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
        [startLabel addTarget:self action:@selector(saveAllDevices:) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    // Draw delete button
    UIButton *imView = [[UIButton alloc] initWithFrame:CGRectMake(tableView.bounds.size.width-40.0,0.0,40.0,40.0)];
    [imView setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
    imView.backgroundColor = [UIColor clearColor];
    imView.tag = 6700+10*section+1;
    [imView addTarget:self action:@selector(deleteEntry:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:imView];
    return view;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section<[self.devNames count]) return [NSString stringWithFormat:@"%@ (%@)",[self.devNames objectAtIndex:section],[self.devTypes objectAtIndex:section]];
    else return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section<[self.devNames count]) return 40.0;
    else return 20.0;
}

-(float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section<[self.devNames count]) return 40.0;
    else return 50.0;
}

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==[self.devNames count]) {  // This is the section with the refresh button
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
