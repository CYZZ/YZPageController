//
//  YZScrollView.m
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import "YZScrollView.h"

@implementation YZScrollView

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // iOS横向滚动的scrollView和系统pop手势返回冲突的解决办法:     http://blog.csdn.net/hjaycee/article/details/49279951
    
    // 兼容系统的pop手势 / FDFullscreenPopGesture / 如有自定义手势需自行在此处判断
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    
    // ReSideMenu 及其他一些手势的开启，需要在这里自行处理，目前还没有完全兼容好，会引起一个小问题
    if (self.otherGestureRecognizerSimultaneously) {
        // 再判断系统的手势state是began还是fail，同时判断scrollView的位置是不是正阿红在最左边
        if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //TODO: UITableViewCell 自定义手势可能要在此处自行定义
    
    if ([otherGestureRecognizer.view isKindOfClass:NSClassFromString(@"UITableViewWrapperVIew")] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
    
}


@end














































