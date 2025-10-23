//
//  ZHHDisablePopGestureController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDisablePopGestureController.h"
#import <Masonry/Masonry.h>

@interface ZHHDisablePopGestureController () 
@property (nonatomic, strong) UISwitch *edgePopSwitch;
@property (nonatomic, strong) UISwitch *fullscreenPopSwitch;
@property (nonatomic, strong) UISwitch *fullscreenModeSwitch;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UISlider *edgeDistanceSlider;
@property (nonatomic, strong) UILabel *edgeDistanceValueLabel;
@end

@implementation ZHHDisablePopGestureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"禁用侧滑返回";
    
    [self setupContent];
}

- (void)setupContent {
    // 说明标签
    [self addDescriptionLabel:@"通过开关来控制侧滑返回手势\n试试从屏幕边缘向右滑动"];
    
    CGFloat topOffset = self.currentY + 40;
    
    // 边缘侧滑开关
    self.edgePopSwitch = [self createSwitchRowWithTitle:@"禁用边缘侧滑返回"
                                              topOffset:topOffset
                                                 action:@selector(edgePopSwitchChanged:)];
    
    // 全屏侧滑开关
    self.fullscreenPopSwitch = [self createSwitchRowWithTitle:@"禁用全屏侧滑返回"
                                                    topOffset:topOffset + 60
                                                       action:@selector(fullscreenPopSwitchChanged:)];
    
    // 边缘触发距离滑块
    [self createEdgeDistanceSliderWithTopOffset:topOffset + 120];
    
    // 状态提示标签
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:14];
    self.statusLabel.textColor = [UIColor secondaryLabelColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(40);
        make.top.equalTo(self.view.mas_top).offset(topOffset + 240);
    }];
    
    // 测试提示卡片
    UIView *tipCard = [[UIView alloc] init];
    tipCard.backgroundColor = [UIColor.systemOrangeColor colorWithAlphaComponent:0.1];
    tipCard.layer.cornerRadius = 12;
    [self.view addSubview:tipCard];
    [tipCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(self.statusLabel.mas_bottom).offset(30);
    }];
    
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.text = @"💡 测试提示\n\n• 关闭开关后，从屏幕边缘向右滑动可返回\n• 打开「禁用边缘侧滑」后，边缘手势将失效\n• 打开「禁用全屏侧滑」后，全屏手势也将失效\n• 开启「全屏模式」可从屏幕任意位置触发返回\n• 关闭「全屏模式」后可调整具体触发距离（0-100pt）\n• 点击左上角返回按钮仍然有效";
    tipLabel.numberOfLines = 0;
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textColor = [UIColor.systemOrangeColor colorWithAlphaComponent:0.8];
    [tipCard addSubview:tipLabel];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tipCard).inset(16);
    }];
    
    // 更新状态显示
    [self updateStatusLabel];
}

- (UISwitch *)createSwitchRowWithTitle:(NSString *)title 
                             topOffset:(CGFloat)topOffset
                                action:(SEL)action {
    // 容器视图
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    containerView.layer.cornerRadius = 12;
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(self.view.mas_top).offset(topOffset);
        make.height.mas_equalTo(54);
    }];
    
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor labelColor];
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(16);
        make.centerY.equalTo(containerView);
    }];
    
    // 开关
    UISwitch *switchControl = [[UISwitch alloc] init];
    [switchControl addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:switchControl];
    [switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-16);
        make.centerY.equalTo(containerView);
    }];
    
    return switchControl;
}

- (void)createEdgeDistanceSliderWithTopOffset:(CGFloat)topOffset {
    // 容器视图
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    containerView.layer.cornerRadius = 12;
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(20);
        make.top.equalTo(self.view.mas_top).offset(topOffset);
        make.height.mas_equalTo(110);
    }];
    
    // 标题标签
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"边缘触发距离";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor labelColor];
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(16);
        make.top.equalTo(containerView).offset(12);
    }];
    
    // 当前值标签
    self.edgeDistanceValueLabel = [[UILabel alloc] init];
    self.edgeDistanceValueLabel.text = @"全屏";
    self.edgeDistanceValueLabel.font = [UIFont monospacedDigitSystemFontOfSize:15 weight:UIFontWeightMedium];
    self.edgeDistanceValueLabel.textColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.8];
    self.edgeDistanceValueLabel.textAlignment = NSTextAlignmentRight;
    [containerView addSubview:self.edgeDistanceValueLabel];
    [self.edgeDistanceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-16);
        make.top.equalTo(containerView).offset(12);
        make.width.mas_equalTo(70);
    }];
    
    // 全屏模式开关行
    UILabel *fullscreenLabel = [[UILabel alloc] init];
    fullscreenLabel.text = @"全屏模式";
    fullscreenLabel.font = [UIFont systemFontOfSize:14];
    fullscreenLabel.textColor = [UIColor secondaryLabelColor];
    [containerView addSubview:fullscreenLabel];
    [fullscreenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(16);
        make.top.equalTo(titleLabel.mas_bottom).offset(12);
    }];
    
    self.fullscreenModeSwitch = [[UISwitch alloc] init];
    self.fullscreenModeSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
    self.fullscreenModeSwitch.on = YES; // 默认开启全屏模式
    [self.fullscreenModeSwitch addTarget:self action:@selector(fullscreenModeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:self.fullscreenModeSwitch];
    [self.fullscreenModeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(containerView).offset(-16);
        make.centerY.equalTo(fullscreenLabel);
    }];
    
    // 滑块
    self.edgeDistanceSlider = [[UISlider alloc] init];
    self.edgeDistanceSlider.minimumValue = 0;
    self.edgeDistanceSlider.maximumValue = 100;
    self.edgeDistanceSlider.value = 30;
    self.edgeDistanceSlider.continuous = YES;
    self.edgeDistanceSlider.enabled = NO; // 默认禁用（因为全屏模式开启）
    self.edgeDistanceSlider.alpha = 0.5;
    [self.edgeDistanceSlider addTarget:self action:@selector(edgeDistanceSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:self.edgeDistanceSlider];
    [self.edgeDistanceSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView).offset(16);
        make.right.equalTo(containerView).offset(-16);
        make.bottom.equalTo(containerView).offset(-12);
    }];
    
    // 设置默认值为全屏（屏幕宽度）
    self.zhh_maxAllowedInitialX = [UIScreen mainScreen].bounds.size.width;
}

- (void)fullscreenModeSwitchChanged:(UISwitch *)sender {
    if (sender.isOn) {
        // 开启全屏模式
        self.edgeDistanceSlider.enabled = NO;
        self.edgeDistanceSlider.alpha = 0.5;
        self.edgeDistanceValueLabel.text = @"全屏";
        self.zhh_maxAllowedInitialX = [UIScreen mainScreen].bounds.size.width;
    } else {
        // 关闭全屏模式，使用滑块值
        self.edgeDistanceSlider.enabled = YES;
        self.edgeDistanceSlider.alpha = 1.0;
        NSInteger value = (NSInteger)self.edgeDistanceSlider.value;
        self.edgeDistanceValueLabel.text = [NSString stringWithFormat:@"%ld pt", (long)value];
        self.zhh_maxAllowedInitialX = value;
    }
    [self updateStatusLabel];
}

- (void)edgeDistanceSliderChanged:(UISlider *)slider {
    NSInteger value = (NSInteger)slider.value;
    self.edgeDistanceValueLabel.text = [NSString stringWithFormat:@"%ld pt", (long)value];
    self.zhh_maxAllowedInitialX = value;
    [self updateStatusLabel];
}

- (void)edgePopSwitchChanged:(UISwitch *)sender {
    self.zhh_disableEdgePopGesture = sender.isOn;
    [self updateStatusLabel];
    
    // 视觉反馈
    [self showFeedbackWithText:sender.isOn ? @"✓ 已禁用边缘侧滑" : @"✓ 已启用边缘侧滑"];
}

- (void)fullscreenPopSwitchChanged:(UISwitch *)sender {
    self.zhh_disableFullscreenPopGesture = sender.isOn;
    [self updateStatusLabel];
    
    // 视觉反馈
    [self showFeedbackWithText:sender.isOn ? @"✓ 已禁用全屏侧滑" : @"✓ 已启用全屏侧滑"];
}

- (void)updateStatusLabel {
    NSString *edgeStatus = self.edgePopSwitch.isOn ? @"❌ 禁用" : @"✅ 启用";
    NSString *fullscreenStatus = self.fullscreenPopSwitch.isOn ? @"❌ 禁用" : @"✅ 启用";
    
    NSString *distanceText;
    if (self.fullscreenModeSwitch.isOn) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        distanceText = [NSString stringWithFormat:@"全屏 (%.0f pt)", screenWidth];
    } else {
        NSInteger distance = (NSInteger)self.edgeDistanceSlider.value;
        distanceText = [NSString stringWithFormat:@"%ld pt", (long)distance];
    }
    
    self.statusLabel.text = [NSString stringWithFormat:@"当前状态\n边缘侧滑：%@  |  全屏侧滑：%@\n手势触发范围：%@", edgeStatus, fullscreenStatus, distanceText];
}

- (void)showFeedbackWithText:(NSString *)text {
    // 创建临时反馈标签
    UILabel *feedbackLabel = [[UILabel alloc] init];
    feedbackLabel.text = text;
    feedbackLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    feedbackLabel.textColor = [UIColor whiteColor];
    feedbackLabel.backgroundColor = [UIColor.systemGreenColor colorWithAlphaComponent:0.9];
    feedbackLabel.textAlignment = NSTextAlignmentCenter;
    feedbackLabel.layer.cornerRadius = 20;
    feedbackLabel.clipsToBounds = YES;
    feedbackLabel.alpha = 0;
    [self.view addSubview:feedbackLabel];
    
    [feedbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-50);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(40);
    }];
    
    // 动画显示并消失
    [UIView animateWithDuration:0.2 animations:^{
        feedbackLabel.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:1.0 options:0 animations:^{
            feedbackLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [feedbackLabel removeFromSuperview];
        }];
    }];
}

@end
