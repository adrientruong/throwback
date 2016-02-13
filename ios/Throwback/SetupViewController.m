//
//  SetupViewController.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "SetupViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SetupViewController () <FBSDKLoginButtonDelegate>


@end

@implementation SetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.readPermissions = @[@"user_photos"];
    loginButton.delegate = self;
    [self.view addSubview:loginButton];
    
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.centerXAnchor constraintEqualToAnchor:loginButton.centerXAnchor].active = YES;
    [loginButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:40].active = YES;
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSLog(@"token: %@", [FBSDKAccessToken currentAccessToken].tokenString);
}

- (IBAction)spotifyButtonWasTapped
{
    
}

@end
