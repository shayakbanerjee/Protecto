//
//  ProtectoMainViewController.h
//  Protecto
//
//  Created by Shak on 12/28/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deviceSelector.h"
#import "PocketMaarViewController.h"
#import "ProtectoSettingsViewController.h"
#import "ProtectoNavControllerViewController.h"

@interface ProtectoMainViewController : UITabBarController <UITabBarControllerDelegate>

@property (strong, nonatomic) deviceSelector *firstViewController;
@property (strong, nonatomic) ProtectoNavControllerViewController* firstNavController;
@property (strong, nonatomic) PocketMaarViewController *secondViewController;
@property (strong, nonatomic) ProtectoNavControllerViewController* secondNavController;
@property (strong, nonatomic) ProtectoSettingsViewController *thirdViewController;
@property (strong, nonatomic) ProtectoNavControllerViewController* thirdNavController;

@end
