//
//  AppDelegate.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Spotify/Spotify.h>

#define kSpotifyClientID @"9d342728b0664f75aeafc7a42aa31a84"
#define kSpotifyRedirectURL @"throwback-login://"

@interface AppDelegate ()

@property (nonatomic, strong) SPTAudioStreamingController *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SPTAuth defaultInstance] setClientID:kSpotifyClientID];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:kSpotifyRedirectURL]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope, SPTAuthUserLibraryReadScope, SPTAuthPlaylistReadPrivateScope]];

    UIWindow *window = [[UIWindow alloc] init];
    
    WelcomeViewController *viewController = [[WelcomeViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navController.navigationBarHidden = YES;
    window.rootViewController = navController;
    
    [window makeKeyAndVisible];
    
    self.window = window;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            if (error) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            NSLog(@"Spotify Token: %@", session.accessToken);
            
            self.spotifyLoginCompletionHandler();
        }];
        return YES;
    } else {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
