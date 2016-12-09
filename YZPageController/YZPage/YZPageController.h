//
//  YZPageController.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZMenuView.h"
#import "YZScrollView.h"
@class YZPageController;


/**
 缓存类型，默认是无限制的，当收到内存警告的时候即memoryWarning被调用的时候会自动切换到底缓存模式
 */
typedef NS_ENUM(NSUInteger, YZPageControllerCachePolicy) {
    YZPageControllerCachePolicyNoLimit = 0, // 无限制
    YZPageControllerCachePolicyLowMemory = 1, // 低缓存，但是滚动的时候会有卡顿的现象
    YZPageControllerCachePolicyBalancel = 3, // 平衡状态，会自动提高和减低⤴️and⤵️
    YZPageControllerCachePolicyHight = 5, // 高缓存
};


/**
 默认加载机制
 */
typedef NS_ENUM(NSUInteger, YZPageControllerPreloadPolicy) {
    YZPageControllerPreloadPolicyNever = 0, // 从不加载，默认显示哪个加载哪个
    YZPageControllerPreloadPolicyNeighbour = 1, // 自动加载下一个视图
    YZPageControllerPreloadPolicyNear = 2, // 加载左右两个视图
};

@protocol YZPageControllerDataSource  <NSObject>
@optional

/**
 子控制器的数量

 @param pageController 当前的控制器
 @return 总控制器数量
 */
- (NSInteger)numberOfChildControllersInPageController:(YZPageController * _Nonnull)pageController;

/**
 索引对应的控制器

 @param pageController 当前管理的总控制器
 @param index 索引
 @return 显示的“子”控制器
 */
- (__kindof UIViewController *_Nonnull)pageController:(YZPageController *_Nonnull)pageController viewControllerAtIndex:(NSInteger)index;


/**
 每一个控制器对应的标题

 @param pageController 总控制器（管理者）
 @param index 索引
 @return 标题
 */
- (NSString *_Nonnull)pageController:(YZPageController *_Nonnull)pageController titleAtIndex:(NSInteger)index;
@end

@protocol YZPageControllerDelegate <NSObject>
@optional


/**
 如果子控制器比较重量级，就可以把比较耗时的操纵放到这个方法中，这个方法只会在滚动结束的时候调用，防止滚动过程中发生卡顿的现象（如果控制器已经被加载过就不会调用该方法）

 @param pageController 当前的控制器（管理者)
 @param viewController 滚动结束后即将显示的控制器
 @param info info中包含索引标题等信息
 */
- (void)pageController:(YZPageController *_Nonnull)pageController lazyLoadViewController:(__kindof UIViewController * _Nonnull)viewController withInfo:(NSDictionary * _Nonnull)info;


/**
 即将被缓存的时候调用该方法，可以在这个方法中处理不需要用到的数据

 @param pageController 管理者（总控制器)
 @param viewController 即将被缓存的控制器
 @param info info中包含索引标题等信息
 */
- (void)pageController:(YZPageController * _Nonnull)pageController willCacheViewController:(__kindof UIViewController * _Nonnull)viewController withInfo:(NSDictionary * _Nonnull)info;


/**
 控制器即将出现，将要显示在用户面前的时候调用

 @param pageController 管理者（总控制器)
 @param viewController 将要显示的控制器
 @param info info中包含索引标题等信息
 */
- (void)pageController:(YZPageController * _Nonnull)pageController willEnterViewController:(__kindof UIViewController * _Nonnull)viewController withInfo:(NSDictionary * _Nonnull)info;


/**
 控制器即将准备成为主控制器，意味着能够操作该控制器的相关点击事件就是在滚动即将停下的时候会调用该方法

 @param pageController 管理者（总控制器)
 @param viewController 即将成为被操作的控制器
 @param info info中包含索引标题等信息
 */
- (void)pageController:(YZPageController * _Nonnull)pageController didEnterViewController:(__kindof UIViewController * _Nonnull)viewController withInfo:(NSDictionary * _Nonnull)info;



@end

@interface YZPageController : UIViewController<YZMenuViewDelegate, YZMenuViewDataSource, UIScrollViewDelegate, YZPageControllerDataSource, YZPageControllerDelegate>

/// 代理方法
@property (nonatomic, weak) id<YZPageControllerDelegate> _Nullable delegate;
/// 数据源方法
@property (nonatomic, weak) id<YZPageControllerDataSource> _Nullable dataSource;

/**
 可以使用kvc设置控制器的一些属性使用的使用需要确保key的名字与控制器所拥有的属性对应
 例如要设置控制器的type，那么keys所放的keys就是字符串@"type")
 */
/// 值
@property (nonatomic, strong) NSMutableArray *_Nullable values;
/// 键
@property (nonatomic, strong) NSMutableArray<NSString *> *_Nullable keys;

/// 各个控制器的class，例如[UITableViewController class]
@property (nonatomic, strong) NSArray<Class>  * _Nullable viewControllerClasses;

@end





















































