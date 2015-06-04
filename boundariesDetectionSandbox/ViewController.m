//
//  ViewController.m
//  boundariesDetectionSandbox
//
//  Created by Alex on 6/1/15.
//  Copyright (c) 2015 asb. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface ViewController ()

@property (nonatomic) UIImagePickerController *photosImagePickerController;

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
 
    self.photosImagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.photosImagePickerController animated:YES completion:nil];
}


- (IBAction)restoreBackOriginal:(id)sender {
    
}


- (IBAction)thresholdResultsStep:(id)sender {
    
}


- (IBAction)rectBandsResultsStep:(id)sender {
    
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
        
        self.buttonRestoreOriginal.enabled = YES;
        self.buttonThresholdStep.enabled = YES;
        self.buttonRectBandsStep.enabled = YES;
        self.buttonFinalBoundariesStep.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
