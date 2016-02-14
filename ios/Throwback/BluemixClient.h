//
//  BluemixClient.h
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class Throwback;

@interface BluemixClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (void)getThrowbackWithFacebookToken:(NSString *)facebookToken
                      spotifyToken:(NSString *)spotifyToken
                 completionHandler:(void (^)(Throwback *throwback, NSError *error))completionHandler;

@end
