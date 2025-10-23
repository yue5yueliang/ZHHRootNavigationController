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
    self.currentY = 20; // 初始Y坐标
    
    // 配置导航栏默认样式
    [self.navigationController.navigationBar zhh_configureWithBlock:^(UINavigationBar *bar) {
        bar.zhh_backgroundColor = UIColor.systemBackgroundColor;
        bar.zhh_tintColor = UIColor.labelColor;
        bar.zhh_translucent = NO;
        bar.zhh_hideBottomLine = YES;
        bar.zhh_titleColor = [UIColor colorWithLightColor:UIColor.labelColor darkColor:UIColor.whiteColor];
    }];
}

#pragma mark - 自定义返回按钮

- (UIBarButtonItem *)zhh_customBackBarButtonItemWithTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon_back_dark"] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

#pragma mark - 便捷方法

- (void)pushViewControllerWithClass:(Class)vcClass title:(NSString *)title {
    if (![vcClass isSubclassOfClass:[UIViewController class]]) {
        NSLog(@"⚠️ %@ 不是 UIViewController 的子类", NSStringFromClass(vcClass));
        return;
    }
    
    UIViewController *vc = [[vcClass alloc] init];
    if (title.length > 0) {
        vc.title = title;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    button.layer.cornerRadius = 8;
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(self.currentY);
        make.height.mas_equalTo(50);
    }];
    
    self.currentY += 70; // 更新Y坐标
    return button;
}

- (UILabel *)addDescriptionLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor secondaryLabelColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(self.currentY);
    }];
    
    self.currentY += 60; // 更新Y坐标
    return label;
}

@end
