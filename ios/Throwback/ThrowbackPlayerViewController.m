//
//  ThrowbackPlayerViewController.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "ThrowbackPlayerViewController.h"
#import <Spotify/Spotify.h>
#import "FacebookPhotoDownloader.h"
#import "Throwback.h"
#import "TimePeriod.h"

#define kAdriensToken @"BQBeP7TbkBuJyFzKyefSVzf1uJgt3NPQGfEM7-yq7ddaIwZ2GFBExik1J_KtsNKy3-7oM1rJie4ai7Bzu0mNRdYyez2QE0Pm-xkmfFsMKBhYjV7NOsLIrMSy9cdwvz5a3CEOUXjtMw_koxFrWuSpXAwxzfyxA_H1IXfGXxj_1SAh8DUL6qtAkkbO7IIrh9z3WLNswKQ1b22ehNeiyJMP6Go"

@interface ThrowbackPlayerViewController ()

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, assign) UIImageView *imageView;

@property (nonatomic, strong) NSDictionary *images;

@property (nonatomic, assign) NSInteger currentTimePeriodIndex;
@property (nonatomic, assign) NSInteger currentImageIndex;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ThrowbackPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.view addSubview:imageView];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView = imageView;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self prepareAssets];
}

- (TimePeriod *)currentTimePeriod
{
    return self.throwback.timePeriods[self.currentTimePeriodIndex];
}

- (UIImage *)currentImage
{
    return self.images[[self currentTimePeriod].facebookPhotoIDs[self.currentImageIndex]];
}

- (void)start
{
    self.currentTimePeriodIndex = 0;
    self.currentImageIndex = 0;
    
    self.imageView.image = [self currentImage];
    
    NSMutableArray *URIStrings = [NSMutableArray array];
    for (TimePeriod *period in self.throwback.timePeriods) {
        [URIStrings addObjectsFromArray:period.spotifySongIDs];
    }
    
    NSMutableArray *URIs = [NSMutableArray array];
    for (NSString *URIString in URIStrings) {
        NSURL *URI = [NSURL URLWithString:URIString];
        [URIs addObject:URI];
    }
    [self.player playURIs:URIs fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Starting playback got error: %@", error);
            return;
        }
    }];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
}

- (void)timerUpdate:(NSTimer *)timer
{
    if (self.currentTimePeriodIndex >= [self.throwback.timePeriods count]) {
        [self stop];
        return;
    }
    
    [self update];
}

- (void)decreaseVolume
{
    double newVolume = MAX(0, self.player.volume - 0.1);
    [self.player setVolume:MAX(0, newVolume) callback:nil];
    
    if (newVolume > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self decreaseVolume];
        });
    }
}

- (void)increaseVolume
{
    double newVolume = MIN(1, self.player.volume + 0.1);
    [self.player setVolume:newVolume callback:nil];
    if (newVolume < 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self increaseVolume];
        });
    }
}

- (void)update
{
    self.currentImageIndex++;
    if (self.currentImageIndex >= [self.currentTimePeriod.facebookPhotoIDs count]) {
        self.currentImageIndex = 0;
        self.currentTimePeriodIndex++;
        if (self.currentTimePeriodIndex >= [self.throwback.timePeriods count]) {
            [self stop];
            return;
        }
        [self.player skipNext:nil];
        //[self increaseVolume];
    }
    
    [UIView transitionWithView:self.view
                      duration:0.33f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = [self currentImage];
    } completion:NULL];
}

- (void)stop
{
    [self.timer invalidate];
    [self.player stop:^(NSError *error) {
        [self.player logout:^(NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

- (void)prepareAssets
{
    dispatch_group_t group = dispatch_group_create();
    
    FacebookPhotoDownloader *downloader = [FacebookPhotoDownloader sharedDownloader];
    dispatch_group_enter(group);
    [downloader downloadPhotosWithIDs:[self.throwback photoIDs] withCompletionHandler:^(NSDictionary *images, NSError *error) {
        self.images = images;
        dispatch_group_leave(group);
    }];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    SPTSession *adriensSession = [[SPTSession alloc] initWithUserName:@"domele123" accessToken:kAdriensToken expirationTimeInterval:60 * 60];
    
    dispatch_group_enter(group);
    [self.player loginWithSession:adriensSession callback:^(NSError *error) {
        dispatch_group_leave(group);
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
    }];
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];
        });
    });
}


@end
