//
//  YZProgressView.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 标题底部滚动的红线
@interface YZProgressView : UIView
@property (nonatomic, strong) NSArray *itemFrames;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) CGFloat progress;
/// 进度因数 ，默认为15，越小越快 ，必须大于0
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat cornerRadius;

// 调皮属性,用于实现腾讯视频的效果
@property (nonatomic, assign) BOOL naughty;
@property (nonatomic, assign) BOOL isTriangle;
@property (nonatomic, assign) BOOL hollow;
@property (nonatomic, assign) BOOL hasBorder;

- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToposition:(NSInteger)posit;

@end
