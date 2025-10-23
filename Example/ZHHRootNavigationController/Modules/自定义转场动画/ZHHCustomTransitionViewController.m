//
//  ZHHCustomTransitionViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHCustomTransitionViewController.h"
#import "ZHHFadeTransition.h"
#import "ZHHScaleTransition.h"
#import "ZHHFlipTransition.h"

typedef NS_ENUM(NSInteger, ZHHTransitionType) {
    ZHHTransitionTypeNone = 0,
    ZHHTransitionTypeFade,
    ZHHTransitionTypeScale,
    ZHHTransitionTypeFlip
};

@interface ZHHCustomTransitionViewController ()
@property (nonatomic, assign) ZHHTransitionType transitionType;
@end

@implementation ZHHCustomTransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"自定义转场动画";
    
    // 如果没有设置转场类型，使用随机颜色
    if (self.transitionType != ZHHTransitionTypeNone) {
        self.view.backgroundColor = UIColor.zhh_randomColor;
    } else {
        self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.97 alpha:1.0];
    }
    
    [self addDescriptionLabel:@"点击下面的按钮体验不同的转场动画效果\n每次进入都会显示随机颜色"];
    
    // 创建按钮并绑定对应的转场类型
    UIButton *fadeBtn = [self addButtonWithTitle:@"淡入淡出动画" action:@selector(pushWithFadeTransition)];
    fadeBtn.tag = ZHHTransitionTypeFade;
    
    UIButton *scaleBtn = [self addButtonWithTitle:@"缩放动画" action:@selector(pushWithScaleTransition)];
    scaleBtn.tag = ZHHTransitionTypeScale;
    
    UIButton *flipBtn = [self addButtonWithTitle:@"翻转动画" action:@selector(pushWithFlipTransition)];
    flipBtn.tag = ZHHTransitionTypeFlip;
}

#pragma mark - Private Methods

- (void)pushWithTransitionType:(ZHHTransitionType)type title:(NSString *)title {
    ZHHCustomTransitionViewController *vc = [[ZHHCustomTransitionViewController alloc] init];
    vc.transitionType = type;
    vc.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions

- (void)pushWithFadeTransition {
    [self pushWithTransitionType:ZHHTransitionTypeFade title:@"淡入淡出"];
}

- (void)pushWithScaleTransition {
    [self pushWithTransitionType:ZHHTransitionTypeScale title:@"缩放动画"];
}

- (void)pushWithFlipTransition {
    [self pushWithTransitionType:ZHHTransitionTypeFlip title:@"翻转动画"];
}

// 返回自定义的转场动画
- (id<UIViewControllerAnimatedTransitioning>)zhh_animatedTransitioning {
    switch (self.transitionType) {
        case ZHHTransitionTypeFade:
            return [[ZHHFadeTransition alloc] init];
        case ZHHTransitionTypeScale:
            return [[ZHHScaleTransition alloc] init];
        case ZHHTransitionTypeFlip:
            return [[ZHHFlipTransition alloc] init];
        default:
            return nil; // 使用系统默认动画
    }
}

@end

