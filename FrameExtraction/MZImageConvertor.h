//
//  MZImageconvertor.h
//  FrameExtraction
//
//  Created by Meirtz on 2017/6/7.
//  Copyright © 2017年 bRo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

@interface MZImageConvertor: NSObject

@property (strong, nonatomic) id someProperty;


+ (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height;
+ (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image;
+ (void)hello;
@end


