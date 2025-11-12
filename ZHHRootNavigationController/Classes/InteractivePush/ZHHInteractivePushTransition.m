//
//  ZHHInteractivePushTransition.m
//  ZHHRootNavigationController
//
//  Created by 桃色三岁 on 2024/9/19.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import "ZHHInteractivePushTransition.h"

@implementation ZHHInteractivePushTransition

- (CGFloat)completionSpeed {
    // 根据当前进度动态调整完成速度，让动画更自然
    CGFloat progress = self.percentComplete;
    
    if (progress <= 0.0) {
        return 1.0; // 默认速度
    }
    
    // 计算剩余进度
    CGFloat remainingProgress = 1.0 - progress;
    
    // 根据剩余进度调整速度
    // 剩余进度越小（越接近完成），速度越快，让动画快速结束
    // 剩余进度越大（刚开始），速度适中，让动画平滑
    if (remainingProgress > 0.7) {
        // 剩余很多，使用较慢速度（取消情况）
        return 0.4;
    } else if (remainingProgress > 0.3) {
        // 剩余中等，使用中等速度
        return 0.7;
    } else {
        // 剩余很少，使用较快速度（完成情况）
        return 1.0;
    }
}

- (UIViewAnimationCurve)completionCurve {
    // 使用 EaseOut 曲线，让动画结束时更自然平滑
    // EaseOut 会让动画开始快，结束慢，符合物理直觉
    return UIViewAnimationCurveEaseOut;
}

@end

