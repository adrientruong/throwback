//
//  WelcomeViewController.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "WelcomeViewController.h"
#import "FacebookLoginViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createThrowback
{
    FacebookLoginViewController *facebookLoginViewController = [[FacebookLoginViewController alloc] init];
    [self.navigationController pushViewController:facebookLoginViewController animated:YES];
}

@end
