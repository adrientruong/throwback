//
//  BluemixClient.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "BluemixClient.h"
#import "TimePeriod.h"
#import "Throwback.h"

#define kURLString @"https://throwback.mybluemix.net"
#define kURL [NSURL URLWithString:kURLString]

#define kGetPhotos @"request"

@implementation BluemixClient

+ (BluemixClient *)sharedClient
{
    static BluemixClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[BluemixClient alloc] initWithBaseURL:kURL];
    });
    
    return client;
}

- (void)getThrowbackWithFacebookToken:(NSString *)facebookToken
                      spotifyToken:(NSString *)spotifyToken
                 completionHandler:(void (^)(Throwback *, NSError *))completionHandler
{    
    NSDictionary *parameters = @{@"facebook_token": facebookToken,
                                 @"spotify_token": spotifyToken};
    
    [self GET:kGetPhotos parameters:parameters success:^(NSURLSessionDataTask *task, id response) {
        /*
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
         */
        
        NSArray *timePeriodDictionaries = response[@"time_periods"];
        NSMutableArray *timePeriods = [NSMutableArray array];
        for (NSDictionary *timePeriodDictionary in timePeriodDictionaries) {
            TimePeriod *period = [[TimePeriod alloc] init];
            period.facebookPhotoIDs = timePeriodDictionary[@"photos"];
            period.spotifySongIDs = timePeriodDictionary[@"songs"];
            [timePeriods addObject:period];
        }
        Throwback *throwback = [[Throwback alloc] init];
        throwback.timePeriods = timePeriods;
        completionHandler(throwback, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completionHandler(nil, error);
    }];
}

@end
