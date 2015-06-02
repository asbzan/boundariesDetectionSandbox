//
//  PixelLevelClassFunctions.h
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, ImageChannel) {
    Red,
    Green,
    Blue,
    Alpha
};

@interface PixelLevelClassFunctions : NSObject

+(NSArray *) intensityProfileOfGrayscaleImage:(UIImage *)image Oriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2;
+(NSArray *) intensityProfileOfImage:(UIImage *)image OfSingleChannel: (ImageChannel)channel Oriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2;

// NOT implemented
//+(NSArray *) intensityProfileOfImage:(UIImage *)image OfDefaultGrayscaleOriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2;
//+(NSArray *) intensityProfileOfImage: (UIImage *)image OfCustomGrayscaleUsingWeightsRed: (double)redWeight Green: (double)greenWeight Blue: (double)blueWeight Oriented: (NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2;


+(NSArray *) boundariesForImageAnalysisFromRectangleDetection: (UIImage *)sourceCompositeImage;
+(NSArray *) boundariesForImageAnalysisForChannel: (ImageChannel)channel FromRectangleDetectionOf: (UIImage *)sourceCompositeImage;

@end
