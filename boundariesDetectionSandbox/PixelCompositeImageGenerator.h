//
//  PixelCompositeImageGenerator.h
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/2/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PixelLevelClassFunctions.h"

@protocol GrayscaleGeneratorDelegate <NSObject>

-(void) grayscaleOutput: (UIImage *)grayscaleCreated;

@end

@interface PixelCompositeImageGenerator : NSObject

@property (weak, nonatomic) id<GrayscaleGeneratorDelegate> delegate;
+(instancetype)singleton;

-(void) extract: (UIImage *)originalImage SingleChannel:(ImageChannel)channel;
-(void) createCustomGrayscale: (UIImage *)originalImage UsingWeightsRed: (double)redWeight Green: (double)greenWeight Blue: (double)blueWeight;
-(void) createGrayscale: (UIImage *)originalImage;


-(void) createFirstDefaultMonoChannelCompositeFromImage1:(UIImage *)image1 AndImage2:(UIImage *)image2;
-(void) createDefaultMonoChannelCompositeFromComposite:(UIImage *)composite AndNewImage:(UIImage *)image OfNImages:(NSUInteger)totalNum;

-(void) createFirstCustomMonoChannelCompositeFromImage1:(UIImage *)image1 AndImage2: (UIImage *)image2 OfColorChannel:(ImageChannel) monoColor;
-(void) createCustomMonoChannelCompositeFromComposite:(UIImage *)image1 AndNewImage:(UIImage *)image2 OfNimages:(NSUInteger)totalNum OfColorChannel:(ImageChannel)monoColor;

-(void) createFirstCustomGreyChannelCompositeFromImage1:(UIImage *)image1 AndImage2: (UIImage *)image2 WithWeightsRed: (double)redWeight Green:(double)greenWeight Blue:(double)blueWeight;
-(void) createCustomGreyChannelCompositeFromComposite:(UIImage *)composite AndNewImage:(UIImage *)image OfNimages:(NSUInteger)totalNum WithWeightsRed:(double) redWeight Green:(double) greenWeight Blue:(double) blueWeight;

@end
