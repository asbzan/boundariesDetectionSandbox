//
//  HelperMathClassFunctions.h
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelperMathClassFunctions : NSObject

+ (NSArray *) approximateFirstDerivative: (NSArray *)input;
+ (NSArray *) approximateSecondDerivative: (NSArray *)input;
+ (NSNumber *) projectedYvalueForX: (NSNumber *)x FromMslope: (NSNumber *) slope andBintcpt: (NSNumber *) intercept;
+ (NSNumber *) linearRegressionMslopeValueFromX: (NSArray *) xVals andY: (NSArray *) yVals;
+ (NSNumber *) linearRegressionByintcptValueFromX: (NSArray *) xVals andY: (NSArray *) yVals andMslope: (NSNumber *) approxSlope;
+ (NSNumber *) standardDeviationFor: (NSArray *) numbers;
+ (NSNumber *) averageFor: (NSArray *) numbers;
+ (NSNumber *) maxFor: (NSArray *) numbers;
+ (NSNumber *) minFor: (NSArray *) numbers;
+ (NSNumber *) summationOfArray: (NSArray *) numbers;
+ (NSNumber *) summationOfSquaresArray: (NSArray *) numbers;
+ (NSNumber *) summationOfProductsTwoArrays: (NSArray *) source1 secondArray: (NSArray *) source2;

@end

