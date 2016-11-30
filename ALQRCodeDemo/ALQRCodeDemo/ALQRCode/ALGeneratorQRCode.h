//
//  ALGeneratorQRCodeVC.h
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALGeneratorQRCode : NSObject

+ (instancetype)shareInstance;
- (UIImage *)generateQRCode:(NSString *)sourceInfo;
- (NSString *)findQRCodeFromImage:(UIImage *)image;

@end
