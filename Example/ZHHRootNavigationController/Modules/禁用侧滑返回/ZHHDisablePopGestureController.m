//
//  ZHHDisablePopGestureController.m
//  ZHHRootNavigationController_Example
//
//  Created by 桃色三岁 on 2025/4/5.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

#import "ZHHDisablePopGestureController.h"
#import "ZHHHiddenStatusViewController.h"

@interface ZHHDisablePopGestureController () 

@end

@implementation ZHHDisablePopGestureController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.zhh_disableEdgePopGesture = YES;
//    self.zhh_disableFullscreenPopGesture = YES;
    self.zhh_navigationController.zhh_enableInteractivePush = YES;
    self.zhh_maxAllowedInitialX = 30;
}

- (UIViewController *)zhh_nextPushViewController{
    return [[ZHHHiddenStatusViewController alloc] init];
}
@end
