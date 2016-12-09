//
//  YZScrollView.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZScrollView : UIScrollView<UIGestureRecognizerDelegate>
/// 左滑时同时启动其他手势，比如系统左滑pop，slidemenu滑动，默认是NO

@property (nonatomic, assign) BOOL otherGestureRecognizerSimultaneously;

@end
