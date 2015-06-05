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
    
    self.photosImagePickerController = [[UIImagePickerController alloc] init];
    self.photosImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.photosImagePickerController.allowsEditing = NO;
    self.photosImagePickerController.delegate = self;
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
    
}


- (IBAction)thresholdResultsStep:(id)sender {
    double thresholdCalculated = [PixelLevelClassFunctions calculateThresholdPixelValueForChannel:Green FromImage:self.displayImageWindow.image];
    self.LabelBaselineThresholdValue.text = [NSString stringWithFormat:@"%.1f", thresholdCalculated];
    
    NSArray *thresholdImageChannelData = [PixelLevelClassFunctions singleChannel:Green FilteredPixelsArrayOf:self.displayImageWindow.image BelowThreshold:thresholdCalculated];
    self.imageThresholdChannelData = thresholdImageChannelData;
    
    // would ever the CGWidth be different from the UIWidth for the composited images?
    NSUInteger imageWidth = self.displayImageWindow.image.size.width;
    NSUInteger imageHeight = self.displayImageWindow.image.size.height;
    NSLog(@"UIImage W=%lu,H=%lu",(unsigned long)imageWidth, (unsigned long)imageHeight);
    
    UIImage *thresholdImage = [PixelLevelClassFunctions convertToImageFromArray:thresholdImageChannelData AndOriginalImageWidth:imageWidth AndImageHeight:imageHeight];
    self.displayImageWindow.image = thresholdImage;
    self.thresholdedGrayscaleImage = thresholdImage;
    self.buttonRectBandsStep.enabled = YES;
    //enable corners thumbnail inspection
}


- (IBAction)rectBandsResultsStep:(id)sender {
 
    self.displayImageWindow.image = self.thresholdedGrayscaleImage;
    //disable corners thumbnail inspection
    
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
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
