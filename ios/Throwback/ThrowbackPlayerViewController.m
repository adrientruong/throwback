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
#import "Photo.h"
#import "ShareViewController.h"

#define kAdriensToken @"BQBjTzuBvyI8Ia_P-7E_-h_g2-Tb0RotJqT9Ay-UB77GNBERHLzqJjFeBhSPUsI26jEG2V837kxD05q3XIZAjt0dHNNO7YtxtX0nL_rnEjFUUHgFqEzDQe2ygoFd3lZwTyJRRbPB1b4ZoIpL0p_JO6khCwqQr69mwT-92crm15uOd3T3BZyYEf6va2Ctk1KDgxKSNH8iKARIiec5Q-FhijM"

@interface ThrowbackPlayerViewController ()

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) UILabel *dateLabel;
@property (nonatomic, assign) UILabel *commentLabel;

@property (nonatomic, assign) NSInteger currentTimePeriodIndex;
@property (nonatomic, assign) NSInteger currentPhotoIndex;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation ThrowbackPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    UILabel *dateLabel = [[UILabel alloc] init];
    dateLabel.textColor = [UIColor whiteColor];
    [effectView.contentView addSubview:dateLabel];
    [self.view addSubview:effectView];
    self.dateLabel = dateLabel;
    
    UILabel *commentLabel = [[UILabel alloc] init];
    commentLabel.textColor = [UIColor whiteColor];
    commentLabel.numberOfLines = 0;
    [self.view addSubview:commentLabel];
    self.commentLabel = commentLabel;
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    effectView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView, dateLabel, commentLabel, effectView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[effectView]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[commentLabel]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[commentLabel]-20-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[dateLabel]-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[dateLabel]-|" options:0 metrics:nil views:views]];

    [self.dateLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.commentLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;

    self.view.backgroundColor = [UIColor blackColor];
    
    [self prepareAssets];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    return _dateFormatter;
}

- (TimePeriod *)currentTimePeriod
{
    return self.throwback.timePeriods[self.currentTimePeriodIndex];
}

- (Photo *)currentPhoto
{
    TimePeriod *period = [self currentTimePeriod];
    return period.photos[self.currentPhotoIndex];
}

- (void)start
{
    self.currentTimePeriodIndex = 0;
    self.currentPhotoIndex = 0;
    
    self.imageView.image = [self currentPhoto].image;
    
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
    self.currentPhotoIndex++;
    if (self.currentPhotoIndex >= [self.currentTimePeriod.photos count]) {
        self.currentPhotoIndex = 0;
        self.currentTimePeriodIndex++;
        if (self.currentTimePeriodIndex >= [self.throwback.timePeriods count]) {
            [self stop];
            return;
        }
        [self.player skipNext:nil];
        //[self increaseVolume];
    }
    
    Photo *photo = [self currentPhoto];
    [UIView transitionWithView:self.view
                      duration:0.33f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.imageView.image = [self currentPhoto].image;
    } completion:NULL];
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:photo.date];
    [self.dateLabel invalidateIntrinsicContentSize];
    self.commentLabel.text = photo.comment;
    [self.commentLabel invalidateIntrinsicContentSize];
    
    NSLog(@"%@", photo.comment);
    
    [self.view setNeedsLayout];
}

- (void)stop
{
    [self.timer invalidate];
    [self.player stop:^(NSError *error) {
        [self.player logout:^(NSError *error) {
            ShareViewController *shareViewController = [[ShareViewController alloc] init];
            shareViewController.throwback = self.throwback;
            [self.navigationController pushViewController:shareViewController animated:YES];
        }];
    }];
}

- (void)prepareAssets
{
    dispatch_group_t group = dispatch_group_create();
    
    FacebookPhotoDownloader *downloader = [FacebookPhotoDownloader sharedDownloader];
    dispatch_group_enter(group);
    [downloader downloadPhotosWithIDs:[self.throwback photoIDs] withCompletionHandler:^(NSDictionary *images, NSError *error) {
        for (TimePeriod *period in self.throwback.timePeriods) {
            for (Photo *photo in period.photos) {
                photo.image = images[photo.facebookID];
            }
        }
        
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
