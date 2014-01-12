//
//  ProtectoTabbedViewController.h
//  Protecto
//
//  Created by Shak on 12/21/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deviceSelector.h"
#import "PocketMaarViewController.h"
#import "ProtectoSettingsViewController.h"

@interface ProtectoTabbedViewController : UITabBarController

//@property (nonatomic, retain) UITabBarController *atabBarController;
@property (strong, nonatomic) deviceSelector *firstViewController;
@property (strong, nonatomic) PocketMaarViewController *secondViewController;
@property (strong, nonatomic) ProtectoSettingsViewController *thirdViewController;
@property (strong, nonatomic) UINavigationController* firstNavController;
@property (strong, nonatomic) UINavigationController* secondNavController;
@property (strong, nonatomic) UINavigationController* thirdNavController;

@end
