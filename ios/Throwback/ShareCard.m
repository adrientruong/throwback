//
//  ShareCard.m
//  Throwback
//
//  Created by Adrien Truong on 14/02/2016.
//  Copyright © 2016 Adrien Truong. All rights reserved.
//

#import "ShareCard.h"
#import "ShareCardView.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>

@implementation ShareCard

+ (UIImage *)shareCardImageWithPhoto:(Photo *)photo
{
    UINib *nib = [UINib nibWithNibName:@"ShareCardView" bundle:nil];
    ShareCardView *cardView = [[nib instantiateWithOwner:nil options:nil] firstObject];
    cardView.frame = CGRectMake(0, 0, photo.image.size.width, photo.image.size.height);
    NSString *format = @"#tb, listening to %@";
    if (photo.image.size.height > photo.image.size.width * 1.5) {
        format = @"#tb, listening to\n%@";
    }
    cardView.label.text = [NSString stringWithFormat:format, photo.songTitle];
    cardView.imageView.image = photo.image;
    
    [cardView layoutIfNeeded];
    UIGraphicsBeginImageContextWithOptions(cardView.bounds.size, cardView.opaque, 0.0);
    [cardView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
