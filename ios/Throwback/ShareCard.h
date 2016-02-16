//
//  ShareCard.h
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

@import UIKit;

@class Photo;

@interface ShareCard : NSObject

+ (UIImage *)shareCardImageWithPhoto:(Photo *)photo;

@end
