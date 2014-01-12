//
//  ProtectoNavControllerViewController.m
//  Protecto
//
//  Created by Shak on 12/31/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "ProtectoNavControllerViewController.h"

@interface ProtectoNavControllerViewController ()

@end

@implementation ProtectoNavControllerViewController

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
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                        shadow, NSShadowAttributeName,
                        [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:19.0], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintAdjustmentMode:UIViewTintAdjustmentModeNormal];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0]];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
