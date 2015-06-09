//
//  ViewController.m
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PixelLevelClassFunctions.h"

@interface ViewController ()

@property (nonatomic) UIImagePickerController *photosImagePickerController;

@property UIImage *originalGrayscaleLoaded;
@property NSArray *imageThresholdChannelData;
@property UIImage *thresholdedGrayscaleImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttonRestoreOriginal.enabled = NO;
    self.buttonThresholdStep.enabled = NO;
    self.buttonRectBandsStep.enabled = NO;
    self.buttonFinalBoundariesStep.enabled = NO;
    self.buttonSelectorCornerBackgroundSamples.enabled = NO;
    self.buttonDisplayFullThresholdedImage.enabled = NO;
    
    self.photosImagePickerController = [[UIImagePickerController alloc] init];
    self.photosImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.photosImagePickerController.allowsEditing = NO;
    self.photosImagePickerController.delegate = self;
    self.LabelBaselineThresholdValue.text = @"00";
}


- (IBAction)loadGrayscale:(id)sender {
 
    self.buttonRestoreOriginal.enabled = NO;
    self.buttonThresholdStep.enabled = NO;
    self.buttonRectBandsStep.enabled = NO;
    self.buttonFinalBoundariesStep.enabled = NO;
    
    self.photosImagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.photosImagePickerController animated:YES completion:nil];
}


- (IBAction)restoreBackOriginal:(id)sender {
    
    self.displayImageWindow.image = self.originalGrayscaleLoaded;
    self.buttonRectBandsStep.enabled = NO;
    self.buttonFinalBoundariesStep.enabled = NO;
    self.LabelBaselineThresholdValue.text = @"0";
    self.buttonDisplayFullThresholdedImage.enabled = NO;
    self.buttonSelectorCornerBackgroundSamples.enabled = NO;
    
}


- (IBAction)thresholdResultsStep:(id)sender {
    double thresholdCalculated = [PixelLevelClassFunctions calculateThresholdPixelValueForChannel:Green FromImage:self.displayImageWindow.image];
    self.LabelBaselineThresholdValue.text = [NSString stringWithFormat:@"%.1f", thresholdCalculated];
    
    NSArray *thresholdImageChannelData = [PixelLevelClassFunctions singleChannel:Green FilteredPixelsArrayOf:self.displayImageWindow.image BelowThreshold:thresholdCalculated];
    self.imageThresholdChannelData = thresholdImageChannelData;
    
    // YES: would ever the CGWidth be different from the UIWidth for the composited images
    NSUInteger imageWidthUI = self.displayImageWindow.image.size.width;
    NSUInteger imageHeightUI = self.displayImageWindow.image.size.height;
    CGImageRef inputCGimageRef = [self.displayImageWindow.image CGImage];
    NSUInteger imageWidth = CGImageGetWidth(inputCGimageRef);
    NSUInteger imageHeight = CGImageGetHeight(inputCGimageRef);
    NSLog(@"UIImage W=%lu,H=%lu",(unsigned long)imageWidthUI, (unsigned long)imageHeightUI);
    NSLog(@"CGImage W=%lu,H=%lu",(unsigned long)imageWidth, (unsigned long)imageHeight);
    
    UIImage *thresholdImage = [PixelLevelClassFunctions convertToImageFromArray:thresholdImageChannelData AndOriginalImageWidth:imageWidth AndImageHeight:imageHeight];
    self.displayImageWindow.image = thresholdImage;
    self.thresholdedGrayscaleImage = thresholdImage;
    
    self.buttonSelectorCornerBackgroundSamples.enabled = YES;
    self.buttonDisplayFullThresholdedImage.enabled = YES;
    
    self.buttonRectBandsStep.enabled = YES;
    
}


- (IBAction)displaySelectedBGSampleThresholdedCorner:(id)sender {
    
    //self.buttonRectBandsStep.enabled = NO;
    
}


- (IBAction)displayRestoredFullThresholdedImage:(id)sender {
    
    self.buttonSelectorCornerBackgroundSamples.enabled = YES;
    self.buttonRectBandsStep.enabled = YES;
    self.displayImageWindow.image = self.thresholdedGrayscaleImage;
}



- (IBAction)rectBandsResultsStep:(id)sender {
 
    self.displayImageWindow.image = self.thresholdedGrayscaleImage;
    self.buttonSelectorCornerBackgroundSamples.enabled = NO;
    
    // operations here
    
    self.buttonFinalBoundariesStep.enabled = YES;
}


- (IBAction)finalBoundariesResultsStep:(id)sender {
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.displayImageWindow.image = image;
        self.originalGrayscaleLoaded = [image copy];
        
        self.buttonRestoreOriginal.enabled = YES;
        self.buttonThresholdStep.enabled = YES;
        self.LabelBaselineThresholdValue.text = @"0";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
