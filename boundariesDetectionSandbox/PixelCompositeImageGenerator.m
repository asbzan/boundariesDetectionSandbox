//
//  PixelCompositeImageGenerator.m
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/2/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import "PixelCompositeImageGenerator.h"


#define BYTESPERPIXEL 4
#define BITSPERCOMPONENT 8
#define RGBA_BIGEND_REDCHANNEL 0
#define RGBA_BIGEND_GREENCHANNEL 1
#define RGBA_BIGEND_BLUECHANNEL 2
#define RGBA_BIGEND_ALPHACHANNEL 3
#define RGBA_LITTLEEND_REDCHANNEL 3
#define RGBA_LITTLEEND_GREENCHANNEL 2
#define RGBA_LITTLEEND_BLUECHANNEL 1
#define RGBA_LITTLEEND_ALPHACHANNEL 0


@implementation PixelCompositeImageGenerator


+(instancetype)singleton {
    static id sharedSingletonInstance = nil;
    static dispatch_once_t singletonDispatcher;
    dispatch_once(&singletonDispatcher, ^{
        sharedSingletonInstance = [[self alloc] init];
    });
    return sharedSingletonInstance;
}





-(void) createFirstDefaultMonoChannelCompositeFromImage1:(UIImage *)image1 AndImage2:(UIImage *)image2 {
    
    [self createFirstCustomGreyChannelCompositeFromImage1:image1 AndImage2:image2 WithWeightsRed:0 Green:1 Blue:0];
    
}


-(void) createDefaultMonoChannelCompositeFromComposite:(UIImage *)composite AndNewImage:(UIImage *)image OfNImages:(NSUInteger)totalNum {
    
    [self createCustomGreyChannelCompositeFromComposite:composite AndNewImage:image OfNimages:totalNum WithWeightsRed:0 Green:1 Blue:0];
    
}


-(void) createFirstCustomMonoChannelCompositeFromImage1:(UIImage *)image1 AndImage2: (UIImage *)image2 OfColorChannel:(ImageChannel) monoColor {
    
    double redProportion = 0;
    double greenProportion = 0;
    double blueProportion = 0;
    
    switch (monoColor) {
        case Red:
            redProportion = 1;
            break;
        case Green:
            greenProportion = 1;
            break;
        case Blue:
            blueProportion = 1;
            break;
        default: // default channel is green
            greenProportion = 1;
            break;
    }
    
    [self createFirstCustomGreyChannelCompositeFromImage1:image1 AndImage2:image2 WithWeightsRed:redProportion Green:greenProportion Blue:blueProportion];
}


-(void) createCustomMonoChannelCompositeFromComposite:(UIImage *)image1 AndNewImage:(UIImage *)image2 OfNimages:(NSUInteger)totalNum OfColorChannel:(ImageChannel)monoColor {
    
    double redProportion = 0;
    double greenProportion = 0;
    double blueProportion = 0;
    
    switch (monoColor) {
        case Red:
            redProportion = 1;
            break;
        case Green:
            greenProportion = 1;
            break;
        case Blue:
            blueProportion = 1;
            break;
        default: // default channel is green
            greenProportion = 1;
            break;
    }
    
    [self createCustomGreyChannelCompositeFromComposite:image1 AndNewImage:image2 OfNimages:totalNum WithWeightsRed:redProportion Green:greenProportion Blue:blueProportion];
}



-(void) createFirstCustomGreyChannelCompositeFromImage1:(UIImage *)image1 AndImage2: (UIImage *)image2 WithWeightsRed: (double)redWeight Green:(double)greenWeight Blue:(double)blueWeight {
    
    NSUInteger image1UIWidth = image1.size.width;
    NSUInteger image2UIWidth = image2.size.width;
    NSUInteger image1UIHeight = image1.size.height;
    NSUInteger image2UIHeight = image2.size.height;
    if (image1UIWidth != image2UIWidth || image1UIHeight != image2UIHeight) {
        NSLog(@"WARNING! image dimensions (and/or from orientations) NOT congruent! createCustomFirstComposite will fail if the CGImage dimensions don't match!!");
    }
    NSLog(@"CreateFirstComposite MainThread=%d", [NSThread isMainThread]);
    
    UIImage *output;
    UIImage *input1Grayscale = [self internalCustomGrayscale:image1 UsingWeightsRed:redWeight Green:greenWeight Blue:blueWeight];
    if (input1Grayscale == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image1Grayscale conversion failed (see previous error in log)!!");
        return;
    }
    UIImage *input2Grayscale = [self internalCustomGrayscale:image2 UsingWeightsRed:redWeight Green:greenWeight Blue:blueWeight];
    if (input2Grayscale == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image2Grayscale conversion failed (see previous error in log)!!");
        return;
    }
    
    CGImageRef input1GreyImageRef = [input1Grayscale CGImage];
    CGImageRef input2GreyImageRef = [input2Grayscale CGImage];
    // this feels inefficient... check for memory usage...
    
    NSUInteger input1width = CGImageGetWidth(input1GreyImageRef);
    NSUInteger input2width = CGImageGetWidth(input2GreyImageRef);
    NSUInteger input1height = CGImageGetHeight(input1GreyImageRef);
    NSUInteger input2height = CGImageGetHeight(input2GreyImageRef);
    
    CGBitmapInfo gray1ConvertedInfo = CGImageGetBitmapInfo(input1GreyImageRef);
    CGBitmapInfo gray2ConvertedInfo = CGImageGetBitmapInfo(input2GreyImageRef);
    CGBitmapInfo bitmapSettings1 = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettings2 = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapSettings3 = kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapSettings4 = kCGBitmapByteOrder32Little;
    NSLog(@"LittleAlphaPremultLast: %u, BigAlphaPremultLast: %u, BigEndian: %u, LittleEndian: %u", bitmapSettings1, bitmapSettings2, bitmapSettings3, bitmapSettings4);
    NSLog(@"converted gray1:%u ; converted gray2:%u", gray1ConvertedInfo, gray2ConvertedInfo);
    // above bitmap info not necessary
    
    if (input1width != input2width || input1height != input2height) {
        NSLog(@"ERROR!!!! createCustomFirstComposite image1, image2 CGimage dimensions NOT congruent. Returning NULL!!!");
        return;
    }
    
    NSUInteger bitmapBytesPerRowInputImg = input1width * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * input2height;
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return;
    }
    
    
    CGContextRef input1GrayContextRef; // = [ImagePixelLevelFunctions newConvertedRGBABitmapContext:input1GreyImageRef];
    // be double check sure that this gets freed by the caller's free action for getting this pointer
    unsigned char *pixelGrayInput1Data = malloc(bitmapTotalByteSizeInputImg);
    if (pixelGrayInput1Data == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    // so CGBitmapInfo parameter in samples gets left at only kCGImagePremultipliedLast, which creates a warning since it's not a true bitmapInfo object and it gets an implicit conversion
    // but all examples just only use kCGImageAlphaPremultipliedLast enum as argument, BitmapByteOrderDefault is applied since it's 0 value, and default for iOS seems to be little Endian
    //CGBitmapInfo newBitmapSettings
    // So JPEG seems to be stored in Big Endian format as a standard? PNG is unknown?? GIF,BMP stored as little endian?
    // TIFF has header field supporting either...
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    //NSLog(@"Big Endian Byte Order (like most PowerPCs and network byte order) tho ARM supposedly bi-Endian with a preference against Big-endians (are there true fully even-split bisexuals though either?) " );
    input1GrayContextRef = CGBitmapContextCreate(pixelGrayInput1Data, input1width, input1height, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (input1GrayContextRef == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image1GrayContext failed (see previous error in log)!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelGrayInput1Data);
        return;
    }
    
    CGContextRef input2GrayContextRef; // = [ImagePixelLevelFunctions newConvertedRGBABitmapContext:input2GreyImageRef];
    unsigned char *pixelGrayInput2Data = malloc(bitmapTotalByteSizeInputImg);
    if (pixelGrayInput2Data == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    input2GrayContextRef = CGBitmapContextCreate(pixelGrayInput2Data, input2width, input2height, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (input2GrayContextRef == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image2GrayContext failed (see previous error in log)!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelGrayInput1Data);
        CGContextRelease(input1GrayContextRef);
        free(pixelGrayInput2Data);
        return;
    }
    
    CGContextDrawImage(input1GrayContextRef, CGRectMake(0, 0, input1width, input1height), input1GreyImageRef);
    CGContextDrawImage(input2GrayContextRef, CGRectMake(0, 0, input2width, input2height), input2GreyImageRef);
    // Pixel Processor releases both input1-2 Context Ref here
    
    CGContextRef outputImageContext;// = [ImagePixelLevelFunctions createNewOutputContextWithWidth:input1width WithHeight:input2height];
    unsigned char *pixelOutputData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelOutputData == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelGrayInput1Data);
        free(pixelGrayInput2Data);
        CGContextRelease(input1GrayContextRef);
        CGContextRelease(input2GrayContextRef);
        return;
    }
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    //NSLog(@"Big Endian Byte Order (like most PowerPCs and network byte order) tho ARM supposedly bi-Endian with a preference against Big-endians (are there true fully even-split bisexuals though either?) " );
    outputImageContext = CGBitmapContextCreate(pixelOutputData, input2width, input2height, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (outputImageContext == NULL) {
        NSLog(@"ERROR!! createCustomFirstComposite Output Image context NOT created (error msg for function in Log too)!!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelGrayInput1Data);
        free(pixelGrayInput2Data);
        CGContextRelease(input1GrayContextRef);
        CGContextRelease(input2GrayContextRef);
        free(pixelOutputData);
        return;
    }
    //CGContextDrawImage(outputImageContext, CGRectMake(0, 0, input2width, input1height), image2.CGImage); in pixel processor but didn't fix saving bug
    // pixel processor has cgcontext and colorspace released
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapTest = kCGBitmapByteOrder32Big;
    // check to make sure this is making appropriate comparison evalutation
    BOOL areSame = bitmapSettingsBig == bitmapTest;
    BOOL areDifferent = bitmapSettingsLittle == bitmapTest;
    NSLog(@"check that comparison operator works: MaybeTrue:%d ShouldFalse:%d ", areSame, areDifferent);
    if (CGBitmapContextGetBitmapInfo(outputImageContext) ==  bitmapSettingsBig) {
        NSLog(@"BigEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = YES;
    }
    else if (CGBitmapContextGetBitmapInfo(outputImageContext) ==  bitmapSettingsLittle) {
        NSLog(@"LittleEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = NO;
        
    }
    else {
        NSLog(@"ERROR! Since Byte Order NOT known, image contexts can't guarantee correct channel access!");
        free(pixelOutputData);
        free(pixelGrayInput1Data);
        free(pixelGrayInput2Data);
        CGContextRelease(outputImageContext);
        CGContextRelease(input1GrayContextRef);
        CGContextRelease(input2GrayContextRef);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    const NSUInteger RED_CHANNEL = (isBigEnd ? RGBA_BIGEND_REDCHANNEL : RGBA_LITTLEEND_REDCHANNEL);
    const NSUInteger GREEN_CHANNEL = (isBigEnd ? RGBA_BIGEND_GREENCHANNEL : RGBA_LITTLEEND_GREENCHANNEL);
    const NSUInteger BLUE_CHANNEL = (isBigEnd ? RGBA_BIGEND_BLUECHANNEL : RGBA_LITTLEEND_BLUECHANNEL);
    const NSUInteger ALPHA_CHANNEL = (isBigEnd ? RGBA_BIGEND_ALPHACHANNEL : RGBA_LITTLEEND_ALPHACHANNEL);
    const NSUInteger RGBACHANNEL_BIGGREEN_LITTLEBLUE = 1; // since all color values same
    
    unsigned long byteIndex = 0;
    for (NSUInteger ij = 0; ij < (input2width * input1height); ij++) {
        unsigned char input1grayValue = pixelGrayInput1Data[byteIndex + RGBACHANNEL_BIGGREEN_LITTLEBLUE];
        unsigned char input2grayValue = pixelGrayInput2Data[byteIndex + RGBACHANNEL_BIGGREEN_LITTLEBLUE];
        int input1 = (int)input1grayValue;
        int input2 = (int)input2grayValue;
        double result = (double)(input1 + input2) / 2.0;
        int resultInt = (int)result;
        unsigned char outputValue = (unsigned char)resultInt;
        
        //consider if the offset ordering makes this bad or not for performance/parallelization
        pixelOutputData[byteIndex + RED_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + GREEN_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + BLUE_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + ALPHA_CHANNEL] = 255;
        
        byteIndex += BYTESPERPIXEL;
    }
    
    CGContextRelease(input1GrayContextRef);
    CGContextRelease(input2GrayContextRef);
    // FIXED SAVING BUG! apparently a Fourth Context is required to somehow let image be saved
    CGContextRef anotherContext = CGBitmapContextCreate(pixelOutputData, input1width, input2height, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    free(pixelGrayInput1Data);
    free(pixelGrayInput2Data);
    
    CGImageRef outputSingleChannelImage = CGBitmapContextCreateImage(anotherContext);
    // above seemingly simpler/more direct, BUT if problematic/non-working, then below method more guaranteed way, but with much more details...
    // consider using below for greater control/precision of resulting image
    /*NSUInteger bitsPerPixel = BYTESPERPIXEL * 8; // 8 bits/byte
     CGBitmapInfo bitmapSettings = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
     
     CGDataProviderRef outputProvider = CGDataProviderCreateWithData(NULL, pixelOutputData, sizeof(pixelOutputData), freePixelData2);
     
     CGImageRef outputCompositeImage = CGImageCreate(input2width, input1height, BITSPERCOMPONENT, bitsPerPixel, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, bitmapSettings, outputProvider, NULL, NO, kCGRenderingIntentDefault);
     */
    
    output = [[UIImage alloc] initWithCGImage:outputSingleChannelImage]; // [UIImage imageWithCGImage:outputCompositeImage]; did not fix saving bug
    
    //CGDataProviderRelease(outputProvider);
    CGContextRelease(outputImageContext);
    CGContextRelease(anotherContext);
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    CGImageRelease(outputSingleChannelImage); // CHECK if reduces memory footprint with release, as saving bug not affected by change
    free(pixelOutputData); //the callback should release it when done!?
    
    
    if ([self.delegate respondsToSelector: @selector(grayscaleOutput:)]) {
        [self.delegate grayscaleOutput:output];
    }
}





-(void) createCustomGreyChannelCompositeFromComposite:(UIImage *)composite AndNewImage:(UIImage *)image OfNimages:(NSUInteger)totalNum WithWeightsRed:(double) redWeight Green:(double) greenWeight Blue:(double) blueWeight {
    
    NSUInteger compositeUIWidth = composite.size.width;
    NSUInteger newImageUIWidth = image.size.width;
    NSUInteger compositeUIHeight = composite.size.height;
    NSUInteger newImageUIHeight = image.size.height;
    if (compositeUIWidth != newImageUIWidth || compositeUIHeight != newImageUIHeight) {
        NSLog(@"WARNING! image dimensions (and/or from orientations) NOT congruent! createCustomComposite will fail if the CGImage dimensions don't match!!");
    }
    NSLog(@"combineNewWithComposite MainThread=%d", [NSThread isMainThread]);
    
    UIImage *output;
    UIImage *newImageGrayscale = [self internalCustomGrayscale:image UsingWeightsRed:redWeight Green:greenWeight Blue:blueWeight];
    if (newImageGrayscale == NULL) {
        NSLog(@"ERROR!!! createCustomComposite newImageGrayscale conversion failed (see previous error in log)!!");
        return;
    }
    // ASSUMING EXISTING COMPOSITE IS GRAYSCALE!
    CGImageRef compositeImageRef = [composite CGImage];
    CGImageRef newGreyImageRef = [newImageGrayscale CGImage];
    // this feels inefficient... check for memory usage...
    
    NSUInteger compositeCGWidth = CGImageGetWidth(compositeImageRef);
    NSUInteger newGrayCGWidth = CGImageGetWidth(newGreyImageRef);
    NSUInteger compositeCGHeight = CGImageGetHeight(compositeImageRef);
    NSUInteger newGrayCGHeight = CGImageGetHeight(newGreyImageRef);
    if (compositeCGWidth != newGrayCGWidth || compositeCGHeight != newGrayCGHeight) {
        NSLog(@"ERROR!!!! createCustomComposite Composite and NewGray CGimage dimensions NOT congruent. Returning NULL!!!");
        //CGImageRelease(compositeImageRef); will DELETE input composite
        return;
    }
    
    CGBitmapInfo compositeConvertedInfo = CGImageGetBitmapInfo(compositeImageRef);
    CGBitmapInfo grayConvertedInfo = CGImageGetBitmapInfo(newGreyImageRef);
    CGBitmapInfo bitmapSettings1 = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettings2 = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapSettings3 = kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapSettings4 = kCGBitmapByteOrder32Little;
    NSLog(@"LittleAlphaPremultLast: %u, BigAlphaPremultLast: %u, BigEndian: %u, LittleEndian: %u", bitmapSettings1, bitmapSettings2, bitmapSettings3, bitmapSettings4);
    NSLog(@"composite1:%u ; converted gray2:%u", compositeConvertedInfo, grayConvertedInfo);
    
    
    NSUInteger bitmapBytesPerRowInputImg = compositeCGWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * newGrayCGHeight;
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return;
    }
    
    CGContextRef compositeContextRef; // = [self newConvertedRGBABitmapContext:compositeImageRef];
    // be double check sure that this gets freed by the caller's free action for getting this pointer
    unsigned char *pixelCompositeData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelCompositeData == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    // so CGBitmapInfo parameter in samples gets left at only kCGImagePremultipliedLast, which creates a warning since it's not a true bitmapInfo object and it gets an implicit conversion
    // but all examples just only use kCGImageAlphaPremultipliedLast enum as argument, BitmapByteOrderDefault is applied since it's 0 value, and default for iOS seems to be little Endian
    //CGBitmapInfo newBitmapSettings
    // So JPEG seems to be stored in Big Endian format as a standard? PNG is unknown?? GIF,BMP stored as little endian?
    // TIFF has header field supporting either...
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    //NSLog(@"Big Endian Byte Order (like most PowerPCs and network byte order) tho ARM supposedly bi-Endian with a preference against Big-endians (are there true fully even-split bisexuals though either?) " );
    compositeContextRef = CGBitmapContextCreate(pixelCompositeData, compositeCGWidth, compositeCGHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (compositeContextRef == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image1GrayContext failed (see previous error in log)!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelCompositeData);
        return;
    }
    
    CGContextRef newGrayContextRef; // = [self newConvertedRGBABitmapContext:newGreyImageRef];
    unsigned char *pixelNewGrayData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelNewGrayData == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    newGrayContextRef = CGBitmapContextCreate(pixelNewGrayData, newGrayCGWidth, newGrayCGHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (newGrayContextRef == NULL) {
        NSLog(@"ERROR!!! createCustomFirstComposite image2GrayContext failed (see previous error in log)!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelNewGrayData);
        CGContextRelease(compositeContextRef);
        free(pixelCompositeData);
        return;
    }
    
    
    CGContextDrawImage(compositeContextRef, CGRectMake(0, 0, compositeCGWidth, compositeCGHeight), compositeImageRef);
    CGContextDrawImage(newGrayContextRef, CGRectMake(0, 0, newGrayCGWidth, newGrayCGHeight), newGreyImageRef);
    
    
    CGContextRef outputImageContext; // = [self createNewOutputContextWithWidth:compositeCGWidth WithHeight:newGrayCGHeight];
    unsigned char *pixelOutputData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelOutputData == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelCompositeData);
        free(pixelNewGrayData);
        CGContextRelease(compositeContextRef);
        CGContextRelease(newGrayContextRef);
        return;
    }
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    //NSLog(@"Big Endian Byte Order (like most PowerPCs and network byte order) tho ARM supposedly bi-Endian with a preference against Big-endians (are there true fully even-split bisexuals though either?) " );
    outputImageContext = CGBitmapContextCreate(pixelOutputData, newGrayCGWidth, newGrayCGHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (outputImageContext == NULL) {
        NSLog(@"ERROR!! createCustomComposite Output Image context NOT created (error msg for function in Log too)!!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelCompositeData);
        free(pixelNewGrayData);
        CGContextRelease(compositeContextRef);
        CGContextRelease(newGrayContextRef);
        free(pixelOutputData);
        return;
    }
    
    // this possibly fixes things (no)
    //CGContextDrawImage(outputImageContext, CGRectMake(0, 0, compositeCGWidth, compositeCGHeight), compositeImageRef);
    
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    if (CGBitmapContextGetBitmapInfo(outputImageContext) ==  bitmapSettingsBig) {
        NSLog(@"BigEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = YES;
    }
    else if (CGBitmapContextGetBitmapInfo(outputImageContext) ==  bitmapSettingsLittle) {
        NSLog(@"LittleEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = NO;
        
    }
    else {
        NSLog(@"ERROR! Since Byte Order NOT known, image contexts can't guarantee correct channel access!");
        free(pixelOutputData);
        free(pixelCompositeData);
        free(pixelNewGrayData);
        CGContextRelease(outputImageContext);
        CGContextRelease(compositeContextRef);
        CGContextRelease(newGrayContextRef);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    const NSUInteger RED_CHANNEL = (isBigEnd ? RGBA_BIGEND_REDCHANNEL : RGBA_LITTLEEND_REDCHANNEL);
    const NSUInteger GREEN_CHANNEL = (isBigEnd ? RGBA_BIGEND_GREENCHANNEL : RGBA_LITTLEEND_GREENCHANNEL);
    const NSUInteger BLUE_CHANNEL = (isBigEnd ? RGBA_BIGEND_BLUECHANNEL : RGBA_LITTLEEND_BLUECHANNEL);
    const NSUInteger ALPHA_CHANNEL = (isBigEnd ? RGBA_BIGEND_ALPHACHANNEL : RGBA_LITTLEEND_ALPHACHANNEL);
    const NSUInteger RGBACHANNEL_BIGGREEN_LITTLEBLUE = 1; // since all color values same
    
    unsigned long byteIndex = 0;
    for (NSUInteger ij = 0; ij < (newGrayCGWidth * compositeCGHeight); ij++) {
        unsigned char compositeGrayValue = pixelCompositeData[byteIndex + RGBACHANNEL_BIGGREEN_LITTLEBLUE];
        unsigned char newGrayValue = pixelNewGrayData[byteIndex + RGBACHANNEL_BIGGREEN_LITTLEBLUE];
        int prevComposite = (int)compositeGrayValue;
        int newInput = (int)newGrayValue;
        double result = (double)((prevComposite * (totalNum - 1)) + newInput) / (double)totalNum;
        int resultInt = (int)result;
        unsigned char outputValue = (unsigned char)resultInt;
        
        //consider if the offset ordering makes this bad or not for performance/parallelization
        pixelOutputData[byteIndex + RED_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + GREEN_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + BLUE_CHANNEL] = outputValue;
        pixelOutputData[byteIndex + ALPHA_CHANNEL] = 255;
        
        byteIndex += BYTESPERPIXEL;
    }
    
    CGContextRelease(compositeContextRef);
    CGContextRelease(newGrayContextRef);
    
    // FIXED SAVING BUG! apparently a Fourth Context is required to somehow let image be saved
    CGContextRef anotherContext = CGBitmapContextCreate(pixelOutputData, compositeCGWidth, newGrayCGHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    free(pixelCompositeData);
    free(pixelNewGrayData);
    
    CGImageRef outputSingleChannelImage = CGBitmapContextCreateImage(anotherContext);
    // above seemingly simpler/more direct, BUT if problematic/non-working, then below method more guaranteed way, but with much more details...
    // consider using below for greater control/precision of resulting image
    /* NSUInteger bitsPerPixel = BYTESPERPIXEL * 8; // 8 bits/byte
     CGBitmapInfo bitmapSettings = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
     
     CGDataProviderRef outputProvider = CGDataProviderCreateWithData(NULL, pixelOutputData, sizeof(pixelOutputData), freePixelData2);
     
     CGImageRef outputCompositeImage = CGImageCreate(newGrayCGWidth, compositeCGHeight, BITSPERCOMPONENT, bitsPerPixel, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, bitmapSettings, outputProvider, NULL, NO, kCGRenderingIntentDefault);
     */
    output = [[UIImage alloc] initWithCGImage:outputSingleChannelImage];
    
    //CGDataProviderRelease(outputProvider);
    CGContextRelease(outputImageContext);
    CGContextRelease(anotherContext);
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    CGImageRelease(outputSingleChannelImage); // CHECK if reduces memory footprint with release, as saving bug not affected by change
    free(pixelOutputData);
    
    if ([self.delegate respondsToSelector: @selector(grayscaleOutput:)]) {
        [self.delegate grayscaleOutput:output];
    }
    
}





-(void) extract: (UIImage *)originalImage SingleChannel:(ImageChannel)channel {
    
    UIImage *output;
    CGImageRef inputCGimageRef = [originalImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    CGContextRef inputImageContext; //= [ImagePixelLevelFunctions newConvertedRGBABitmapContext:inputCGimageRef];
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    // = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); supposedly only works for mac instead of iOS? but why is method still in objective c documentation?!?!?
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return;
    }
    
    // be double check sure that this gets freed by the caller's free action for getting this pointer
    unsigned char *bitmapDataInputImg = malloc(bitmapTotalByteSizeInputImg);
    if (bitmapDataInputImg == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return;
    }
    
    // So JPEG seems to be stored in Big Endian format as a standard? PNG is unknown?? GIF,BMP stored as little endian?
    // TIFF has header field supporting either...
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    //NSLog(@"Big Endian Byte Order (like most PowerPCs and network byte order) tho ARM supposedly bi-Endian with a preference against Big-endians (are there true fully even-split bisexuals though either?) " );
    inputImageContext = CGBitmapContextCreate(bitmapDataInputImg, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (inputImageContext == NULL) {
        NSLog(@"ERROR!! extractSingleChannel Converted Input Image context NOT created (error msg for function in Log too)!!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(bitmapDataInputImg);
        return;
    }
    
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapTest = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    /*
     BOOL areSame = bitmapSettingsBig == bitmapTest;
     BOOL areDifferent = bitmapSettingsLittle == bitmapTest;
     NSLog(@"check that comparison operator works: ShouldTrue:%d ShouldFalse:%d ", areSame, areDifferent);
     */
    if (CGBitmapContextGetBitmapInfo(inputImageContext) ==  bitmapSettingsBig) {
        NSLog(@"BigEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = YES;
    }
    else if (CGBitmapContextGetBitmapInfo(inputImageContext) ==  bitmapSettingsLittle) {
        NSLog(@"LittleEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = NO;
        
    }
    else {
        NSLog(@"ERROR! Since Byte Order NOT known, image contexts can't guarantee correct channel access!");
        CGContextRelease(inputImageContext);
        free(bitmapDataInputImg);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        
        return;
    }
    const NSUInteger RED_CHANNEL = (isBigEnd ? RGBA_BIGEND_REDCHANNEL : RGBA_LITTLEEND_REDCHANNEL);
    const NSUInteger GREEN_CHANNEL = (isBigEnd ? RGBA_BIGEND_GREENCHANNEL : RGBA_LITTLEEND_GREENCHANNEL);
    const NSUInteger BLUE_CHANNEL = (isBigEnd ? RGBA_BIGEND_BLUECHANNEL : RGBA_LITTLEEND_BLUECHANNEL);
    const NSUInteger ALPHA_CHANNEL = (isBigEnd ? RGBA_BIGEND_ALPHACHANNEL : RGBA_LITTLEEND_ALPHACHANNEL);
    
    NSUInteger indexByteChannelOffset;
    switch (channel) {
        case Red:
            indexByteChannelOffset = RED_CHANNEL;
            break;
        case Green:
            indexByteChannelOffset = GREEN_CHANNEL;
            break;
        case Blue:
            indexByteChannelOffset = BLUE_CHANNEL;
            break;
            // though not sure how useful alpha channel would be in this context...
        case Alpha:
            indexByteChannelOffset = ALPHA_CHANNEL;
            break;
        default:
            // Green is default, for our purposes
            indexByteChannelOffset = GREEN_CHANNEL;
            break;
    }
    
    unsigned long byteIndex = 0;
    for (NSUInteger ij = 0; ij < (inputWidth * inputHeight); ij++) {
        unsigned char outputColorChannel =  bitmapDataInputImg[byteIndex + indexByteChannelOffset];
        
        // pixelOutputData[byteIndex + ALPHA_CHANNEL] = 255;
        bitmapDataInputImg[byteIndex + RED_CHANNEL] = outputColorChannel;
        bitmapDataInputImg[byteIndex + GREEN_CHANNEL] = outputColorChannel;
        bitmapDataInputImg[byteIndex + BLUE_CHANNEL] = outputColorChannel;
        
        byteIndex += BYTESPERPIXEL;
    }
    
    CGContextRelease(inputImageContext);
    //CGImageRelease(inputCGimageRef); // this deletes the original source images since references passed
    
    //CGImageRef outputSingleChannelImage = CGBitmapContextCreateImage(outputImageContext);
    // above seemingly simpler/more direct, BUT if problematic/non-working, then below method more guaranteed way, but with much more details...
    // consider using below for greater control/precision of resulting image
    
    NSUInteger bitsPerPixel = BYTESPERPIXEL * 8; // 8 bits/byte
    NSUInteger bytesPerRow = inputWidth * BYTESPERPIXEL;
    // Confirmed! AlphaPremult...Last: LittleEnd = ABGR, BigEnd = RGBA (key difference to FilteringSmoothing Implementation)
    // Confirmed! Default is LittleEnd! not including BitmapByteOrder argument is same as applying default?
    CGBitmapInfo bitmapSettings1 = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    /* CGBitmapInfo bitmapSettings2 = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault;
     CGBitmapInfo bitmapSettings3 = kCGBitmapByteOrderDefault;
     CGBitmapInfo bitmapSettings4 = kCGImageAlphaPremultipliedLast;
     NSLog(@"bitmapInfo1: %u, bitmapInfo2: %u, bitmapInfo3: %u, bitmapInfo4: %u", bitmapSettings1, bitmapSettings2, bitmapSettings3, bitmapSettings4);
     */
    CGDataProviderRef outputProvider = CGDataProviderCreateWithData(NULL, bitmapDataInputImg, sizeof(bitmapDataInputImg), freePixelData2);
    
    CGImageRef outputSingleChannelImage = CGImageCreate(inputWidth, inputHeight, BITSPERCOMPONENT, bitsPerPixel, bytesPerRow, colorspaceStandardizedOutput, bitmapSettings1, outputProvider, NULL, NO, kCGRenderingIntentDefault);
    
    output = [UIImage imageWithCGImage:outputSingleChannelImage];
    
    CGDataProviderRelease(outputProvider);
    
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    CGImageRelease(outputSingleChannelImage); // maybe not keep this statement, as would mess up later references to output??? does ARC get rid of these images????? All examples show releasing tho
    //free(pixelOutputData); the callback should release it when done!?
    
    if ([self.delegate respondsToSelector: @selector(grayscaleOutput:)]) {
        [self.delegate grayscaleOutput:output];
    }
}



-(void) createCustomGrayscale: (UIImage *)originalImage UsingWeightsRed: (double)redWeight Green: (double)greenWeight Blue: (double)blueWeight {
    
    UIImage *output = [self internalCustomGrayscale:originalImage UsingWeightsRed:redWeight Green:greenWeight Blue:blueWeight];
    
    if ([self.delegate respondsToSelector: @selector(grayscaleOutput:)]) {
        [self.delegate grayscaleOutput:output];
    }
}


// normal "recc'd" values for grayscale conversion (from wikipedia) of sRGB standard from CIE 1931 linear luminence
//      is 0.2126R + 0.7152G + 0.0722B
-(void) createGrayscale: (UIImage *)originalImage {
    
    [self createCustomGrayscale:originalImage UsingWeightsRed:0.2126 Green:0.7152 Blue:0.0722];
}



//
// Internal Private reused methods
//


// SAVING BUG: FIX not in this function, already tested out matching to Pixel Processor with no fix to saving bug
-(UIImage *) internalCustomGrayscale: (UIImage *)originalImage UsingWeightsRed: (double)redWeight Green: (double)greenWeight Blue: (double)blueWeight {
    
    UIImage *output;
    CGImageRef inputCGimageRef = [originalImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    
    CGContextRef inputImageContext;
    //NSUInteger pixelsWidthInputImg = CGImageGetWidth(originalImage);
    //NSUInteger pixelsHeightInputImg = CGImageGetHeight(originalImage);
    //NSUInteger bitmapBytesPerRowInputImg = CGImageGetBytesPerRow(inputImage);
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    // = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); supposedly only works for mac instead of iOS? but why is method still in objective c documentation?!?!?
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return NULL;
    }
    
    // be double check sure that this gets freed by the caller's free action for getting this pointer
    unsigned char *bitmapDataInputImg = malloc(bitmapTotalByteSizeInputImg);
    if (bitmapDataInputImg == NULL) {
        NSLog(@"ERROR!! conversion memory space NOT ALLOCATED!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return NULL;
    }
    
    // so CGBitmapInfo parameter in samples gets left at only kCGImagePremultipliedLast, which creates a warning since it's not a true bitmapInfo object and it gets an implicit conversion
    // but all examples just only use kCGImageAlphaPremultipliedLast enum as argument, BitmapByteOrderDefault is applied since it's 0 value, and default for iOS seems to be little Endian
    //CGBitmapInfo newBitmapSettings
    // So JPEG seems to be stored in Big Endian format as a standard? PNG is unknown?? GIF,BMP stored as little endian?
    // TIFF has header field supporting either...
    // Network/Neutral Ordering is for Big-Endian (most human understandable)
    inputImageContext = CGBitmapContextCreate(bitmapDataInputImg, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //CGColorSpaceRelease(colorspaceStandardizedOutput); in pixel processor
    
    if (inputImageContext == NULL) {
        NSLog(@"ERROR!!! standardized RGBA output context NOT created! (will return null instance anyways so no escape)");
        free(bitmapDataInputImg);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return output;
    }
    
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    //CGContextRelease(inputImageContext); in pixel processor
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGBitmapInfo bitmapTest = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    // check to make sure this is making appropriate comparison evalutation
    BOOL areSame = bitmapSettingsBig == bitmapTest;
    BOOL areDifferent = bitmapSettingsLittle == bitmapTest;
    NSLog(@"check that comparison operator works: ShouldTrue:%d ShouldFalse:%d ", areSame, areDifferent);
    if (CGBitmapContextGetBitmapInfo(inputImageContext) ==  bitmapSettingsBig) {
        NSLog(@"BigEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = YES;
    }
    else if (CGBitmapContextGetBitmapInfo(inputImageContext) ==  bitmapSettingsLittle) {
        NSLog(@"LittleEndian--double check to ensure always matches imageContext Creation byte order...");
        isBigEnd = NO;
    }
    else {
        NSLog(@"ERROR! Since Byte Order NOT known, image contexts can't guarantee correct channel access!");
        CGContextRelease(inputImageContext);
        free(bitmapDataInputImg);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return output;
    }
    //byte order above not probably necessary anymore(since set to BigEndian always)... NOT in pixel processor
    
    const NSUInteger RED_CHANNEL = (isBigEnd ? RGBA_BIGEND_REDCHANNEL : RGBA_LITTLEEND_REDCHANNEL);
    const NSUInteger GREEN_CHANNEL = (isBigEnd ? RGBA_BIGEND_GREENCHANNEL : RGBA_LITTLEEND_GREENCHANNEL);
    const NSUInteger BLUE_CHANNEL = (isBigEnd ? RGBA_BIGEND_BLUECHANNEL : RGBA_LITTLEEND_BLUECHANNEL);
    const NSUInteger ALPHA_CHANNEL = (isBigEnd ? RGBA_BIGEND_ALPHACHANNEL : RGBA_LITTLEEND_ALPHACHANNEL);
    
    unsigned long byteIndex = 0;
    for (NSUInteger ij = 0; ij < (inputWidth * inputHeight); ij++) {
        unsigned char inPixelAlphaPremultRed = bitmapDataInputImg[byteIndex + RED_CHANNEL];
        unsigned char inPixelAlphaPremultGreen = bitmapDataInputImg[byteIndex + GREEN_CHANNEL];
        unsigned char inPixelAlphaPremultBlue = bitmapDataInputImg[byteIndex + BLUE_CHANNEL];
        /* unsigned char inPixelAlphaPremultAlpha = pixelInputData[byteIndex + ALPHA_CHANNEL];
         int red = (int)inPixelAlphaPremultRed;
         int green = (int)inPixelAlphaPremultGreen;
         int blue = (int)inPixelAlphaPremultBlue;
         int alpha = (int)inPixelAlphaPremultAlpha; */
        // consider if memory or performance is improved by putting all these calculations into one line
        // consider if more or less accurate with integer rounding/truncation at component level or the product level...
        double greyRedComponent = redWeight * (double)inPixelAlphaPremultRed;
        double greyGreenComponent = greenWeight * (double)inPixelAlphaPremultGreen;
        double greyBlueComponent = blueWeight * (double)inPixelAlphaPremultBlue;
        unsigned int customGreyProduct = (unsigned int)greyRedComponent + (unsigned int)greyGreenComponent + (unsigned int)greyBlueComponent; // consider if conversions are creating problems?? cast as int instead of unsigned int?
        unsigned char outputColorChannel = (unsigned char)customGreyProduct;
        //int outAlphaExisting = (int)pixelOutputData[byteIndex + ALPHA_CHANNEL];
        bitmapDataInputImg[byteIndex + RED_CHANNEL] = outputColorChannel;
        bitmapDataInputImg[byteIndex + GREEN_CHANNEL] = outputColorChannel;
        bitmapDataInputImg[byteIndex + BLUE_CHANNEL] = outputColorChannel;
        //pixelOutputData[byteIndex + ALPHA_CHANNEL] = 255;
        // CONSIDER IF Customing WITH ALPHA CHANNEL distorts image color/channel values: PremultipliedLast sets all to 255, leave unassigned would seemingly have it set to remain 0
        
        byteIndex += BYTESPERPIXEL;
    }
    
    CGContextRelease(inputImageContext);
    //CGImageRelease(inputCGimageRef); this DELETES the input image!
    
    // did NOT fix saving issue
    //CGContextRef grayContext = CGBitmapContextCreate(bitmapDataInputImg, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput,kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //CGImageRef outputSingleChannelImage = CGBitmapContextCreateImage(grayContext);
    // above seemingly simpler/more direct, BUT if problematic/non-working, then below method more guaranteed way, but with much more details...
    // consider using below for greater control/precision of resulting image
    NSUInteger bitsPerPixel = BYTESPERPIXEL * 8; // 8 bits/byte
    //NSUInteger bytesPerRow = inputWidth * BYTESPERPIXEL;
    //CGColorSpaceRef rgbaColorspaceRef = CGColorSpaceCreateDeviceRGB();
    // Confirmed! AlphaPremult...Last: LittleEnd = ARGB, BigEnd = RGBA (key difference to FilteringSmoothing Implementation)
    // Confirmed! Default is LittleEnd! not including BitmapByteOrder argument is same as applying default
    CGBitmapInfo bitmapSettings1 = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGDataProviderRef outputProvider = CGDataProviderCreateWithData(NULL, bitmapDataInputImg, sizeof(bitmapDataInputImg), freePixelData2);
    
    CGImageRef outputGrayscaleImage = CGImageCreate(inputWidth, inputHeight, BITSPERCOMPONENT, bitsPerPixel, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, bitmapSettings1, outputProvider, NULL, NO, kCGRenderingIntentDefault);
    
    
    output = [[UIImage alloc] initWithCGImage:outputGrayscaleImage]; // [UIImage imageWithCGImage:outputGrayscaleImage]; did not fix saving bug
    
    CGDataProviderRelease(outputProvider);
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    CGImageRelease(outputGrayscaleImage); // CHECK if reduces memory footprint with release, as saving bug not affected by change
    //free(bitmapDataInputImg); //the callback should release it when done!?
    
    /* CGContextRelease(grayContext);
     free(bitmapDataInputImg);
     CGImageRelease(outputSingleChannelImage); */
    
    return output;
    
}



void freePixelData2(void *info, const void *data, size_t size) {
    NSLog(@"freePixelData2 called");
    free((void *)data);
}


@end
