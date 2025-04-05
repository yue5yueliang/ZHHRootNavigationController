//
//  ZHHCommonViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHCommonViewController.h"

@interface ZHHCommonViewController ()

@end

@implementation ZHHCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = UIColor.systemBackgroundColor;
        bar.zhh_tintColor = UIColor.labelColor;
        bar.zhh_translucent = NO;
        bar.zhh_hideBottomLine = YES;
        bar.zhh_titleColor = [UIColor colorWithLightColor:UIColor.labelColor darkColor:UIColor.whiteColor];
    }];
}

- (UIBarButtonItem *)zhh_customBackBarButtonItemWithTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon_back_dark"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}
@end
