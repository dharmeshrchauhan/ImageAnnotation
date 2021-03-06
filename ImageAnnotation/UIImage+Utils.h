//
//  UIImage+Utils.h
//  ImageAnnotation
//
//  Created by Sagar on 13/04/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage *) getMaskedArtworkFromPicture:(UIImage *)image withMask:(UIImage *)mask;
- (UIImage*)imageByClearingWhitePixels;
- (UIImage*)imageByChangingWhitePixels;
@end