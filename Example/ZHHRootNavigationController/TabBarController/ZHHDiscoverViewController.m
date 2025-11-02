//
//  ZHHDiscoverViewController.m
//  ZHHRootNavigationController
//
//  Created on 03/03/2025.
//

#import "ZHHDiscoverViewController.h"
#import <UINavigationController+ZHHInteractivePush.h>

@interface ZHHDiscoverViewController ()

@end

@implementation ZHHDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.97 blue:1.0 alpha:1.0];
    
    // 启用交互式推送（从右侧边缘左滑可触发 push）
//    self.navigationController.zhh_enableInteractivePush = YES;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"🔍 发现页面\n\n👈 向左滑动试试交互式推送";
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor grayColor];
    [self.view addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
}

/// 重写此方法，返回交互式推送的目标视图控制器
- (__kindof UIViewController *)zhh_nextPushViewController {
    // 从右侧边缘左滑时，推送到「普通导航栏」页面
    NSString *className = @"ZHHNormalViewController";
    Class cls = NSClassFromString(className);
    if (cls) {
        UIViewController *vc = [[cls alloc] init];
        vc.title = @"普通导航栏";
        return vc;
    }
    return nil;
}

@end

