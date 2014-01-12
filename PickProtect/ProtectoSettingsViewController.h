//
//  ProtectoSettingsViewController.h
//  Protecto
//
//  Created by Shak on 12/21/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProtectoSettingsViewController : UITableViewController <UIAlertViewDelegate>

@property (strong,nonatomic) NSMutableArray *devDates;
@property (strong,nonatomic) NSMutableArray *devPeriName;
@property (strong,nonatomic) NSMutableArray *devUUIDs;
@property (strong,nonatomic) NSMutableArray *devNames;
@property (strong,nonatomic) NSMutableArray *devTypes;
@property (strong,nonatomic) NSMutableArray *devRanges;
@property NSInteger sectionToDelete;

@end
