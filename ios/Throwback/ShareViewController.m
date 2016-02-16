//
//  ShareViewController.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "ShareViewController.h"
#import "Throwback.h"
#import "Photo.h"
#import "TimePeriod.h"
#import "ShareCard.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ShareViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *periods = [self.throwback.timePeriods mutableCopy];
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 0; i < MIN(3, [periods count]); i++) {
        NSUInteger randomPeriodIndex = arc4random_uniform([periods count]);
        TimePeriod *period = periods[randomPeriodIndex];
        [periods removeObjectAtIndex:randomPeriodIndex];
        NSUInteger randomPhotoIndex = arc4random_uniform([period.photos count]);
        [photos addObject:period.photos[randomPhotoIndex]];
    }
    
    CGFloat currentX = 10;
    CGFloat totalWidth = 10;
    CGFloat height = self.scrollView.frame.size.height - 40;
    for (Photo *photo in photos) {
        UIImage *shareCardImage = [ShareCard shareCardImageWithPhoto:photo];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:shareCardImage];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapToShare:)];
        [imageView addGestureRecognizer:tap];
        imageView.userInteractionEnabled = YES;
        CGFloat width = shareCardImage.size.width * (height / shareCardImage.size.height);
        imageView.frame = CGRectMake(currentX, 20, width, height);
        totalWidth += width + 10;
        currentX += width + 10;
        [self.scrollView addSubview:imageView];
    }
    self.scrollView.contentSize = CGSizeMake(totalWidth, self.scrollView.frame.size.height);
}

- (void)didTapToShare:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = imageView.image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
}

- (IBAction)finish
{
    [[FBSDKLoginManager new] logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
