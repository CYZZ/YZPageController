//
//  YZPageConfig.h
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#ifndef YZPageConfig_h
#define YZPageConfig_h 

#define kRGBColor(R, G, B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1]
#define YZTitleColorSelected kRGBColor(168.0, 20.0, 4.0)
#define YZTitleColorNormal kRGBColor(0, 0, 0)
#define YZMenuBGColor kRGBColor(244.0, 244.0, 244.0)

//  标题的尺寸(选中/非选中)
static CGFloat const YZTitleSizeSelected = 18.0f;
static CGFloat const YZTitleSizeNormal   = 15.0f;
//  导航菜单栏的高度
static CGFloat const YZMenuHeight        = 30.0f;
//  导航菜单栏每个item的宽度
static CGFloat const YZMenuItemWidth     = 65.0f;

/// 用于通知控制器被添加到屏幕上
static NSString *const YZControllerDidAddToSuperViewNotification = @"YZControllerDidAddToSuperViewNotification";

/// 当一个控制器被完全展示在用户面前的时候发送通知，
// 可用于判断当前控制器的序号，加载或者刷新当前数据
// 传递的数据包含两个信息，当前的序号（index）以及标题 （title）
static NSString *const YZControllerDidFullyDisplayedNotification = @"YZControllerDidFullyDisplayedNotification";

#endif /* YZPageConfig_h */
