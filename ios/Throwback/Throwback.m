//
//  Throwback.m
//  Throwback
//
//  Created by Adrien Truong on 13/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "Throwback.h"
#import "TimePeriod.h"

@implementation Throwback

- (NSArray *)photoIDs
{
    NSMutableArray *photoIDs = [NSMutableArray array];
    for (TimePeriod *period in self.timePeriods) {
        [photoIDs addObjectsFromArray:period.facebookPhotoIDs];
    }
    return photoIDs;
}

@end
