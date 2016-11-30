//
//  ALScanningQRCodeVC.m
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import "ALScannerQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "ALScannerQRCodeView.h"

@interface ALScannerQRCodeVC () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) ALScannerQRCodeView *scannerView;

@end

@implementation ALScannerQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_scannerView) {
        self.scannerView = [[ALScannerQRCodeView alloc] initWithFrame:self.view.bounds withLayer:self.view.layer];
        [self.view addSubview:self.scannerView];
    }
    [self.session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.session stopRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self _playSoundEffect:@"ALQRCode.bundle/sound.mp3"];
    [self.session stopRunning];
    NSString *result = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *readableCodeObject = [metadataObjects firstObject];
        NSLog(@"readableCodeObject = %@", readableCodeObject);
        result = readableCodeObject.stringValue;
    }
    if (self.scannerQRCodeDone) {
        self.scannerQRCodeDone(result);
    }
}

#pragma mark - Private Method
- (void)_setupViewController {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.rectOfInterest = CGRectMake(0, 0, 1, 1);
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)_playSoundEffect:(NSString *)name {
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (audioFile) {
        NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, _soundCompleteCallback, NULL);
        AudioServicesPlaySystemSound(soundID);
    }
}

void _soundCompleteCallback(SystemSoundID soundID,void *clientData){
    NSLog(@"播放完成...");
}

@end
