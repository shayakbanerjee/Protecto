//
//  ProtectoTabbedViewController.m
//  Protecto
//
//  Created by Shak on 12/21/13.
//  Copyright (c) 2013 Shak. All rights reserved.
//

#import "ProtectoTabbedViewController.h"

@interface ProtectoTabbedViewController ()

@end

@implementation ProtectoTabbedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"Tab Bar Controller was initialized");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.firstViewController = [[deviceSelector alloc] initWithStyle:UITableViewStyleGrouped];
    self.firstNavController = [[UINavigationController alloc]initWithRootViewController:self.firstViewController];
    self.firstNavController.title = @"Add Device";
    self.firstNavController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Add Device" image:[UIImage imageNamed:@"1388136530_519691-199_CircledPlus.png"] tag:0];
    [self.firstNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                  [UIColor grayColor], UITextAttributeTextColor,
                                                                  //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                                  //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                                  nil] forState:UIControlStateNormal];
    [self.firstNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                  [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                  nil] forState:UIControlStateSelected];
    
    // Details for the second view controller
    self.secondViewController = [[PocketMaarViewController alloc] init];
    self.secondNavController = [[UINavigationController alloc] initWithRootViewController:self.secondViewController];
    self.secondNavController.title = @"List Devices";
    self.secondNavController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"List Devices" image:[UIImage imageNamed:@"1388136450_30.png"] tag:1];
    [self.secondNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                        [UIColor grayColor], UITextAttributeTextColor,
                                        //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                        //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                        nil] forState:UIControlStateNormal];
    [self.secondNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                        [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                        nil] forState:UIControlStateSelected];
    
    self.thirdViewController = [[ProtectoSettingsViewController alloc] init];
    self.thirdNavController = [[UINavigationController alloc] initWithRootViewController:self.thirdViewController];
    self.thirdNavController.title = @"Settings";
    self.thirdNavController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"1388136493_54_Settings.png"] tag:2];
    [self.thirdNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                  [UIColor grayColor], UITextAttributeTextColor,
                                                                  //[UIColor lightGrayColor], UITextAttributeTextShadowColor,
                                                                  //[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                                  nil] forState:UIControlStateNormal];
    [self.thirdNavController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIFont fontWithName:@"AmericanTypewriter" size:12.0f], UITextAttributeFont,
                                                                  [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                                  nil] forState:UIControlStateSelected];
    
    //self.tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    self.tabBarController.view.tintColor = [UIColor colorWithRed:0.0 green:157.0/255.0 blue:223.0/255.0 alpha:1.0];
    self.tabBarController.viewControllers = [[NSArray alloc] initWithObjects:self.firstNavController, self.secondNavController, self.thirdNavController, nil];
    //self.tabBarController.viewControllers = [[NSArray alloc] initWithObjects:self.firstViewController, self.secondViewController, self.thirdViewController, nil];
    //self.tabBarController.view.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.origin.y+self.view.frame.size.height-40), self.view.frame.size.width, 40); // SOLUTION TO MY LONG HOUR PROBLEM!
    //self.tabBarController.delegate = self;
    
    // Give tags to each view
    self.firstViewController.view.tag = 6601;
    self.secondViewController.view.tag = 6602;
    self.thirdViewController.view.tag = 6603;
    self.tabBarController.view.tag = 6604;
    
    //[self.view addSubview:self.tabBarController.view];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(tabBarController.selectedIndex == 0) {
        //[self.navigationController popViewControllerAnimated:YES];
       //[self.navigationController pushViewController:self.firstViewController animated:YES];
        //[self.view addSubview:self.atabBarController.view];
        //[self.view setBackgroundColor:[UIColor whiteColor]];
    } else if(tabBarController.selectedIndex ==1) {
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController pushViewController:self.secondViewController animated:YES];
        //[self.view addSubview:self.atabBarController.view];
        //[self.view setBackgroundColor:[UIColor whiteColor]];
    }
    else if(tabBarController.selectedIndex ==2) {
        //[self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController pushViewController:self.thirdViewController animated:YES];
        //[self.view addSubview:self.atabBarController.view];
        //[self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
