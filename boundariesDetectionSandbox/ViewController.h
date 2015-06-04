//
//  ViewController.h
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonLoadGrayImage;
@property (weak, nonatomic) IBOutlet UIButton *buttonRestoreOriginal;
@property (weak, nonatomic) IBOutlet UIButton *buttonThresholdStep;
@property (weak, nonatomic) IBOutlet UIButton *buttonRectBandsStep;
@property (weak, nonatomic) IBOutlet UIButton *buttonFinalBoundariesStep;

@property (weak, nonatomic) IBOutlet UILabel *LabelBaselineThresholdValue;

@property (weak, nonatomic) IBOutlet UIImageView *displayImageWindow;

@end

