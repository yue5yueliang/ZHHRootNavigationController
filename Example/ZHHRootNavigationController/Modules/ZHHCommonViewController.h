//
//  ZHHCommonViewController.h
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <ZHHAnneKit/ZHHAnneKit.h>
#import <ZHHRootNavigationController/ZHHRootNavigationController.h>

NS_ASSUME_NONNULL_BEGIN

/// 示例基类，提供通用的界面配置和跳转方法
@interface ZHHCommonViewController : UIViewController

/// 当前布局的Y坐标（子类可访问）
@property (nonatomic, assign) CGFloat currentY;

/// 便捷的跳转方法
- (void)pushViewControllerWithClass:(Class)vcClass title:(NSString *)title;

/// 添加一个按钮到视图中
- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action;

/// 添加说明文本
- (UILabel *)addDescriptionLabel:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
