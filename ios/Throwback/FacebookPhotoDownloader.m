//
//  FacebookPhotoDownloader.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "FacebookPhotoDownloader.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <SDWebImage/SDWebImageManager.h>

@implementation FacebookPhotoDownloader

+ (FacebookPhotoDownloader *)sharedDownloader
{
    static FacebookPhotoDownloader *downloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloader = [[FacebookPhotoDownloader alloc] init];
    });
    
    return downloader;
}

- (void)downloadPhotosWithIDs:(NSArray *)photoIDs
        withCompletionHandler:(void (^)(NSDictionary *images, NSError *error))completionHandler
{
    NSMutableDictionary *images = [NSMutableDictionary dictionary];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    dispatch_group_t group = dispatch_group_create();

    for (NSString *photoID in photoIDs) {
        NSString *path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", photoID, [FBSDKAccessToken currentAccessToken].tokenString];
        NSURL *URL = [NSURL URLWithString:path];
        dispatch_group_enter(group);
        [manager downloadImageWithURL:URL
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    images[photoID] = image;
                                }
                                dispatch_group_leave(group);
                            }];
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        completionHandler(images, nil);
    });
}

@end
