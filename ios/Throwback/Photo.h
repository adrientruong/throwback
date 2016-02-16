//
//  Photo.h
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Photo : NSObject

@property (nonatomic, copy) NSString *facebookID;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *songTitle;

@end
