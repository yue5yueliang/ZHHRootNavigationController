//
//  ZHHGradientNavBarViewController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/3/3.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHGradientNavBarViewController.h"

@interface ZHHGradientNavBarViewController ()
@end

@implementation ZHHGradientNavBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"渐变导航栏";
    self.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:1.0 alpha:1.0];
    
    [self setupContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 每次显示时设置渐变导航栏
    [self setupGradientNavigationBar];
}

- (void)setupGradientNavigationBar {
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    // 获取状态栏高度
    UIWindowScene *windowScene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
    CGFloat statusBarHeight = windowScene.statusBarManager.statusBarFrame.size.height;
    
    // 计算完整高度：状态栏 + 导航栏
    CGFloat navBarHeight = navBar.bounds.size.height;
    CGFloat totalHeight = statusBarHeight + navBarHeight;
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    
    // 使用 ZHHAnneKit 创建不带圆角的渐变图片（从左到右）
    UIImage *gradientImage = [UIColor zhh_gradientImageWithColors:@[
        [UIColor zhh_colorWithHexString:@"#FF6699"],  // 粉色
        [UIColor zhh_colorWithHexString:@"#9966FF"]   // 紫色
    ] size:CGSizeMake(width, totalHeight)
                                                        direction:ZHHGradientDirectionTypeLeftToRight];
    
    // 使用 UINavigationBarAppearance 设置导航栏外观
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    
    // 设置渐变背景图片
    appearance.backgroundImage = gradientImage;
    
    // 设置标题样式为白色
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: UIColor.whiteColor,
        NSFontAttributeName: [UIFont boldSystemFontOfSize:17]
    };
    
    // 移除底部阴影线
    appearance.shadowImage = [[UIImage alloc] init];
    appearance.shadowColor = nil;
    
    // 设置导航栏按钮颜色为白色
    navBar.tintColor = UIColor.whiteColor;
    
    // 应用外观到标准状态和滚动边缘状态
    navBar.standardAppearance = appearance;
    navBar.scrollEdgeAppearance = appearance;
    navBar.compactAppearance = appearance;
    
    // 保持半透明以避免布局偏移（appearance 已经是不透明的）
    navBar.translucent = YES;
}

- (void)setupContent {
    [self addDescriptionLabel:@"这个示例展示了如何在不使用自定义导航栏类的情况下\n为导航栏添加渐变效果"];
    
    UIButton *btn = [self addButtonWithTitle:@"Push到下一页" action:@selector(pushNext)];
    btn.backgroundColor = [UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0];
    
    // 添加渐变色卡片
    NSArray *colors = @[
        @[@"#FF6B9D", @"#C364D9"],
        @[@"#667EEA", @"#764BA2"],
        @[@"#F093FB", @"#F5576C"],
        @[@"#4FACFE", @"#00F2FE"]
    ];
    
    CGFloat startY = 250;
    for (NSInteger i = 0; i < colors.count; i++) {
        UIView *card = [self createGradientCardWithColors:colors[i] index:i];
        [self.view addSubview:card];
        [card mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(startY + i * 90);
            make.height.mas_equalTo(70);
        }];
    }
}

- (UIView *)createGradientCardWithColors:(NSArray *)colors index:(NSInteger)index {
    UIView *card = [[UIView alloc] init];
    card.layer.cornerRadius = 12;
    card.layer.masksToBounds = YES;
    
    // 创建渐变层
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[
        (id)[UIColor zhh_colorWithHexString:colors[0]].CGColor,
        (id)[UIColor zhh_colorWithHexString:colors[1]].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    gradient.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - 40, 70);
    [card.layer addSublayer:gradient];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [NSString stringWithFormat:@"渐变卡片 %ld", (long)(index + 1)];
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    label.textColor = UIColor.whiteColor;
    [card addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(card);
    }];
    
    return card;
}

- (void)pushNext {
    ZHHGradientNavBarViewController *vc = [[ZHHGradientNavBarViewController alloc] init];
    vc.title = @"第二页";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc {
    // 在视图控制器被释放时恢复默认外观
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        UINavigationBarAppearance *defaultAppearance = [[UINavigationBarAppearance alloc] init];
        [defaultAppearance configureWithDefaultBackground];
        
        navBar.standardAppearance = defaultAppearance;
        navBar.scrollEdgeAppearance = defaultAppearance;
        navBar.compactAppearance = defaultAppearance;
        navBar.tintColor = [UIColor systemBlueColor];
        navBar.translucent = YES;
    }
}

@end

