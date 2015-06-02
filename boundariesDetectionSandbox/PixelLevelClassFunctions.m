//
//  PixelLevelClassFunctions.m
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import "PixelLevelClassFunctions.h"
#import "HelperMathClassFunctions.h"

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

@implementation PixelLevelClassFunctions


// STUBS FOR NOW since these calls involved utilizing class level grayscale compositing functions, which weren't saving
// MEMORY LEAKAGE After these calls, the memory level stays at ~45 mb from initial ~13mb before call
+(NSArray *) intensityProfileOfImage:(UIImage *)image OfDefaultGrayscaleOriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2 {
    
    NSArray *output;
    //UIImage *defaultGrey = [ImagePixelLevelFunctions createGrayscale:image];
    //output = [PixelLevelClassFunctions intensityProfileOfGrayscaleImage:defaultGrey Oriented:orientation OfRegionX1:x1 Y1:y1 X2:x2 Y2:y2];
    return output;
}



// STUBS FOR NOW since these calls involved utilizing class level grayscale compositing functions, which weren't saving
// MEMORY LEAKAGE After these calls, the memory level stays at ~45 mb from initial ~13mb before call
+(NSArray *) intensityProfileOfImage: (UIImage *)image OfCustomGrayscaleUsingWeightsRed: (double)redWeight Green: (double)greenWeight Blue: (double)blueWeight Oriented: (NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2 {
    
    NSArray *output;
    //UIImage *customGrey = [ImagePixelLevelFunctions createCustomGrayscale:image UsingWeightsRed:redWeight Green:greenWeight Blue:blueWeight];
    //output = [PixelLevelClassFunctions intensityProfileOfGrayscaleImage:customGrey Oriented:orientation OfRegionX1:x1 Y1:y1 X2:x2 Y2:y2];
    return output;
}



// should be no more MEMORY LEAKAGE?? After these calls, the memory level stays at ~45 mb from initial ~13mb before call, but after refactoring shouldn't happen anymore
// Let X dimension be smaller dimension between Height and Width (so in portrait, would be width)
+(NSArray *)intensityProfileOfGrayscaleImage:(UIImage *)image Oriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2{
    
    NSArray *output;
    NSMutableArray *intensityRowXAverages = [NSMutableArray arrayWithCapacity:(y2  - y1)];
    
    CGImageRef inputCGimageRef = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return NULL;
    }
    
    CGContextRef inputImageContext;
    unsigned char *pixelInputData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelInputData == NULL) {
        NSLog(@"Error!! Single Channel Input Image Pixel Data pointer allocation failed!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return output; // or NULL
    }
    
    inputImageContext = CGBitmapContextCreate(pixelInputData, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (inputImageContext == NULL) {
        NSLog(@"Error!!! no context ref returned!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelInputData);
        return output;
    }
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    
    
    const NSUInteger RGBACHANNEL_BIGGREEN_LITTLEBLUE = 1;
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(inputCGimageRef);
    for (NSUInteger j = y1; j < y2; j++) {
        NSUInteger regionRowIntensitySum = 0;
        for (NSUInteger i = x1; i < x2; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i); // more clear-reliable, but check if computationally inefficient enough for automatic parallelization?
            UInt32 intensity = pixelInputData[byteIndxRegion+RGBACHANNEL_BIGGREEN_LITTLEBLUE]; // since grayscale, all channel values should be same, so should be trivial if is actually blue or green because of byte order
            regionRowIntensitySum += intensity;
        }
        
        NSArray *entry = [NSArray arrayWithObjects:[NSNumber numberWithFloat:((float)regionRowIntensitySum / (float)(x2-x1))], [NSNumber numberWithInteger:j], [NSNumber numberWithInteger:x1], [NSNumber numberWithInteger:x2], nil];
        [intensityRowXAverages addObject:entry];
    }
    
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    free(pixelInputData);
    CGContextRelease(inputImageContext);
    
    output = [NSArray arrayWithArray:intensityRowXAverages];
    return output;
}



// should be no more MEMORY LEAKAGE?? After these calls, the memory level stays at ~45 mb from initial ~13mb before call, but after refactoring shouldn't happen anymore
+(NSArray *) intensityProfileOfImage:(UIImage *)image OfSingleChannel: (ImageChannel)channel Oriented:(NSUInteger)orientation OfRegionX1:(NSUInteger)x1 Y1:(NSUInteger)y1 X2:(NSUInteger)x2 Y2:(NSUInteger)y2 {
    
    NSArray *output;
    NSMutableArray *intensityRowXAverages = [NSMutableArray arrayWithCapacity:(y2  - y1)];
    
    CGImageRef inputCGimageRef = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    // should look into more device independent encoding? like ICC profile/sRGB standard?
    // sRGB standard not sensitive enough to greens as compared to others??
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return NULL;
    }
    
    CGContextRef inputImageContext;
    unsigned char *pixelInputData = malloc(bitmapTotalByteSizeInputImg);
    if (pixelInputData == NULL) {
        NSLog(@"Error!! Single Channel Input Image Pixel Data pointer allocation failed!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return output; // or NULL
    }
    
    inputImageContext = CGBitmapContextCreate(pixelInputData, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (inputImageContext == NULL) {
        NSLog(@"Error!!! no context ref returned!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelInputData);
        return output;
    }
    
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
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
        free(pixelInputData);
        return output;
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
    
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(inputCGimageRef);
    
    for (NSUInteger j = y1; j < y2; j++) {
        NSUInteger regionRowIntensitySum = 0;
        for (NSUInteger i = x1; i < x2; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i); // more clear-reliable, but check if computationally inefficient enough for effective implicit parallelization?
            UInt32 intensity = pixelInputData[byteIndxRegion+indexByteChannelOffset]; // since grayscale, all channel values should be same, so technically trivial if is actually blue or green because of byte order
            regionRowIntensitySum += intensity;
        }
        
        NSArray *entry = [NSArray arrayWithObjects:[NSNumber numberWithFloat:((float)regionRowIntensitySum / (float)(x2-x1))], [NSNumber numberWithInteger:j], [NSNumber numberWithInteger:x1], [NSNumber numberWithInteger:x2], nil];
        [intensityRowXAverages addObject:entry];
    }
    
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    free(pixelInputData);
    CGContextRelease(inputImageContext);
    
    output = [NSArray arrayWithArray:intensityRowXAverages];
    
    return output;
}





// uses DEFAULT channel of Green
+(NSArray *) boundariesForImageAnalysisFromRectangleDetection: (UIImage *)sourceCompositeImage {
    
    NSArray *boundaries = [PixelLevelClassFunctions boundariesForImageAnalysisForChannel:Green FromRectangleDetectionOf:sourceCompositeImage];
    
    return boundaries;
}



+(NSArray *) boundariesForImageAnalysisForChannel: (ImageChannel)channel FromRectangleDetectionOf: (UIImage *)sourceCompositeImage {
    NSArray *boundaries;
    
    // threshold calculated from background intensity with sampled outer edge regions
    double threshold = [PixelLevelClassFunctions calculateThresholdPixelValueForChannel:channel FromImage:sourceCompositeImage];
    // apply filter transformation to set intensity for all below threshold to 0, and above left unchanged ?100?
    NSArray *transformedThresholdPixels = [PixelLevelClassFunctions singleChannel:channel FilteredPixelsArrayOf:sourceCompositeImage BelowThreshold:threshold];
    // search the y-axis? space for points where length ?> 100? of continuous above threshold
    // calculate longest above threshold band length for ?y-axis
    // ? search for across the other axis for same: Rotate CGImage?, use inverted traversal loop (slow memory access)??
    // calculate longest above threshold band length for other axis
    CGImageRef inputCGimageRef = [sourceCompositeImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    NSArray *collectionOfRectRegions = [PixelLevelClassFunctions findContinuousPixelIntensityBandRegions:transformedThresholdPixels WithWidth:inputWidth AndHeight:inputHeight];
    
    // ACTUALLY, technically don't need exact number of rectangles, only agreement among all rectangles for size difference
    /*
     switch (collectionOfRectRegions.count) {
     case 0:
     NSLog(@"ERROR: NO RECTANGLES FOUND!!!");
     return boundaries;
     break;
     case 1:
     NSLog(@"Single Rectangle Found!");
     break;
     case 2:
     NSLog(@"2 Rectangles Found!");
     break;
     default:
     NSLog(@"ERROR: TOO MANY RECTANGLES FOUND!!!");
     return boundaries;
     break;
     } */
    
    // the longer band for one axis will then be used to determine the start/end boundary points
    NSUInteger longerXcounter = 0;
    NSUInteger longerYcounter = 0;
    NSMutableArray *xRectCoords = [NSMutableArray array];
    NSMutableArray *yRectCoords = [NSMutableArray array];
    for (NSArray *rectangle in collectionOfRectRegions) {
        NSNumber *xRectStart = rectangle[0];
        NSNumber *yRectStart = rectangle[1];
        NSNumber *xRectEnd = rectangle[2];
        NSNumber *yRectEnd = rectangle[3];
        NSUInteger xLengthHeight = xRectEnd.unsignedIntegerValue - xRectStart.unsignedIntegerValue;
        NSUInteger yLengthWidth = yRectEnd.unsignedIntegerValue - yRectStart.unsignedIntegerValue;
        [xRectCoords addObject:[NSNumber numberWithInteger:xRectStart.integerValue]];
        [xRectCoords addObject:[NSNumber numberWithInteger:xRectEnd.integerValue]];
        [yRectCoords addObject:[NSNumber numberWithInteger:yRectStart.integerValue]];
        [yRectCoords addObject:[NSNumber numberWithInteger:yRectEnd.integerValue]];
        // separated so both counters are incremented if xHeight == yWidth
        if (xLengthHeight >= yLengthWidth) {
            longerXcounter++;
        }
        if (yLengthWidth >= xLengthHeight) {
            longerYcounter++;
        }
    }
    
    [xRectCoords sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *first = (NSNumber *)obj1;
        NSNumber *second = (NSNumber *)obj2;
        return [first compare:second];
    }];
    [yRectCoords sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *first = (NSNumber *)obj1;
        NSNumber *second = (NSNumber *)obj2;
        return [first compare:second];
    }];
    
    if (longerXcounter == longerYcounter) {
        NSLog(@"ONLY SQUARE(S) DETECTED!! Using DEFAULT BOUNDARIES of (950,50) to (2175,2400)");
        boundaries = [NSArray arrayWithObjects:[NSNumber numberWithInt:950], [NSNumber numberWithInt:50], [NSNumber numberWithInt:2175], [NSNumber numberWithInt:2400], nil];
    }
    // NOTE!!!!!! allowing more than 1 or 2 IDEAL Rectangles MIGHT mess this boundary up, as no longer STRICTLY TRUE
    // use the max min of the rect coords for the bondaries
    else if (longerXcounter > longerYcounter) {
        NSNumber *xSmallest = xRectCoords.firstObject;
        NSNumber *xLargest = xRectCoords.lastObject;
        NSNumber *ySmallest = yRectCoords.firstObject;
        NSNumber *yLargest = yRectCoords.lastObject;
        
        // buffer of 100 used so that later Profile analysis have a sample set of background values
        NSUInteger xBegin = (xSmallest.integerValue < 100 ? 0 : xSmallest.integerValue - 100);
        NSUInteger xEnd = (xLargest.integerValue > inputWidth - 100 ? inputWidth - 1 : xLargest.integerValue + 100);
        NSUInteger yBegin = (ySmallest.integerValue < 100 ? 0 : ySmallest.integerValue - 100);
        NSUInteger yEnd = (yLargest.integerValue > inputHeight - 100 ? inputHeight - 1 : yLargest.integerValue + 100);
        
        boundaries = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:xBegin], [NSNumber numberWithUnsignedInteger:yBegin], [NSNumber numberWithUnsignedInteger:xEnd], [NSNumber numberWithUnsignedInteger:yEnd], nil];
    }
    else {
        NSLog(@"ERROR: Need to rotate the cgimage for a proper profile!?!? But points being passed are flipped for axes, so would still work (but computationally/memory access bad?) ??? ");
        
        NSNumber *xSmallest = yRectCoords.firstObject;
        NSNumber *xLargest = yRectCoords.lastObject;
        NSNumber *ySmallest = xRectCoords.firstObject;
        NSNumber *yLargest = xRectCoords.lastObject;
        
        // buffer of 100 used so that later Profile analysis have a sample set of background values
        NSUInteger xBegin = (xSmallest.integerValue < 100 ? 0 : xSmallest.integerValue - 100);
        NSUInteger xEnd = (xLargest.integerValue > inputHeight - 100 ? inputHeight - 1 : xLargest.integerValue + 100);
        NSUInteger yBegin = (ySmallest.integerValue < 100 ? 0 : ySmallest.integerValue - 100);
        NSUInteger yEnd = (yLargest.integerValue > inputWidth - 100 ? inputWidth - 1 : yLargest.integerValue + 100);
        
        boundaries = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:xBegin], [NSNumber numberWithUnsignedInteger:yBegin], [NSNumber numberWithUnsignedInteger:xEnd], [NSNumber numberWithUnsignedInteger:yEnd], nil];
    }
    
    return boundaries;
}


// ASSUMING WIDTH = columns = i = Longest ~3200 = x coord, HEIGHT = Row/bytesPerRow = j = Shortest ~2400 = y coord
+(NSArray *) findContinuousPixelIntensityBandRegions: (NSArray *)sourcePixels WithWidth:(NSUInteger)width AndHeight:(NSUInteger)height{
    NSUInteger MINBANDLENGTH = 100;
    NSUInteger BANDGAPTHRESHOLD = 10;
    NSUInteger DISTORTIONTOLERANCE = 25;
    // collection of rectangular objects that have: x,y and then x2, y2 for diagonal corner to corner
    NSArray *regionDescriptions;
    NSMutableArray *growingRegions = [NSMutableArray array];
    NSMutableArray *fullXYdescriptionRegions = [NSMutableArray array];
    
    
    for (NSUInteger i = 0; i < height; i++) {
        NSUInteger rowPosition = i * width;
        NSMutableArray *currentRowRegions = [NSMutableArray array];
        BOOL previousPixelNonzero = FALSE;
        NSUInteger yStart = 0;
        NSUInteger bandLength = 0;
        for (NSUInteger j = 0; j < width; j++) {
            NSNumber *pixelIntensity = sourcePixels[rowPosition + j];
            if (pixelIntensity.doubleValue > 0 && previousPixelNonzero) {
                // continue length of band region
                bandLength++;
            }
            else if (pixelIntensity.doubleValue > 0) {
                // start of new row band region
                yStart = j;
                previousPixelNonzero = YES;
            }
            else if (previousPixelNonzero) {
                // save final length to record if above minLength=100
                if (bandLength > MINBANDLENGTH) {
                    NSArray *rowRegion = [NSArray arrayWithObjects: [NSNumber numberWithUnsignedInteger:yStart], [NSNumber numberWithUnsignedInteger:bandLength], nil];
                    [currentRowRegions addObject:rowRegion];
                }
                bandLength = 0;
                yStart = 0;
                previousPixelNonzero = NO;
            }
        }
        
        // process current row regions?
        // collapse regions if gap is less than tolerance?
        NSNumber *prevEndPoint = [NSNumber numberWithInt:0];
        NSMutableArray *keptRowRegions = [NSMutableArray array];
        for (NSArray *band in currentRowRegions) {
            NSNumber *length = band.lastObject;
            NSNumber *startPosition = band.firstObject;
            if ((startPosition.intValue - prevEndPoint.intValue) < BANDGAPTHRESHOLD) {
                NSArray *previousBand = [keptRowRegions lastObject];
                NSNumber *prevStartPosition = previousBand.firstObject;
                int newLength = (startPosition.intValue + length.intValue) - prevStartPosition.intValue;
                length = [NSNumber numberWithInt:newLength];
                startPosition = [NSNumber numberWithInt:prevStartPosition.intValue];
                // possible caution about persistance: references to last object's contents vs copies of its values
                [keptRowRegions removeLastObject];
            }
            NSArray *copiedBand = [NSArray arrayWithObjects:startPosition, length, nil];
            [keptRowRegions addObject:copiedBand];
            NSNumber *endPoint = [NSNumber numberWithInt:(startPosition.intValue + length.intValue)];
            prevEndPoint = endPoint;
        }
        
        // filter out any bands that are too short -- REDUNDANT since earlier bands are already prefiltered
        [currentRowRegions removeAllObjects];
        for (NSArray *band in keptRowRegions) {
            NSNumber *length = band.lastObject;
            NSNumber *startPosition = band.firstObject;
            if (length.intValue > MINBANDLENGTH) {
                NSArray *finalBand = [NSArray arrayWithObjects:startPosition, length, nil];
                [currentRowRegions addObject:finalBand ];
            }
        }
        
        for (NSArray *band in currentRowRegions) {
            NSNumber *length = band.lastObject;
            NSNumber *start = band.firstObject;
            
            NSNumber *xPosStart = [NSNumber numberWithUnsignedInteger:i];
            NSNumber *yPosStart = [NSNumber numberWithInteger:start.integerValue];
            NSNumber *yLength = [NSNumber numberWithInteger:length.integerValue];
            NSArray *region = [NSArray arrayWithObjects: xPosStart, yPosStart, yLength, nil];
            [growingRegions addObject:region];
        }
        
        // SKIP compare previous to current row regions so to process later to allow noise gaps across multiple rows!!
        
    } // end FOR loop traversal over entire image
    
    
    [growingRegions sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *regionA = (NSArray *)obj1;
        NSArray *regionB = (NSArray *)obj2;
        NSNumber *yPosA = regionA[1];
        NSNumber *yPosB = regionB[1];
        
        if (yPosA.intValue == yPosB.intValue) {
            NSNumber *xPosA = regionA[0];
            NSNumber *xPosB = regionB[0];
            return [xPosA compare:xPosB];
        }
        else {
            return [yPosA compare:yPosB];
        }
    }];
    
    // possible to do filteredSearch while inside an enumerated forin loop??? suspect can't...
    /* for (NSArray *region in growingRegions) {
     NSArray *sameRegion = [growingRegions filteredArrayUsingPredicate:(NSPredicate *)];
     } */
    // or maybe initially a search that returns same region rows?
    //      indexesofObjectsPassingTest: ... but predicate block would have to be applied for all regions to look for
    
    NSMutableSet *yStartPositions = [NSMutableSet set];
    for (NSArray *orderedBand in growingRegions) {
        NSNumber *y = orderedBand[1];
        [yStartPositions addObject:y];
    }
    
    
    NSMutableSet *yStartTolerancePositions = [NSMutableSet set];
    NSSet *copiedYstarts = [NSSet setWithSet:yStartPositions];
    NSSortDescriptor *ascendNumSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortAscDescripWrapper = [NSArray arrayWithObject:ascendNumSortDescriptor];
    for (NSNumber *yInitial in yStartPositions) {
        
        
        NSSet *closeYStarts = [copiedYstarts objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            NSNumber *evaluatedY = (NSNumber *)obj;
            return (evaluatedY.intValue < (yInitial.intValue + DISTORTIONTOLERANCE) && evaluatedY.intValue > (yInitial.intValue - DISTORTIONTOLERANCE));
        }];
        NSArray *yRangePositions = [NSArray arrayWithArray:
                                    [closeYStarts sortedArrayUsingDescriptors:sortAscDescripWrapper]
                                    ];
        NSUInteger midpoint = yRangePositions.count / 2;
        
        NSNumber *yMidRangeStart = yRangePositions[midpoint];
        [yStartTolerancePositions addObject:yMidRangeStart];
    }
    
    
    for (NSNumber *y in yStartTolerancePositions) {
        NSPredicate *nearbyYpositionPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSArray *regionEntry = (NSArray *)evaluatedObject;
            NSNumber *yCoord = regionEntry[1];
            return (yCoord.intValue < (y.intValue + DISTORTIONTOLERANCE) && yCoord.intValue > (y.intValue - DISTORTIONTOLERANCE));
        }];
        NSMutableArray *foundStackedBands = [NSMutableArray arrayWithArray:[growingRegions filteredArrayUsingPredicate:nearbyYpositionPredicate]];
        
        [foundStackedBands sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSArray *regionA = (NSArray *)obj1;
            NSArray *regionB = (NSArray *)obj2;
            NSNumber *xPosA = regionA[0];
            NSNumber *xPosB = regionB[0];
            
            return [xPosA compare:xPosB];
        }];
        
        NSUInteger xRunningLength = 0;
        NSUInteger prevXPosition = 0;
        double runningYavgPosition = 0;
        double runningYavgLength = 0;
        
        NSUInteger lastLoopIteration = foundStackedBands.count - 1;
        NSUInteger iterationCounter = 0;
        for (NSArray *band in foundStackedBands) {
            NSNumber *xCoordPos = band[0];
            NSNumber *yCoordPos = band[1];
            NSNumber *yLength = band[2];
            
            // recording the first rectangle start points (both at beginning and for next new rectangle)
            if (runningYavgLength == 0) {
                runningYavgLength = yLength.doubleValue;
                runningYavgPosition = yCoordPos.doubleValue;
            }
            // consider case of saving a rectangle if last band of iteration: SOLVED with counter
            else if (xCoordPos.integerValue >  (prevXPosition + BANDGAPTHRESHOLD) || iterationCounter == lastLoopIteration) {
                NSUInteger yPositionAvg = (NSUInteger)runningYavgPosition;
                NSUInteger yLengthAvg = (NSUInteger)runningYavgLength;
                NSNumber *xIniCoord = [NSNumber numberWithUnsignedInteger:(prevXPosition - xRunningLength)];
                NSNumber *yIniCoord = [NSNumber numberWithUnsignedInteger:yPositionAvg];
                NSNumber *xTotalLength = [NSNumber numberWithUnsignedInteger:xRunningLength];
                NSNumber *yTotalLength = [NSNumber numberWithUnsignedInteger:yLengthAvg];
                NSArray *finalRectangleObjectEntry = [NSArray arrayWithObjects:xIniCoord, yIniCoord, xTotalLength, yTotalLength, nil];
                
                if (xRunningLength > 100) {
                    [fullXYdescriptionRegions addObject:finalRectangleObjectEntry];
                }
                
                runningYavgLength = 0;
                runningYavgPosition = 0;
                xRunningLength = 0;
            }
            else {
                runningYavgPosition = (runningYavgPosition + yCoordPos.doubleValue)/2.0;
                runningYavgLength = (runningYavgLength + yLength.doubleValue)/2.0;
                NSUInteger xDistance = xCoordPos.unsignedIntegerValue - prevXPosition;
                xRunningLength += xDistance;
            }
            prevXPosition = xCoordPos.unsignedIntegerValue;
            iterationCounter++;
        } // end for-in loop of stacked x-sorted bands for the unique y-tolerance
        
    } // end For loop with y-tolerance unique regions
    
    
    // fullXYdescriptionRegions should now have all rectangle regions
    // BUT a LOT of overlapping rectangles for some reason!?!
    NSMutableArray *nonOverlapRects = [NSMutableArray array];
    NSMutableArray *superRectangles = [NSMutableArray array];
    for (NSArray *rectangle in fullXYdescriptionRegions) {
        NSNumber *xBegin = rectangle[0];
        NSNumber *yBegin = rectangle[1];
        NSNumber *xDist = rectangle[2];
        NSNumber *yDist = rectangle[3];
        NSUInteger x1 = xBegin.unsignedIntegerValue;
        NSUInteger y1 = yBegin.unsignedIntegerValue;
        NSUInteger x2 = xBegin.unsignedIntegerValue + xDist.unsignedIntegerValue;
        NSUInteger y2 = yBegin.unsignedIntegerValue + yDist.unsignedIntegerValue;
        if (nonOverlapRects.count == 0) {
            NSArray *uniqueRect = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:x1],[NSNumber numberWithUnsignedInteger:y1],[NSNumber numberWithUnsignedInteger:x2],[NSNumber numberWithUnsignedInteger:y2] , nil];
            [nonOverlapRects addObject:uniqueRect];
        }
        else {
            [superRectangles removeAllObjects];
            NSUInteger overlappingIndex = 0;
            BOOL foundOverlapping = NO;
            for (NSArray *greatRect in nonOverlapRects) {
                NSNumber *xA1 = greatRect[0];
                NSNumber *yA1 = greatRect[1];
                NSNumber *xA2 = greatRect[2];
                NSNumber *yA2 = greatRect[3];
                BOOL isOverlapping = [PixelLevelClassFunctions isRectangleAx1:xA1.unsignedIntegerValue Ay1:yA1.unsignedIntegerValue Ax2:xA2.unsignedIntegerValue Ay2:yA2.unsignedIntegerValue OverlappingRectangleBx1:x1 By1:y1 Bx2:x2 By2:y2];
                if (isOverlapping) {
                    // get new master dimensions
                    NSArray *xValues = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:x1], [NSNumber numberWithUnsignedInteger:x2], [NSNumber numberWithUnsignedInteger:xA1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:xA2.unsignedIntegerValue], nil];
                    NSArray *yValues = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:y1], [NSNumber numberWithUnsignedInteger:y2], [NSNumber numberWithUnsignedInteger:yA1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:yA2.unsignedIntegerValue], nil];
                    
                    // sort coordinate values
                    [xValues sortedArrayUsingDescriptors:sortAscDescripWrapper];
                    [yValues sortedArrayUsingDescriptors:sortAscDescripWrapper];
                    
                    NSNumber *superX1 = xValues.firstObject; // smallest
                    NSNumber *superX2 = xValues.lastObject; // largest
                    NSNumber *superY1 = yValues.firstObject;
                    NSNumber *superY2 = yValues.lastObject;
                    
                    NSArray *superRect = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:superX1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:superY1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:superX2.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:superY2.unsignedIntegerValue], nil];
                    
                    // add new superrectangle
                    [superRectangles addObject:superRect];
                    foundOverlapping = YES;
                    // stop search/loop and keep flag and index of inaccurate existing rectangle to remove
                    break;
                }
                
                overlappingIndex++;
            }// end for loop iterating nonOverlapRects
            
            for (NSUInteger i = 0; i < nonOverlapRects.count; i++) {
                NSArray *keepRect = nonOverlapRects[i];
                NSNumber *uX1 = keepRect[0];
                NSNumber *uY1 = keepRect[1];
                NSNumber *uX2 = keepRect[2];
                NSNumber *uY2 = keepRect[3];
                if (i != overlappingIndex || !foundOverlapping) {
                    NSArray *unique = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:uX1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:uY1.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:uX2.unsignedIntegerValue], [NSNumber numberWithUnsignedInteger:uY2.unsignedIntegerValue], nil];
                    [superRectangles addObject:unique];
                }
            } // end for loop copying over all non-overlapping other rectangles
            if (!foundOverlapping) {
                NSArray *unique2 = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:x1], [NSNumber numberWithUnsignedInteger:y1], [NSNumber numberWithUnsignedInteger:x2], [NSNumber numberWithUnsignedInteger:y2], nil];
                // store new verified unique rectangle
                [superRectangles addObject:unique2];
            }
            
            
            nonOverlapRects = [NSMutableArray arrayWithArray:superRectangles]; // for persistance, if superRectangles gets erased, nonOverlap loses new contents???
        } // end else for searching existing nonOverlapRects
    } // end for loop iterating fullXYdescriptionRegions
    
    regionDescriptions = [NSArray arrayWithArray:nonOverlapRects];
    return regionDescriptions;
}



+(BOOL) isRectangleAx1:(NSUInteger)xA1 Ay1:(NSUInteger)yA1 Ax2:(NSUInteger)xA2 Ay2:(NSUInteger)yA2 OverlappingRectangleBx1:(NSUInteger)xB1 By1:(NSUInteger)yB1 Bx2:(NSUInteger)xB2 By2:(NSUInteger)yB2 {
    
    // CASE: X-axis Component, Rectangle B is partially contained in Rectangle A
    if (xB1 >= xA1 && xB2 <= xA2 && (yB1 <= yA2 && yB2 >= yA1)) {
        return YES;
    }
    // CASE: X-axis Component, Rectangle A is partially contained in Rectangle B
    if (xA1 >= xB1 && xA2 <= xB2 && yA1 <= yB2 && yA2 >= yB1) {
        return YES;
    }
    // CASE: Y-axis Component, Rectangle B is partially contained in Rectangle A
    if (yB1 >= yA1 && yB2 <= yA2 && (xB1 <= xA2 && xB2 >= xA1)) {
        return YES;
    }
    // CASE: Y-axis Component, Rectangle A is partially contained in Rectangle B
    if (yA1 >= yB1 && yA2 <= yB2 && xA1 <= xB2 && xA2 >= xB1) {
        return YES;
    }
    return NO;
}


+(NSArray *) singleChannel:(ImageChannel)channel FilteredPixelsArrayOf:(UIImage *)image BelowThreshold:(double)threshold {
    
    NSArray *filteredChannelValues;
    
    CGImageRef inputCGimageRef = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    NSMutableArray *filteredPixelValues = [NSMutableArray arrayWithCapacity:(inputWidth * inputHeight)];
    
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return NULL;
    }
    CGContextRef inputImageContext; //= [ImagePixelLevelFunctions newConvertedRGBABitmapContext:inputCGimageRef];
    unsigned char *pixelInputData = malloc(bitmapTotalByteSizeInputImg); //(unsigned char *)CGBitmapContextGetData(inputImageContext); // ordering seemed off on channel access, this aligns better??
    if (pixelInputData == NULL) {
        NSLog(@"Error!! Single Channel Input Image Pixel Data pointer allocation failed!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return filteredChannelValues; // or NULL?
    }
    
    inputImageContext = CGBitmapContextCreate(pixelInputData, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (inputImageContext == NULL) {
        NSLog(@"Error!!! no context ref returned!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelInputData);
        return filteredChannelValues;
    }
    
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
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
        free(pixelInputData);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return filteredChannelValues;
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
        unsigned char channelValue = pixelInputData[byteIndex + indexByteChannelOffset];
        int input = (int)channelValue;
        NSUInteger filteredPixelIntensity = (((NSUInteger)threshold > input) ? 0 : input);
        [filteredPixelValues addObject:[NSNumber numberWithUnsignedInteger:filteredPixelIntensity]];
        
        byteIndex += BYTESPERPIXEL;
    }
    
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    free(pixelInputData);
    CGContextRelease(inputImageContext);
    
    filteredChannelValues = [NSArray arrayWithArray:filteredPixelValues];
    
    return filteredChannelValues;
}


+(NSArray *) baselineNearCornerPixelValuesOf:(UIImage *)image ForChannel:(ImageChannel)channel {
    // 50 by 50 pixel regions of 4 corners = 10000 points
    NSArray *baselinePixels;
    // but backgroundPixels ends up with 10201 recorded objects??
    NSMutableArray *backgroundPixels = [NSMutableArray arrayWithCapacity:10000];
    
    CGImageRef inputCGimageRef = [image CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger inputHeight = CGImageGetHeight(inputCGimageRef);
    NSUInteger bitmapBytesPerRowInputImg = inputWidth * BYTESPERPIXEL;
    NSUInteger bitmapTotalByteSizeInputImg = bitmapBytesPerRowInputImg * inputHeight;
    CGColorSpaceRef colorspaceStandardizedOutput = CGColorSpaceCreateDeviceRGB();
    if (colorspaceStandardizedOutput == NULL) {
        NSLog(@"ERROR! conversion Color Space NOT allocated.");
        return NULL;
    }
    
    CGContextRef inputImageContext;
    unsigned char *pixelInputData = malloc(bitmapTotalByteSizeInputImg); // ordering seemed off on channel access, this aligns better??
    if (pixelInputData == NULL) {
        NSLog(@"Error!! Single Channel Input Image Pixel Data pointer allocation failed!!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return baselinePixels; // or NULL
    }
    
    inputImageContext = CGBitmapContextCreate(pixelInputData, inputWidth, inputHeight, BITSPERCOMPONENT, bitmapBytesPerRowInputImg, colorspaceStandardizedOutput, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (inputImageContext == NULL) {
        NSLog(@"Error!!! no context ref returned!");
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        free(pixelInputData);
        return baselinePixels;
    }
    
    CGContextDrawImage(inputImageContext, CGRectMake(0, 0, inputWidth, inputHeight), inputCGimageRef);
    
    BOOL isBigEnd;
    CGBitmapInfo bitmapSettingsLittle = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Little;
    CGBitmapInfo bitmapSettingsBig = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
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
        free(pixelInputData);
        CGColorSpaceRelease(colorspaceStandardizedOutput);
        return baselinePixels;
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
    
    // ALTERNATIVELY could have collapsed all these memory accesses in same double for loop,
    // BUT, from loop unrolling/HPC that might be worse/slower since they are potentially vast different areas of memory and NOT sequential... definitely NOT as easily parallelizable at least
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(inputCGimageRef);
    for (NSUInteger j = 0; j < 50; j++) {
        for (NSUInteger i = 0; i < 50; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i);
            UInt32 intensity = pixelInputData[byteIndxRegion+indexByteChannelOffset];
            [backgroundPixels addObject:[NSNumber numberWithUnsignedInt:intensity]];
        }
    }
    // ASSUMING WIDTH = columns = i = Longest ~3200 = x coord, HEIGHT = Row/bytesPerRow = j = Shortest ~2400 = y coord
    NSUInteger startCorner2height = inputHeight - 50;
    NSUInteger startCorner3width = inputWidth - 50;
    for (NSUInteger j = (startCorner2height - 1); j < inputHeight; j++) {
        for (NSUInteger i = 0; i < 50; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i);
            UInt32 intensity = pixelInputData[byteIndxRegion+indexByteChannelOffset];
            [backgroundPixels addObject:[NSNumber numberWithUnsignedInt:intensity]];
        }
    }
    for (NSUInteger j = 0; j < 50; j++) {
        for (NSUInteger i = (startCorner3width - 1); i < inputWidth; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i);
            UInt32 intensity = pixelInputData[byteIndxRegion+indexByteChannelOffset];
            [backgroundPixels addObject:[NSNumber numberWithUnsignedInt:intensity]];
        }
    }
    for (NSUInteger j = (startCorner2height - 1); j < inputHeight; j++) {
        for (NSUInteger i = (startCorner3width - 1); i < inputWidth; i++) {
            NSUInteger byteIndxRegion = (bytesPerRow * j) + (BYTESPERPIXEL * i);
            UInt32 intensity = pixelInputData[byteIndxRegion+indexByteChannelOffset];
            [backgroundPixels addObject:[NSNumber numberWithUnsignedInt:intensity]];
        }
    }
    CGColorSpaceRelease(colorspaceStandardizedOutput);
    free(pixelInputData);
    CGContextRelease(inputImageContext);
    // problem here!? backgroundPixels has 10201 recorded objects??
    baselinePixels = [NSArray arrayWithArray:backgroundPixels];
    
    return baselinePixels;
}



+(double) calculateThresholdPixelValueForChannel: (ImageChannel)channel FromImage:(UIImage *)sourceCompositeImage {
    
    // sample outer edge regions to get a baseline for background intensity
    NSArray *backgroundPixelValues = [PixelLevelClassFunctions baselineNearCornerPixelValuesOf:sourceCompositeImage ForChannel:channel];
    // calculate mean, std dev for background to get threshold of mean + 3*stddev
    NSNumber *backgroundMean = [HelperMathClassFunctions averageFor:backgroundPixelValues];
    NSNumber *stdDev = [HelperMathClassFunctions standardDeviationFor:backgroundPixelValues];
    double threshold = backgroundMean.doubleValue + (stdDev.doubleValue * 3.0);
    return threshold;
}



@end
