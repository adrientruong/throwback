//
//  SetupViewController.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "SetupViewController.h"
#import "AppDelegate.h"
#import "BluemixClient.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FacebookPhotoDownloader.h"

#import <Spotify/Spotify.h>

#import "ThrowbackPlayerViewController.h"
#import "Throwback.h"

@interface SetupViewController () <FBSDKLoginButtonDelegate>

@property (nonatomic, assign) IBOutlet FBSDKLoginButton *facebookLoginButton;


@end

@implementation SetupViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.facebookLoginButton.readPermissions = @[@"user_photos"];
    self.facebookLoginButton.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSString *spotifyToken = [SPTAuth defaultInstance].session.accessToken;
    if ([facebookToken length] > 0 && [spotifyToken length] > 0) {
        [self getAndShowThrowback];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

- (void)getAndShowThrowback
{
    NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
    NSString *spotifyToken = [SPTAuth defaultInstance].session.accessToken;
    [[BluemixClient sharedClient] getThrowbackWithFacebookToken:facebookToken spotifyToken:spotifyToken completionHandler:^(Throwback *throwback, NSError *error) {
        if (!throwback) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Server failed." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        } else if ([throwback.timePeriods count] == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Server Error" message:@"Server returned 0 time periods." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        
        ThrowbackPlayerViewController *playerViewController = [[ThrowbackPlayerViewController alloc] init];
        playerViewController.throwback = throwback;
        [self presentViewController:playerViewController animated:YES completion:nil];
    }];
}

- (IBAction)spotifyLoginButtonWasTapped
{
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    [[UIApplication sharedApplication] openURL:loginURL];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.spotifyLoginCompletionHandler = ^{
        NSString *facebookToken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSString *spotifyToken = [SPTAuth defaultInstance].session.accessToken;
        if ([facebookToken length] > 0 && [spotifyToken length] > 0) {
            [self getAndShowThrowback];
        }
    };

}

@end
