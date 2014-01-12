//
//  ProtectoMainViewController.m
//  Protecto
//
//  Created by Shak on 12/28/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "ProtectoMainViewController.h"

@interface ProtectoMainViewController ()

@end

@implementation ProtectoMainViewController

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
    self.firstViewController = [[deviceSelector alloc] initWithStyle:UITableViewStyleGrouped];
    self.firstViewController.title = @"Add Protecto Device";
    self.firstViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Add Device" image:[UIImage imageNamed:@"1388136530_519691-199_CircledPlus.png"] tag:0];
    [self.firstViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                [UIColor grayColor], UITextAttributeTextColor,
                                                                //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                                //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                                nil] forState:UIControlStateNormal];
    [self.firstViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                nil] forState:UIControlStateSelected];
    self.firstNavController = [[ProtectoNavControllerViewController alloc] initWithRootViewController:self.firstViewController];
    
    self.secondViewController = [[PocketMaarViewController alloc] init:@"Protecto_Device_Information.txt"];
    self.secondViewController.title = @"List Protecto Devices";
    self.secondViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"List Devices" image:[UIImage imageNamed:@"1388136450_30.png"] tag:1];
    [self.secondViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                 [UIColor grayColor], UITextAttributeTextColor,
                                                                 //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                                 //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                                 nil] forState:UIControlStateNormal];
    [self.secondViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                 [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                 nil] forState:UIControlStateSelected];
    self.secondNavController = [[ProtectoNavControllerViewController alloc] initWithRootViewController:self.secondViewController];
    
    self.thirdViewController = [[ProtectoSettingsViewController alloc] init];
    self.thirdViewController.title = @"Settings";
    self.thirdViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"1388136493_54_Settings.png"] tag:2];
    [self.thirdViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                [UIColor grayColor], UITextAttributeTextColor,
                                                                //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                                //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                                nil] forState:UIControlStateNormal];
    [self.thirdViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                nil] forState:UIControlStateSelected];
    self.thirdNavController = [[ProtectoNavControllerViewController alloc] initWithRootViewController:self.thirdViewController];
    
    [self setViewControllers:[[NSArray alloc] initWithObjects:self.secondNavController, self.firstNavController, self.thirdNavController, nil]];
    self.tabBarController.delegate = self;
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

/*
 - (UILabel*)screenHeader
{
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0f)];
    customLabel.text = @"Protecto";
    customLabel.font = [UIFont fontWithName:@"AmericanTypeWriter-Bold" size:20.0];
    customLabel.textColor = [UIColor whiteColor];
    customLabel.textAlignment = NSTextAlignmentCenter;
    customLabel.backgroundColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
    customLabel.layer.cornerRadius = 8;
    return customLabel;
}*/

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
