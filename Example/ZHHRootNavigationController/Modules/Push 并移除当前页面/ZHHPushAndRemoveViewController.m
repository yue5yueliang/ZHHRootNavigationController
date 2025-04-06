//
//  ZHHPushAndRemoveViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/7.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHPushAndRemoveViewController.h"
#import "ZHHViewController.h"

@interface ZHHPushAndRemoveViewController ()
@property (nonatomic, strong) UISwitch *animatedSwitch;
@end

@implementation ZHHPushAndRemoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.animatedSwitch = [self zhh_switchWithOn:YES target:self action:@selector(switchChanged:)];
    [self.view addSubview:self.animatedSwitch];
    self.animatedSwitch.frame = CGRectMake(100, 100, 60, 30); // 根据需要布局
    
    UIButton *loginBtn = [self zhh_buttonWithTitle:@"登录"
                                              font:[UIFont boldSystemFontOfSize:16]
                                         textColor:[UIColor whiteColor]
                                   backgroundColor:[UIColor systemBlueColor]
                                            target:self
                                            action:@selector(loginBtnClicked:)];
    [self.view addSubview:loginBtn];
    loginBtn.frame = CGRectMake(50, 200, 200, 44);
    loginBtn.layer.cornerRadius = 8;
    loginBtn.clipsToBounds = YES;
}

- (void)switchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        NSLog(@"开关已打开");
    } else {
        NSLog(@"开关已关闭");
    }
}

- (void)loginBtnClicked:(UIButton *)sender {
    NSLog(@"登录按钮被点击");
    [self.zhh_navigationController pushViewController:[[ZHHViewController alloc] init]
                                            animated:self.animatedSwitch.on
                                            complete:^(BOOL finished) {
                                                [self.zhh_navigationController removeViewController:self];
                                            }];
}

- (UISwitch *)zhh_switchWithOn:(BOOL)isOn target:(id)target action:(SEL)action {
    UISwitch *uiSwitch = [[UISwitch alloc] init];
    uiSwitch.on = isOn;
    [uiSwitch addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    return uiSwitch;
}

- (UIButton *)zhh_buttonWithTitle:(NSString *)title
                             font:(UIFont *)font
                        textColor:(UIColor *)textColor
                    backgroundColor:(UIColor *)backgroundColor
                            target:(id)target
                            action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:textColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    button.backgroundColor = backgroundColor;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
