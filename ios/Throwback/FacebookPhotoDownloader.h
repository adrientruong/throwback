//
//  FacebookPhotoDownloader.h
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookPhotoDownloader : NSObject

+ (FacebookPhotoDownloader *)sharedDownloader;

- (void)downloadPhotosWithIDs:(NSArray *)photoIDs
        withCompletionHandler:(void (^)(NSDictionary *images, NSError *error))completionHandler;

@end
