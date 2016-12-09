//
//  YZMenuView.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZMenuItem.h"
#import "YZProgressView.h"
@class YZMenuView;

typedef NS_ENUM(NSUInteger, YZMenuViewStyle) {
    YZMenuViewStyleDefault, // 默认
    YZMenuViewStyleLine, // 带下划线
    YZMenuViewStyleTriangle, // 三角形
    YZMenuViewStyleFlood, // 涌入效果填充颜色
    YZMenuViewStyleFloodHollow, // 涌入效果（空心)
    YZMenuViewStyleSegmented, // 涌入带边框，即网易新闻频道管理
};

typedef NS_ENUM(NSUInteger, YZMenuViewLayoutMode) {
    YZMenuViewStyleModeScatter, // 默认的布局模式，如果item数量较少时均分标题栏
    YZMenuViewLayoutModeLeft, // Item紧靠屏幕左侧
    YZMenuViewLayoutModeRight, // Item紧靠屏幕右侧
    YZMenuViewLayoutModeCenter, // Item 紧挨且居中分布
};

@protocol YZMenuViewDelegate <NSObject>
@optional
- (void)menuView:(YZMenuView *)menu didSeleSctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
- (CGFloat)menuView:(YZMenuView *)menu widthForItemAtIndex:(NSInteger)index;
- (CGFloat)menuView:(YZMenuView *)menu itemMarginAtIndex:(NSInteger)index;
- (CGFloat)menuView:(YZMenuView *)menu titleSizeForState:(YZMenuItemState)state;
- (UIColor *)menuView:(YZMenuView *)menu titleColorForState:(YZMenuItemState)state;
- (void)menuView:(YZMenuView *)menu didLayoutItemFrame:(YZMenuItem *)menuItem atIndex:(NSInteger)index;
@end

@protocol YZMenuViewDataSource <NSObject>

@required
/**
 标题数量数据源方法

 @param menu 当前菜单栏
 @return 标题总数
 */
- (NSInteger)numberOfTitlesInMenuView:(YZMenuView *)menu;

/**
 设置每一个位置的标题

 @param menu 当前菜单栏
 @param index 索引
 @return 标题
 */
- (NSString *)menuView:(YZMenuView *)menu titleAtIndex:(NSInteger)index;

@optional

/**
 设置角标

 @param menu 当前菜单栏
 @param index 索引
 @return 自定义View
 */
- (UIView *)menuView:(YZMenuView *)menu badgeViewAtInde:(NSInteger)index;


/**
 自定义YZMenuItem，可以对当前已经初始化的Item进行修改，也可以继承YZMenuItem进行自定义控件，此时的Item的frame是不确定的，所有请勿根据此时的frame做计算
 如果需要根据frame修改，请使用代理

 @param menu 当前的menuView，frame是不确定的
 @param initialMenuItem 正在使用的menuItem
 @param index 索引
 @return 定制完成之后的MenuItem
 */
- (YZMenuItem *)menuView:(YZMenuView *)menu initialMenuItem:(YZMenuItem *)initialMenuItem atIndex:(NSInteger)index;

@end

@interface YZMenuView : UIView <YZMenuItemDelegate>

@property (nonatomic, strong) NSArray *progressWidths;
/// 下划线
@property (nonatomic, weak) YZProgressView *progressView;
/// 下划线的高度
@property (nonatomic, assign) CGFloat progressHeight;
/// 类型
@property (nonatomic, assign) YZMenuViewStyle style;
/// 标题分布样式
@property (nonatomic, assign) YZMenuViewLayoutMode layoutMode;
/// 标题间距
@property (nonatomic, assign) CGFloat contentMargin;
/// 下划线颜色
@property (nonatomic, strong) UIColor *lineColor;
/// 距离底部的间距
@property (nonatomic, assign) CGFloat progressViewBottonSpace;
/// menuView的代理代理方法
@property (nonatomic, weak) id<YZMenuViewDelegate> delegate;
/// menuView的数据源方法
@property (nonatomic, weak) id<YZMenuViewDataSource> dataSource;
/// 菜单栏的左视图
@property (nonatomic, weak) UIView *leftView;
/// 菜单栏的右视图
@property (nonatomic, weak) UIView *rightView;
/// 字体名字
@property (nonatomic, copy) NSString *fontName;
/// 选中状态的字体大小
@property (nonatomic, assign) CGFloat selectedSize;
/// 普通状态下的字体大小
@property (nonatomic, assign) CGFloat normalSize;
/// 选中时的颜色
@property (nonatomic, strong) UIColor *selectedColor;
/// 普通状态下的字体颜色
@property (nonatomic, strong) UIColor *normalColor;
/// 滚动视图
@property (nonatomic, weak) UIScrollView *scrollView;
/// 进度条速度因数 默认为15， 越小越快,必须大于0
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat progressViewCornerRadius;
@property (nonatomic, assign) BOOL progressViewIsNaugty;

- (void)slideMenuAtProgress:(CGFloat)progress;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)resetFrames;
- (void)reload;

/**
 更新标题

 @param title 最新标题
 @param index 索引
 @param update 是否更新
 */
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;


/**
 更行字体属性

 @param title 属性字体
 @param index 索引
 @param update 是否刷新
 */
- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
/// 立即刷新,让item位于中间
- (void)refreshContentOffset;
- (void)deselectedItemsIfNeeded;
/// 更新角标
- (void)updateBadgeViewAtIndex:(NSInteger)index;

@end








































