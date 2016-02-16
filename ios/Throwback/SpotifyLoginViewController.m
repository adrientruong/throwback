//
//  SpotifyLoginViewController.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "SpotifyLoginViewController.h"
#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "LoadingViewController.h"

@interface SpotifyLoginViewController ()

@end

@implementation SpotifyLoginViewController

- (IBAction)spotifyLoginButtonWasTapped
{
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    [[UIApplication sharedApplication] openURL:loginURL];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.spotifyLoginCompletionHandler = ^{
        NSString *spotifyToken = [SPTAuth defaultInstance].session.accessToken;
        if ([spotifyToken length] > 0) {
            LoadingViewController *loadingViewController = [[LoadingViewController alloc] init];
            [self.navigationController pushViewController:loadingViewController animated:YES];
        }
    };
}

@end
