//
//  ViewController.m
//  ALQRCodeDemo
//
//  Created by DHF on 2016/11/11.
//  Copyright © 2016年 MZ. All rights reserved.
//

#import "ViewController.h"
#import "ALScannerQRCodeVC.h"
#import "ALGeneratorQRCode.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *codeIV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)scanningAction:(id)sender {
    ALScannerQRCodeVC *vc =[[ALScannerQRCodeVC alloc] init];
    vc.scannerQRCodeDone = ^(NSString *result) {
        UIViewController *vc2 = [[UIViewController alloc] init];
        vc2.view.backgroundColor = [UIColor greenColor];
        vc2.title = result;
        [self.navigationController pushViewController:vc2 animated:YES];
        NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
        for (UIViewController *vc3 in self.navigationController.viewControllers) {
            if ([vc3 isKindOfClass:[ALScannerQRCodeVC class]]) {
                [array removeObject:vc3];
                break;
            }
        }
        self.navigationController.viewControllers = array;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)generateAction:(id)sender {
    self.codeIV.image = [[ALGeneratorQRCode shareInstance] generateQRCode:@"hello QRCode"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
