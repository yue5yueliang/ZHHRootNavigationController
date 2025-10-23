//
//  ZHHCustomNavigationBar.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHCustomNavigationBar.h"

@interface ZHHCustomNavigationBar ()
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation ZHHCustomNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGradient];
    }
    return self;
}

- (void)setupGradient {
    // 创建渐变层
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[
        (id)[UIColor colorWithRed:0.4 green:0.6 blue:1.0 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.6 green:0.4 blue:1.0 alpha:1.0].CGColor
    ];
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 1);
    
    // 插入到最底层
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
    
    // 设置导航栏为半透明，这样渐变层才能显示
    self.translucent = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 更新渐变层的大小
    self.gradientLayer.frame = self.bounds;
}

@end

