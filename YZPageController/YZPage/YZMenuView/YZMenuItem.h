//
//  YZMenuItem.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZMenuItem;


/** 标题的状态 */
typedef NS_ENUM(NSUInteger, YZMenuItemState) {
    /// 选中状态
    YZMenuItemStateSelected,
    /// 普通状态
    YZMenuItemStateNormal,
};

@protocol YZMenuItemDelegate <NSObject>
@optional
- (void)didPressedMenuItem:(YZMenuItem *)menuItem;
@end

@interface YZMenuItem : UILabel

@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat normalSize;
@property (nonatomic, assign) CGFloat seleteSize;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@property (nonatomic, weak) id <YZMenuItemDelegate> delegate;
/// 进度条的速度，默认为15，越小越快必须大于0
@property (nonatomic, assign) CGFloat speedFactor;

- (void)selectedWithoutAnimation;
- (void)deselectedWithoutAnimation;


@end
