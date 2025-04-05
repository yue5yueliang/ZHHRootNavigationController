//
//  ZHHNormalViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 136769890@qq.com. All rights reserved.
//

#import "ZHHNormalViewController.h"

@interface ZHHNormalViewController ()

@end

@implementation ZHHNormalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Test VC";
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationController.navigationBar.zhh_hideBottomLine = NO;
//    self.navigationController.navigationBar.zhh_titleColor = UIColor.zhh_randomColor;
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

@end
