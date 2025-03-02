//
//  ZHHViewControllerAnimatedTransitioning.h
//  ZHHAnneKitExample
//
//  Created by 桃色三岁 on 2024/9/18.
//  Copyright © 2024 桃色三岁. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef ZHHViewControllerAnimatedTransitioning_h
#define ZHHViewControllerAnimatedTransitioning_h

@protocol ZHHViewControllerAnimatedTransitioning <UIViewControllerAnimatedTransitioning>

- (id<UIViewControllerInteractiveTransitioning>)zhh_interactiveTransitioning;

@end

#endif /* ZHHViewControllerAnimatedTransitioning_h */
