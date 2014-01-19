//
//  ViewController.m
//  CodeScanner
//
//  Created by Hank Wang on 2014/1/20.
//  Copyright (c) 2014年 Company. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.session = [[AVCaptureSession alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (self.input) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"Error %@", error);
    }
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];
    
    [self.output setMetadataObjectTypes:[self.output availableMetadataObjectTypes]];
    
    self.preview =  [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    [self.preview setFrame:self.view.bounds];
    [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.view.layer addSublayer:self.preview];

    [self.session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    CGRect highlightViewRect = CGRectZero;
    
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                               AVMetadataObjectTypeCode39Code,
                               AVMetadataObjectTypeCode39Mod43Code,
                               AVMetadataObjectTypeEAN13Code,
                               AVMetadataObjectTypeEAN8Code,
                               AVMetadataObjectTypeCode93Code,
                               AVMetadataObjectTypeCode128Code,
                               AVMetadataObjectTypePDF417Code,
                               AVMetadataObjectTypeQRCode,
                               AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[self.preview transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
    }
    
    if (detectString != nil)
    {
        NSLog(@"%@", detectString);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
