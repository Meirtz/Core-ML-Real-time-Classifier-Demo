//
//  MZImageConvertor.m
//  FrameExtraction
//
//  Created by Meirtz on 2017/6/7.
//  Copyright © 2017年 bRo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import "MZImageConvertor.h"

@implementation MZImageConvertor:NSObject

+ (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height {
    // create context, keeping original image properties
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    CGContextRef context = CGBitmapContextCreate(NULL, width, height,
                                                 CGImageGetBitsPerComponent(image),
                                                 CGImageGetBytesPerRow(image),
                                                 colorspace,
                                                 CGImageGetAlphaInfo(image));
    CGColorSpaceRelease(colorspace);
    
    
    if(context == NULL)
        return nil;
    
    
    // draw image to context (resizing it)
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    // extract resulting image from context
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    
    return imgRef;
}

+ (void)hello {
    NSLog(@"hello");
}

+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    CVPixelBufferRef pxbuffer = NULL;
    NSCParameterAssert(NULL != image);
    size_t originalWidth = CGImageGetWidth(image);
    size_t originalHeight = CGImageGetHeight(image);
    
    NSMutableData *imageData = [NSMutableData dataWithLength:originalWidth*originalHeight*4];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate([imageData mutableBytes], originalWidth, originalHeight, 8, 4*originalWidth, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(cgContext, CGRectMake(0, 0, originalWidth, originalHeight), image);
    CGContextRelease(cgContext);
    CGImageRelease(image);
    unsigned char *pImageData = (unsigned char *)[imageData bytes];
    
    
    CFDictionaryRef empty;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef m_pPixelBufferAttribs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                                             3,
                                                                             &kCFTypeDictionaryKeyCallBacks,
                                                                             &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(m_pPixelBufferAttribs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    CFDictionarySetValue(m_pPixelBufferAttribs, kCVPixelBufferOpenGLCompatibilityKey, empty);
    CFDictionarySetValue(m_pPixelBufferAttribs, kCVPixelBufferCGBitmapContextCompatibilityKey, empty);
    
    CVPixelBufferCreateWithBytes(kCFAllocatorDefault, originalWidth, originalHeight, kCVPixelFormatType_32BGRA, pImageData, originalWidth * 4, NULL, NULL, m_pPixelBufferAttribs, &pxbuffer);
    CFRelease(empty);
    CFRelease(m_pPixelBufferAttribs);
    
    
    return pxbuffer;
}

@end
