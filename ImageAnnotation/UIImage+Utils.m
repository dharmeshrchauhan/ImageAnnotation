//
//  UIImage+Utils.m
//  ImageAnnotation
//
//  Created by Sagar on 13/04/15.
//  Copyright (c) 2015 Sagar. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

#pragma mark Private Methods
- (CGImageRef) CopyImageAndAddAlphaChannel:(CGImageRef) sourceImage {
    CGImageRef retVal = NULL;
    
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}

- (UIImage *) getMaskedArtworkFromPicture:(UIImage *)image withMask:(UIImage *)mask{
    
    UIImage *maskedImage;
    CGImageRef imageRef = [self CopyImageAndAddAlphaChannel:image.CGImage];
    CGImageRef maskRef = mask.CGImage;
    CGImageRef maskToApply = CGImageMaskCreate(CGImageGetWidth(maskRef),CGImageGetHeight(maskRef),CGImageGetBitsPerComponent(maskRef),CGImageGetBitsPerPixel(maskRef),CGImageGetBytesPerRow(maskRef),CGImageGetDataProvider(maskRef), NULL, NO);
    CGImageRef masked = CGImageCreateWithMask(imageRef, maskToApply);
    maskedImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(imageRef);
    CGImageRelease(maskToApply);
    CGImageRelease(masked);
    return maskedImage;
    
}

#pragma mark Public Methods
- (UIImage*)imageByClearingWhitePixels{
    
    //Copy image bitmaps
    float originalWidth = self.size.width;
    float originalHeight = self.size.height;
    CGSize newSize;
    
    newSize = CGSizeMake(originalWidth, originalHeight);
    
    UIGraphicsBeginImageContext( newSize );
    
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //Clear white color by masking with self
    newImage = [self getMaskedArtworkFromPicture:newImage withMask:newImage];
    
    return newImage;
}

@end