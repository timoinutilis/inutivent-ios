//
//  UIImage+Utils.m
//  Gromf
//
//  Created by Timo Kloss on 22/10/14.
//  Copyright (c) 2014 Inutilis Software. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

- (UIImage *)resizedImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    // An autoreleased image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
