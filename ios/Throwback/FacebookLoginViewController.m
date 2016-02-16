//
//  FacebookLoginViewController.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "FacebookLoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SpotifyLoginViewController.h"

@interface FacebookLoginViewController () <FBSDKLoginButtonDelegate>

@property (nonatomic, assign) IBOutlet FBSDKLoginButton *facebookLoginButton;

@end

@implementation FacebookLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.facebookLoginButton.readPermissions = @[@"user_photos"];
    self.facebookLoginButton.delegate = self;
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if ([result.token.tokenString length] > 0) {
        SpotifyLoginViewController *spotifyViewController = [[SpotifyLoginViewController alloc] init];
        [self.navigationController pushViewController:spotifyViewController animated:YES];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    
}

@end
