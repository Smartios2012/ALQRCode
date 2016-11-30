//
//  ALScanningQRCodeVC.h
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALScannerQRCodeVC : UIViewController

@property (nonatomic, copy) void(^scannerQRCodeDone)(NSString *result);

@end
