//
//  HelperMathClassFunctions.m
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import "HelperMathClassFunctions.h"

@implementation HelperMathClassFunctions



/* using 9 point stencil approx, f'(x) ~= ( ( 3f(x-4h)-32f(x-3h)+168f(x-2h)-672f(x-h)+0f(x)+672f(x+h)-168f(x+2h)+32f(x+3h)-3f(x+4h) ) / 840h)
 where h=1  */

+(NSArray *) approximateFirstDerivative: (NSArray *)input {
    
    NSArray *firstDeriv;
    NSMutableArray *runningCalc = [NSMutableArray array];
    int stenden1 = 840;
    int d_sten = (9-1)/2;
    NSArray *stencilCoefficients = [NSArray arrayWithObjects:@3, @-32, @168, @-672, @0, @672, @-168, @32, @-3, nil];
    
    // figure out how to potentially transform the initial, end points
    for (int i = 0; i < d_sten; i++) {
        //NSNumber *val = input[i];
        //[runningCalc addObject:val];
        [runningCalc addObject:@0];
    }
    int derivPositionBound = (int)input.count - d_sten;
    for (int j = d_sten; j < derivPositionBound; j++) {
        double sum = 0;
        for (int k = -d_sten; k < (d_sten + 1); k++) {
            NSNumber *value = input[j+k];
            NSNumber *coeff = stencilCoefficients[k+d_sten];
            double prod = value.doubleValue * coeff.floatValue;
            sum += prod;
        }
        double deriv = sum / (double)stenden1;
        // matlab code doesn't seem to contaminate new replaced values in calculations, but
        // double check to see if formula does require
        [runningCalc addObject:[NSNumber numberWithDouble:deriv]];
    }
    int arrayBound = (int)input.count;
    for (int i = derivPositionBound; i < arrayBound; i++) {
        //NSNumber *val = input[i];
        //[runningCalc addObject:val];
        [runningCalc addObject:@0];
    }
    // the N value (from prev Gaussian calc) doesn't appear to belong; also the d_i value (from 9 pt Gauss) is equiv to d_sten
    // xder_vec = N*d_i + d_sten + [1:length(der1_vec)]; %Corresponding x-positions for 1st and 2nd derivative calculations
    firstDeriv = [NSArray arrayWithArray:runningCalc];
    return firstDeriv;
}



/* using 9 point stencil approx, f"(x) ~= ( ( -9f(x-4h)+128f(x-3h)-1008f(x-2h)+8064f(x-h)-14350f(x)+8064f(x+h)-1008f(x+2h)+128f(x+3h)-9f(x+4h) ) / 840h)
 where h=1  */

+(NSArray *) approximateSecondDerivative: (NSArray *)input {
    
    NSArray *secondDeriv;
    int stenden2 = 5040;
    int d_sten = (9-1)/2;
    NSMutableArray *runningCalc = [NSMutableArray array];
    
    NSArray *stencilCoefficients = [NSArray arrayWithObjects:@-9, @128, @-1008, @8064, @-14350, @8064, @-1008, @128, @-9, nil];
    
    // figure out how to potentially transform the initial points
    for (int i = 0; i < d_sten; i++) {
        //NSNumber *val = input[i];
        //[runningCalc addObject:val];
        [runningCalc addObject:@0];
    }
    int derivPositionBound = (int)input.count - d_sten;
    for (int j = d_sten; j < derivPositionBound; j++) {
        double sum = 0;
        for (int k = -d_sten; k < (d_sten + 1); k++) {
            NSNumber *value = input[j+k];
            NSNumber *coeff = stencilCoefficients[k+d_sten];
            double prod = value.doubleValue * coeff.floatValue;
            sum += prod;
        }
        double deriv = sum / (double)stenden2;
        // matlab code doesn't seem to contaminate new replaced values in calculations, but
        // double check to see if formula does require
        [runningCalc addObject:[NSNumber numberWithDouble:deriv]];
    }
    // figure out how to potentially transform the end points
    int arrayBound = (int)input.count;
    for (int i = derivPositionBound; i < arrayBound; i++) {
        //NSNumber *val = input[i];
        //[runningCalc addObject:val];
        [runningCalc addObject:@0];
    }
    // the N value (from prev Gaussian calc) doesn't appear to belong; also the d_i value (from 9 pt Gauss) is equiv to d_sten
    // xder_vec = N*d_i + d_sten + [1:length(der1_vec)]; %Corresponding x-positions for 1st and 2nd derivative calculations
    secondDeriv = [NSArray arrayWithArray:runningCalc];
    
    return secondDeriv;
}



+ (NSNumber *) projectedYvalueForX: (NSNumber *)x FromMslope: (NSNumber *) slope andBintcpt: (NSNumber *) intercept {
    NSNumber *y = @0;
    double expectedY = ([slope doubleValue] * [x doubleValue]) + [intercept doubleValue];
    y = [NSNumber numberWithDouble:expectedY];
    return y;
}



// from the formula: m = ((Sum(xy)/N)-((Sum(x)/N)*(Sum(y)/N)))/((Sum(x^2)/N)-((Sum(x)/N)^2))

+ (NSNumber *) linearRegressionMslopeValueFromX: (NSArray *) xVals andY: (NSArray *) yVals {
    NSNumber *slope = @0;
    if (xVals.count == yVals.count) {
        NSNumber *summationX = [self summationOfArray:xVals];
        NSNumber *summationY = [self summationOfArray:yVals];
        NSNumber *summationXsqd = [self summationOfSquaresArray:xVals];
        //NSNumber *summationYsqd = [self summationOfSquaresArray:yVals];
        NSNumber *summationXY = [self summationOfProductsTwoArrays:xVals secondArray:yVals];
        double countN = yVals.count;
        double countNinverse = 1 / countN;
        double xySampleAvg = countNinverse * [summationXY doubleValue];
        double xSampleAvg = countNinverse * [summationX doubleValue];
        double ySampleAvg = countNinverse * [summationY doubleValue];
        double x2SampleAvg = countNinverse * [summationXsqd doubleValue];
        double numerator = xySampleAvg - (xSampleAvg * ySampleAvg);
        double denominator = x2SampleAvg - (xSampleAvg * xSampleAvg);
        double slopeBapproxM = numerator / denominator;
        slope = [NSNumber numberWithDouble:slopeBapproxM];
    }
    else {
        NSLog(@"Error!! input arrays are different lengths!");
    }
    return slope;
}



// from the formula: b = (Sum(y)/N) - (m*(Sum(x)/N))

+ (NSNumber *) linearRegressionByintcptValueFromX: (NSArray *) xVals andY: (NSArray *) yVals andMslope: (NSNumber *) approxSlope{
    NSNumber *yintcpt = @0;
    if (xVals.count == yVals.count) {
        double inverseCountN = 1.0 / xVals.count;
        NSNumber *summationX = [self summationOfArray:xVals];
        NSNumber *summationY = [self summationOfArray:yVals];
        double yintcptAapproxB = (inverseCountN * [summationY doubleValue]) - (inverseCountN * [approxSlope doubleValue] * [summationX doubleValue]);
        yintcpt = [NSNumber numberWithDouble:yintcptAapproxB];
    }
    else {
        NSLog(@"Error!! input arrays are different lengths!");
    }
    return yintcpt;
}



+ (NSNumber *) standardDeviationFor: (NSArray *) numbers {
    NSNumber *sd = @0;
    NSNumber *average = [self averageFor:numbers];
    double runningSum = 0;
    for (NSUInteger i = 0; i < numbers.count; i++) {
        NSNumber *val = numbers[i];
        double difference = [val doubleValue] - [average doubleValue];
        runningSum += (difference * difference);
    }
    double variance = runningSum / (double)numbers.count;
    double stanDev = sqrt(variance);
    sd = [NSNumber numberWithDouble:stanDev];
    return sd;
}



+ (NSNumber *) averageFor: (NSArray *) numbers {
    NSNumber *average = @0;
    double runningSum = 0;
    for (NSUInteger i=0; i < numbers.count; i++) {
        NSNumber *value = numbers[i];
        runningSum += [value doubleValue];
    }
    double avg = runningSum / (double)numbers.count;
    average = [NSNumber numberWithDouble:avg];
    return average;
}



+ (NSNumber *) maxFor: (NSArray *) numbers {
    NSNumber *max = @0;
    double greatest = 0;
    for (NSUInteger i=0; i < numbers.count; i++) {
        NSNumber *entry = numbers[i];
        if ([entry doubleValue] > greatest) {
            greatest = [entry doubleValue];
        }
    }
    max = [NSNumber numberWithDouble:greatest];
    return max;
}



+ (NSNumber *) minFor: (NSArray *) numbers {
    double least = MAXFLOAT;
    NSNumber *min = [NSNumber numberWithDouble:least];
    for (NSUInteger i=0; i < numbers.count; i++) {
        NSNumber *entry = numbers[i];
        if ([entry doubleValue] < least) {
            least = [entry doubleValue];
        }
    }
    min = [NSNumber numberWithDouble:least];
    return min;
}



+ (NSNumber *) summationOfArray: (NSArray *) numbers {
    NSNumber *sum = [NSNumber numberWithDouble:0];
    double runSum = 0;
    for (NSUInteger i = 0; i < numbers.count; i++) {
        NSNumber *value = numbers[i];
        runSum += [value doubleValue];
    }
    sum = [NSNumber numberWithDouble:runSum];
    return sum;
}



+ (NSNumber *) summationOfSquaresArray: (NSArray *) numbers {
    NSNumber *sum = @0;
    double runSum = 0;
    for (NSUInteger i = 0; i < numbers.count; i++) {
        NSNumber *value = numbers[i];
        runSum += ([value doubleValue] * [value doubleValue]);
    }
    sum = [NSNumber numberWithDouble:runSum];
    return sum;
}



+ (NSNumber *) summationOfProductsTwoArrays: (NSArray *) source1 secondArray: (NSArray *) source2 {
    NSNumber *sum = @0;
    if (source1.count == source2.count) {
        double runSum = 0;
        for (NSUInteger i=0; i < source1.count; i++) {
            NSNumber *value1 = source1[i];
            NSNumber *value2 = source2[i];
            runSum += ([value1 doubleValue] * [value2 doubleValue]);
        }
        sum = [NSNumber numberWithDouble:runSum];
    }
    
    return sum;
}



@end

