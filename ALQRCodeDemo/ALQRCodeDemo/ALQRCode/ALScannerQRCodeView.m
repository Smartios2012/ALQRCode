//
//  ALScannerQRCodeView.m
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import "ALScannerQRCodeView.h"
#import <AVFoundation/AVFoundation.h>

#define scanContent_Y self.frame.size.height * 0.24
#define scanContent_X self.frame.size.width * 0.15

/** 扫描动画线(冲击波) 的高度 */
static CGFloat const animation_line_H = 12;
/** 扫描内容外部View的alpha值 */
static CGFloat const scanBorderOutsideViewAlpha = 0.4;

@interface ALScannerQRCodeView ()

@property (nonatomic, strong) CALayer *scannerLayer;
@property (nonatomic, strong) CALayer *lineLayer;
@property (nonatomic, strong) AVCaptureDevice *device;

@end

@implementation ALScannerQRCodeView

- (instancetype)initWithFrame:(CGRect)frame withLayer:(CALayer *)scannerLayer {
    if (self = [super initWithFrame:frame]) {
        _scannerLayer = scannerLayer;
        [self _setupView];
    }
    return self;
}

#pragma mark - Private Method
- (void)_setupView {
    // 扫描内容的创建
    UIView *scanContentView = [[UIView alloc] init];
    CGFloat scanContentViewX = scanContent_X;
    CGFloat scanContentViewY = scanContent_Y;
    CGFloat scanContentViewW = self.frame.size.width - 2 * scanContent_X;
    CGFloat scanContentViewH = scanContentViewW;
    scanContentView.frame = CGRectMake(scanContentViewX, scanContentViewY, scanContentViewW, scanContentViewH);
    scanContentView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    scanContentView.layer.borderWidth = 0.7;
    scanContentView.backgroundColor = [UIColor clearColor];
    [self.scannerLayer addSublayer:scanContentView.layer];
    
    self.lineLayer = [CALayer layer];
    self.lineLayer.contents = (id)[UIImage imageNamed:@"ALQRCode.bundle/icon_line"].CGImage;
    self.lineLayer.frame = CGRectMake(scanContent_X * 0.5, scanContentViewY, self.frame.size.width - scanContent_X , animation_line_H);
    [self.layer addSublayer:self.lineLayer];
    [self resumeAnimation];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAnimation) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
#pragma mark - - - 扫描外部View的创建
    // 顶部View的创建
    UIView *top_View = [[UIView alloc] init];
    CGFloat top_ViewX = 0;
    CGFloat top_ViewY = 0;
    CGFloat top_ViewW = self.frame.size.width;
    CGFloat top_ViewH = scanContentViewY;
    top_View.frame = CGRectMake(top_ViewX, top_ViewY, top_ViewW, top_ViewH);
    top_View.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:top_View];
    
    // 左侧View的创建
    UIView *left_View = [[UIView alloc] init];
    CGFloat left_ViewX = 0;
    CGFloat left_ViewY = scanContentViewY;
    CGFloat left_ViewW = scanContent_X;
    CGFloat left_ViewH = scanContentViewH;
    left_View.frame = CGRectMake(left_ViewX, left_ViewY, left_ViewW, left_ViewH);
    left_View.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:left_View];
    
    // 右侧View的创建
    UIView *right_View = [[UIView alloc] init];
    CGFloat right_ViewX = CGRectGetMaxX(scanContentView.frame);
    CGFloat right_ViewY = scanContentViewY;
    CGFloat right_ViewW = scanContent_X;
    CGFloat right_ViewH = scanContentViewH;
    right_View.frame = CGRectMake(right_ViewX, right_ViewY, right_ViewW, right_ViewH);
    right_View.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:right_View];
    
    // 下面View的创建
    UIView *bottom_View = [[UIView alloc] init];
    CGFloat bottom_ViewX = 0;
    CGFloat bottom_ViewY = CGRectGetMaxY(scanContentView.frame);
    CGFloat bottom_ViewW = self.frame.size.width;
    CGFloat bottom_ViewH = self.frame.size.height - bottom_ViewY;
    bottom_View.frame = CGRectMake(bottom_ViewX, bottom_ViewY, bottom_ViewW, bottom_ViewH);
    bottom_View.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:bottom_View];
    
    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = scanContent_X * 0.5;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 25;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
    [bottom_View addSubview:promptLabel];
    
    // 添加闪光灯按钮
    UIButton *light_button = [[UIButton alloc] init];
    CGFloat light_buttonX = 0;
    CGFloat light_buttonY = CGRectGetMaxY(promptLabel.frame) + scanContent_X * 0.5;
    CGFloat light_buttonW = self.frame.size.width;
    CGFloat light_buttonH = 25;
    light_button.frame = CGRectMake(light_buttonX, light_buttonY, light_buttonW, light_buttonH);
    [light_button setTitle:@"打开照明灯" forState:UIControlStateNormal];
    [light_button setTitle:@"关闭照明灯" forState:UIControlStateSelected];
    [light_button setTitleColor:promptLabel.textColor forState:(UIControlStateNormal)];
    light_button.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottom_View addSubview:light_button];
    
#pragma mark - - - 扫描边角imageView的创建
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"ALQRCode.bundle/icon_top_left"];
    UIImageView *left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(scanContentView.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(scanContentView.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX, left_imageViewY, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    [self.scannerLayer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"ALQRCode.bundle/icon_top_right"];
    UIImageView *right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(scanContentView.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    [self.scannerLayer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"ALQRCode.bundle/icon_bottom_left"];
    UIImageView *left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(scanContentView.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    [self.scannerLayer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"ALQRCode.bundle/icon_bottom_right"];
    UIImageView *right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    [self.scannerLayer addSublayer:right_imageView_down.layer];
}

#pragma mark - - - 照明灯的点击事件
- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) { // 点击打开照明灯
        [self turnOnLight:YES];
        button.selected = YES;
    } else { // 点击关闭照明灯
        [self turnOnLight:NO];
        button.selected = NO;
    }
}

- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}

- (void)stopAnimation {
    [self.lineLayer removeAnimationForKey:@"translationY"];
}

- (void)resumeAnimation {
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    basic.fromValue = @(0);
    basic.toValue = @(self.frame.size.width - 2 * scanContent_X);
    basic.duration = 2.0;
    basic.repeatCount = NSIntegerMax;
    [self.lineLayer addAnimation:basic forKey:@"translationY"];
}

@end
