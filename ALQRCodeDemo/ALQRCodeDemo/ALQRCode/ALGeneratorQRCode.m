//
//  ALGeneratorQRCodeVC.m
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import "ALGeneratorQRCode.h"

static ALGeneratorQRCode *_generatorQRCode = nil;

@interface ALGeneratorQRCode ()

@end

@implementation ALGeneratorQRCode

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _generatorQRCode = [[ALGeneratorQRCode alloc] init];
    });
    return _generatorQRCode;
}

- (UIImage *)generateQRCode:(NSString *)sourceInfo {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *infoData = [sourceInfo dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    CIImage *outputImage = filter.outputImage;
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    return [UIImage imageWithCIImage:outputImage];
}

- (NSString *)findQRCodeFromImage:(UIImage *)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:nil
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    NSString *result = nil;
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features firstObject];
        result = feature.messageString;
    }
    return result;
}

@end
