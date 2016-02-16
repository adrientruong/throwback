//
//  LoadingViewController.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "LoadingViewController.h"
#import "BluemixClient.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FacebookPhotoDownloader.h"

#import <Spotify/Spotify.h>

#import "ThrowbackPlayerViewController.h"
#import "Throwback.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getAndShowThrowback];
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
        [self.navigationController pushViewController:playerViewController animated:YES];
    }];
}

@end
