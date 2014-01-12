//
//  AdditionalDevDataController.m
//  Protecto
//
//  Created by Shak on 12/30/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "AdditionalDevDataController.h"

@interface AdditionalDevDataController ()

@end

@implementation AdditionalDevDataController

-(id)init:(CBPeripheral*)p
{
    self = [super initWithNibName:nil bundle:nil];
    self.peri = p;
    self.periRange = -70;
    self.title = @"Additional Details";
    self.periType = @"Press to Select";
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.typeOfCarriers = [[NSArray alloc] initWithObjects:
                         @"Wallet", @"Purse", @"Camera Bag",
                         @"Briefcase", @"Other", nil];
    self.defaultRanges = [[NSArray alloc]
                          initWithObjects: [NSNumber numberWithInteger:-90],
                          [NSNumber numberWithInteger:-90],
                          [NSNumber numberWithInteger:-100],
                          [NSNumber numberWithInteger:-100],
                          [NSNumber numberWithInteger:-90], nil];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%d_%d_Entry_Cell",indexPath.row,indexPath.section]];
    if(indexPath.section ==0) {
        // Name the Protecto Device
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(cell.bounds.origin.x+0.1*cell.bounds.size.width,cell.bounds.origin.y,0.8*cell.bounds.size.width,cell.bounds.size.height)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:16.0];
        textField.placeholder = @"Enter Name";
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.tag = 5607;
        textField.delegate = self;
        [cell.contentView addSubview:textField];
    } else if (indexPath.section ==1) {
        // Select what type of bag it is
        UIButton *myPickButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.origin.x+0.1*cell.bounds.size.width,cell.bounds.origin.y + 0.2*cell.bounds.size.height,0.8*cell.bounds.size.width,0.8*cell.bounds.size.height)];
        myPickButton.layer.borderColor = [[UIColor blackColor] CGColor];
        myPickButton.layer.borderWidth = 1.0f;
        myPickButton.layer.cornerRadius = 8.0f;
        [myPickButton setTitle:self.periType forState:UIControlStateNormal];
        myPickButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [myPickButton setBackgroundColor:[UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0]];
        myPickButton.tag = 5606;
        [myPickButton addTarget:self action:@selector(displayPickerView:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:myPickButton];
        //[self displayPickerView:nil];
        
    } else if (indexPath.section ==2) {
        //cell.textLabel.text = @"Select Range for Alarm";
        CGFloat slX = cell.bounds.origin.x + 0.1*cell.bounds.size.width;
        CGFloat slY = cell.bounds.origin.y;
        CGFloat slW = 0.8*cell.bounds.size.width;
        CGFloat slH = 0.5*cell.bounds.size.height;
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(slX,(slY+slH),slW,(cell.bounds.size.height-slH))];
        slider.minimumValue = -110.0;
        slider.maximumValue = -50.0;
        slider.minimumValueImage = [UIImage imageNamed:@"math-minus-icon.png"];
        slider.maximumValueImage = [UIImage imageNamed:@"Sign-Add-icon.png"];
        slider.continuous = YES;
        slider.value = (float)self.periRange;
        slider.tag = 5609;
        [slider addTarget:self action:@selector(updateThreshold:) forControlEvents:UIControlEventValueChanged];
        
        UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(slX,slY,slW,slH)];
        sliderLabel.text = [NSString stringWithFormat:@"Range Set to (%d)",self.periRange];
        sliderLabel.backgroundColor = [UIColor whiteColor];
        sliderLabel.textColor = [UIColor blackColor];
        sliderLabel.font = [UIFont systemFontOfSize:16.0];
        sliderLabel.adjustsFontSizeToFitWidth = YES;
        sliderLabel.minimumScaleFactor = 0.5;
        sliderLabel.tag = 5608;
        [cell.contentView addSubview:slider];
        [cell.contentView addSubview:sliderLabel];
    } else {
        // Display Save Button
        UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.15*cell.bounds.size.width,0.0,0.7*cell.bounds.size.width,cell.bounds.size.height)];
        startLabel.text = @"Save Details";
        startLabel.textAlignment = NSTextAlignmentCenter;
        startLabel.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:20.0];
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
    if (section == SAVE_BUTTON_SECTION) return nil;
    
    //NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:TYPE_PICK_SECTION];
    //UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    label.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont fontWithName:@"AmericanTypeWriter" size:16.0];
    label.text = sectionTitle;
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    return view;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case NAME_ENTRY_SECTION: return @"Name Your Device"; break;
        case TYPE_PICK_SECTION: return @"Select Bag Type"; break;
        case RANGE_SET_SECTION: return @"Set Alarm Range"; break;
        default: return @"";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section ==SAVE_BUTTON_SECTION) return 0.0f;
    else return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section ==TYPE_PICK_SECTION) return 120.0f;
    else if(indexPath.section ==RANGE_SET_SECTION) return 60.0f;
    else return 50.0f;
}

/*-(float) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}*/

#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section ==SAVE_BUTTON_SECTION) {
        UITextField* tf = (UITextField*)[self.view viewWithTag:5607];
        self.periName = tf.text;
        NSLog(@"Device UUID: %@",CFUUIDCreateString(nil, self.peri.UUID));
        NSLog(@"Device Name: %@",self.periName);
        NSLog(@"Device Type: %@",self.periType);
        NSLog(@"Device Range: %d",self.periRange);
        NSLog(@"Device Identifier: %@", [self.peri.identifier UUIDString]);
        // Some error checking
        if(![self.typeOfCarriers containsObject:self.periType]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error: Select Type" message:@"Must select which type of Protecto device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        [self writePeripheralToFile];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Save Successful" message:@"Congratulations on your new Protecto Device!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertView.tag = 6801;
        [alertView show];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex ==0 && alertView.tag == 6801) [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Picker View delegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    self.periType = [self.typeOfCarriers objectAtIndex:row];
    self.periRange = [[self.defaultRanges objectAtIndex:row] integerValue];
    [self updateRangeSliderLabel];
    [self updatePickerButton];
    [self removePickerView];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.typeOfCarriers count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.typeOfCarriers objectAtIndex:row];
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 300.0f;
}

-(IBAction)updateThreshold:(UISlider*)sender {
    self.periRange = (NSInteger)sender.value;
    [self updateRangeSliderLabel];
}

-(void)updatePickerButton {
    UIButton* bt1 = (UIButton*)[self.view viewWithTag:5606];
    [bt1 setTitle:self.periType forState:UIControlStateNormal];
}

-(void)updateRangeSliderLabel {
    UILabel *sliderLabel = (UILabel*)[self.view viewWithTag:5608];
    sliderLabel.text = [NSString stringWithFormat:@"Range Set To (%d)",self.periRange];
    UISlider* slider = (UISlider*)[self.view viewWithTag:5609];
    slider.value = (float)self.periRange;
}

// Function to display the set of options to pick the type of bag
-(void)displayPickerView:(UIButton*)bt {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:TYPE_PICK_SECTION];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(cell.contentView.bounds.origin.x,cell.contentView.bounds.origin.y,cell.contentView.bounds.size.width,cell.contentView.bounds.size.height)];
    myPickerView.delegate = self;
    myPickerView.layer.borderColor = [[UIColor blackColor] CGColor];
    myPickerView.layer.borderWidth = 2.0f;
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = 5605;
    [cell.contentView addSubview:myPickerView];
}

-(void)removePickerView {
    [[self.view viewWithTag:5605] removeFromSuperview];
}

#pragma mark Text Field delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITextField* myTextField = (UITextField*)[self.view viewWithTag:5607];
    [myTextField resignFirstResponder];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Function to write all the peripheral data to file
-(void)writePeripheralToFile {
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dataFile = [[dirPaths objectAtIndex:0] stringByAppendingPathComponent: @"Protecto_Device_Information.txt"];
    NSMutableString *writeString = [NSMutableString stringWithCapacity:0];
    [writeString appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%d,\n",
                                             [NSDate date], self.peri.name, [self.peri.identifier UUIDString],
                                             self.periName, self.periType, self.periRange]];
    // Check if the file already exists
    if (![filemgr isWritableFileAtPath:dataFile] && [filemgr fileExistsAtPath:dataFile]) {
        NSLog(@"Could not write file at path %@",dataFile);
        return;
    } else {
        NSError* error;
        if(![filemgr fileExistsAtPath:dataFile]) {
            NSLog(@"File does not exist, creating ...");
            [writeString writeToFile:dataFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if(error) { NSLog(@"Encountered error on writing file: %@",error); return; }
        }
        else {
            NSFileHandle *handle;
            handle = [NSFileHandle fileHandleForWritingAtPath:dataFile];
            //say to handle where's the file fo write
            [handle truncateFileAtOffset:[handle seekToEndOfFile]];
            //position handle cursor to the end of file
            [handle writeData:[writeString dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"File already exists, appending ...");
            [handle closeFile];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
