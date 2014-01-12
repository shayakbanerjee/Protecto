//
//  AdditionalDevDataController.h
//  Protecto
//
//  Created by Shak on 12/30/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDevice.h"

#define NAME_ENTRY_SECTION 0
#define TYPE_PICK_SECTION 1
#define RANGE_SET_SECTION 2
#define SAVE_BUTTON_SECTION 3

@interface AdditionalDevDataController : UITableViewController <UIPickerViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) CBPeripheral* peri;
@property (strong,nonatomic) NSString* periName;
@property (strong,nonatomic) NSString* periType;
@property NSInteger periRange;
@property (strong,nonatomic) NSArray* typeOfCarriers;
@property (strong,nonatomic) NSArray* defaultRanges;

-(id)init:(CBPeripheral*)p;

@end
