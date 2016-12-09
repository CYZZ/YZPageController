
//
//  YZMenuView.m
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import "YZMenuView.h"

@interface YZMenuView ()
@property (nonatomic, weak) YZMenuItem *selItem;
@property (nonatomic, strong) NSMutableArray *frames;
@property (nonatomic, assign) NSInteger titleCount;
@property (nonatomic, assign) NSInteger selectIndex;
@end

#pragma mark - 常量
static CGFloat const YZProgressHeight = 2.0;
static CGFloat const YZMenuItemWidth = 60.0;
static NSInteger const YZMenuItemTagOffSet = 6250;
static NSInteger const YZBadgeViewTagOffset  = 1212;

@implementation YZMenuView

#pragma mark - Setter方法
- (void)setLayoutMode:(YZMenuViewLayoutMode)layoutMode
{
    _layoutMode = layoutMode;
    if (!self.superview) {
        return;
    }
    [self reload]; // 设置样式之后刷新
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (!self.scrollView) {
        return;
    }
    CGFloat leftMargin = self.contentMargin + self.leftView.frame.size.width;
    CGFloat rightMargin = self.contentMargin + self.rightView.frame.size.width;
    CGFloat contentWidth = self.scrollView.frame.size.width + leftMargin + rightMargin;
    CGFloat startX = self.leftView ? self.leftView.frame.origin.x : self.scrollView.frame.origin.x - self.contentMargin;
    
    // 让内容居中，因为系统可能会改变menuView的frame
    if (startX + contentWidth / 2 != self.bounds.size.width / 2) {
        CGFloat xOffset = (self.bounds.size.width - contentWidth) / 2;
        
        self.leftView.frame = ({
            CGRect frame = self.leftView.frame;
            frame.origin.x = xOffset;
            frame;
        });
        
        self.scrollView.frame = ({
            CGRect frame = self.scrollView.frame;
            frame.origin.x = self.leftView ? CGRectGetMaxX(self.leftView.frame) + self.contentMargin : xOffset;
            frame;
        });
        
        self.rightView.frame = ({
            CGRect frame = self.rightView.frame;
            frame.origin.x = CGRectGetMaxX(self.scrollView.frame) + self.contentMargin;
            frame;
        });
    }
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius
{
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.progressView) {
        self.progressView.cornerRadius = _progressViewCornerRadius;
    }
}

- (void)setSpeedFactor:(CGFloat)speedFactor
{
    _speedFactor = speedFactor;
    if (self.progressView) {
        self.progressView.speedFactor = _speedFactor;
    }
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[YZMenuItem class]]) {
            ((YZMenuItem*)obj).speedFactor = _speedFactor;
        }
    }];
}

- (void)setProgressWidths:(NSArray *)progressWidths
{
    _progressWidths = progressWidths;
    
    if (!self.progressView.superview) {
        return;
    }
    [self resetFramesFromIndex:0];
}

- (void)setLeftView:(UIView *)leftView
{
    if (self.leftView) { // 如果存在就移除现有的view
        [self.leftView removeFromSuperview];
        _leftView = nil;
    }
    if (leftView) {
        [self addSubview:leftView];
        _leftView = leftView;
    }
    [self resetFrames];
}

- (void)setRightView:(UIView *)rightView
{
    if (self.rightView) {
        [self.rightView removeFromSuperview];
        _rightView = nil;
    }
    if (rightView) {
        [self addSubview: rightView];
        _rightView = rightView;
    }
    [self resetFrames];
}

- (void)setContentMargin:(CGFloat)contentMargin
{
    _contentMargin = contentMargin;
    if (self.scrollView) {
        [self resetFrames];
    }
}

#pragma mark - getter方法
- (UIColor *)lineColor
{
    if (!_lineColor) {
        _lineColor = self.selectedColor;
    }
    return _lineColor;
}

- (NSMutableArray *)frames
{
    if (_frames == nil) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

- (UIColor *)selectedColor
{
    if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:)]) {
        return [self.delegate menuView:self titleColorForState:YZMenuItemStateSelected];
    }
    return [UIColor blackColor];
}

- (UIColor *)normalColor
{
    if ([self.delegate respondsToSelector:@selector(menuView:titleColorForState:)]) {
        return [self.delegate menuView:self titleColorForState:YZMenuItemStateNormal];
    }
    return [UIColor blackColor];
}

- (CGFloat)selectedSize
{
    if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:)]) {
        return [self.delegate menuView:self titleSizeForState:YZMenuItemStateSelected];
    }
    return 18.0;
}

- (CGFloat)normalSize
{
    if ([self.delegate respondsToSelector:@selector(menuView:titleSizeForState:)]) {
        return [self.delegate menuView:self titleSizeForState:YZMenuItemStateNormal];
    }
    return 15.0;
}

- (UIView *)badgeViewAtIndex:(NSInteger)index{
    if (![self.dataSource respondsToSelector:@selector(menuView:badgeViewAtInde:)]) {
        return nil;
    }
    UIView *badgeView = [self.dataSource menuView:self badgeViewAtInde:index];
    if (!badgeView) {
        return nil;
    }
    badgeView.tag = index + YZBadgeViewTagOffset;
    
    return badgeView;
}

- (void)reload
{
    [self.frames removeAllObjects];
    [self.progressView removeFromSuperview];
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
    
}

- (void)slideMenuAtProgress:(CGFloat)progress
{
    if (self.progressView) {
        self.progressView.progress = progress;
    }
    NSInteger tag = (NSInteger)progress + YZMenuItemTagOffSet;
    CGFloat rate = progress - tag + YZMenuItemTagOffSet;
    YZMenuItem *currentItem = (YZMenuItem *)[self viewWithTag:tag];
    YZMenuItem *nextItem = (YZMenuItem *)[self viewWithTag:tag + 1];
    if (rate == 0.0) {
        [self.selItem deselectedWithoutAnimation];
        self.selItem = currentItem;
        [self.selItem selectedWithoutAnimation];
        [self refreshContentOffset];
        return;
    }
    currentItem.rate = 1 - rate;
    nextItem.rate = rate;
}

- (void)selectItemAtIndex:(NSInteger)index
{
    NSInteger tag = index + YZMenuItemTagOffSet;
    NSInteger currentIndex = self.selItem.tag - YZMenuItemTagOffSet;
    self.selectIndex = index;
    if (index == currentIndex || !self.selItem) {
        return;
    }
    
    YZMenuItem *item = (YZMenuItem *)[self viewWithTag:tag];
    [self.selItem deselectedWithoutAnimation];
    self.selItem = item;
    [self.selItem selectedWithoutAnimation];
    [self.progressView setProgressWithOutAnimate:index];
    if ([self.delegate respondsToSelector:@selector(menuView:didSeleSctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSeleSctedIndex:index currentIndex:currentIndex];
    }
    [self refreshContentOffset];
    
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update
{
    if (index >= self.titleCount || index < 0) {
        return;
    }
    YZMenuItem *item = (YZMenuItem *)[self viewWithTag:(YZMenuItemTagOffSet + index)];
    item.text = title;
    if (update) {
        [self resetFrames];
    }
}

- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update
{
    if (index >= self.titleCount || index < 0) {
        return;
    }
    YZMenuItem *item = (YZMenuItem *)[self viewWithTag:(YZMenuItemTagOffSet + index)];
    item.attributedText = title;
    if (update) {
        [self resetFrames];
    }
}

- (void)updateBadgeViewAtIndex:(NSInteger)index
{
    UIView *oldBadgeView = [self.scrollView viewWithTag:(YZBadgeViewTagOffset + index)];
    if (oldBadgeView) {
        [oldBadgeView removeFromSuperview];
    }
    [self addBadgeViewAtIndex:index];
    [self resetBadgeFrame:index];
}

// 让选中的item位于中间
- (void)refreshContentOffset
{
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width / 2.0) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width / 2.0) {
            targetX = contentSize.width - width;
        }else{
            targetX = frame.origin.x - width/2.0 + frame.size.width/2;
        }
        // 应该有更好的解决办法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    }else{
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark - DataSource
- (NSInteger)titleCount
{
    return [self.dataSource numberOfTitlesInMenuView:self];
}

#pragma mark - PrivateMethods 私有方法
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (self.scrollView) {
        return;
    }
    
    [self addScrollView];
    [self addItems];
    [self makeStyle];
    [self addBadgeViews];
    
    
    if (self.selectIndex == 0) {
        return;
    }
    [self selectItemAtIndex:self.selectIndex];
    
}

- (void)resetFrames
{
    CGRect frame = self.bounds;
    if (self.rightView) {
        CGRect rightFrame = self.rightView.frame;
        rightFrame.origin.x = frame.size.width - rightFrame.size.width;
        self.rightView.frame = rightFrame;
        frame.size.width -= rightFrame.size.width;
    }
    
    if (self.leftView) {
        CGRect leftFrame = self.leftView.frame;
        leftFrame.origin.x = 0;
        self.leftView.frame = leftFrame;
        frame.origin.x += leftFrame.size.width;
        frame.size.width -= leftFrame.size.width;
    }
    
    frame.origin.x += self.contentMargin;
    frame.size.width -= self.contentMargin * 2;
    self.scrollView.frame = frame;
    [self resetFramesFromIndex:0];
}

- (void)resetFramesFromIndex:(NSInteger)index
{
    [self.frames removeAllObjects];
    [self calculateItemFrames];
    for (NSInteger i = index; i < self.titleCount; i++) {
        [self resetItemFrame:i];
        [self resetBadgeFrame:i];
    }
    
    if (!self.progressView.superview) {
        return;
    }
    CGRect frame = self.progressView.frame;
    frame.size.width = self.scrollView.contentSize.width;
    if (self.style == YZMenuViewStyleLine || self.style == YZMenuViewStyleTriangle) {
        frame.origin.y = self.frame.size.height - self.progressHeight - self.progressViewBottonSpace;
    }else{
        frame.origin.y = (self.scrollView.frame.size.height - frame.size.height) / 2.0;
    }
    
    self.scrollView.frame = frame;
    self.progressView.itemFrames = [self convertProgressWidthsToFrames];
    [self.progressView setNeedsDisplay];
    
}

// 计算所有item的frame值，主要是为适配所有item的狂赌纸盒小于屏幕宽度的情况
// 这与后面的‘-(void)addItems"做了重复的操作，并不是很合理需要后期改进
- (void)calculateItemFrames
{
    CGFloat contentWidth = [self itemMarginAtIndex:0];
    for (int i = 0; i < self.titleCount; i++) {
        CGFloat itemW = YZMenuItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemW = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemW, self.frame.size.height);
        // 记录frame
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemW + [self itemMarginAtIndex:i + 1];
    }
    
    // 如果总宽度小于屏幕宽度，重新计算frame，为item间添加间距
    if (contentWidth < self.scrollView.frame.size.width) {
        CGFloat distance = self.scrollView.frame.size.width - contentWidth;
        CGFloat (^shiftDis)(int);
        
        switch (self.layoutMode) {
            case YZMenuViewStyleModeScatter:
            {
                CGFloat gap = distance / (self.titleCount + 1);
                shiftDis = ^CGFloat(int index) {
                    return gap * (index + 1);
                };
                break;
            }
            case YZMenuViewLayoutModeLeft:{
                shiftDis = ^CGFloat(int index){
                    return 0.0;
                };
                break;
            }
            case YZMenuViewLayoutModeRight:{
                shiftDis = ^CGFloat(int index){
                    return distance / 2.0;
                };
                break;
            }
            case YZMenuViewLayoutModeCenter:{
                shiftDis = ^CGFloat(int index){
                    return distance / 2.0;
                };
                break;
            }
        }
        for (int i = 0; i < self.frames.count; i++) {
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += shiftDis(i);
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.scrollView.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (CGFloat)itemMarginAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(menuView:itemMarginAtIndex:)]) {
        return [self.delegate menuView:self itemMarginAtIndex:index];
    }
    return 0.0;
}


- (void)addScrollView
{
    CGFloat width = self.frame.size.width - self.contentMargin * 2;
    CGFloat height = self.frame.size.height;
    CGRect frame = CGRectMake(self.contentMargin, 0, width, height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
}

- (void)addItems
{
    [self calculateItemFrames];
    
    for (int i = 0; i < self.titleCount; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        YZMenuItem *item = [[YZMenuItem alloc]initWithFrame:frame];
        if (self.fontName) {
            item.font = [UIFont fontWithName:self.fontName size:self.selectedSize];
        }else{
            item.font = [UIFont systemFontOfSize:self.selectedSize];
        }
        item.tag = (i + YZMenuItemTagOffSet);
        item.delegate = self;
        item.text = [self.dataSource menuView:self titleAtIndex:i];
        item.textAlignment = NSTextAlignmentCenter; // 字体居中
        if ([self.dataSource respondsToSelector:@selector(menuView:initialMenuItem:atIndex:)]) {
            item = [self.dataSource menuView:self initialMenuItem:item atIndex:i];
        }
        item.userInteractionEnabled = YES;
        item.backgroundColor = [UIColor clearColor];
        item.normalSize = self.normalSize;
        item.seletedSize = self.selectedSize;
        item.normalColor = self.normalColor;
        item.selectedColor = self.selectedColor;
        item.speedFactor = self.speedFactor;
        if (i == 0) {
            [item selectedWithoutAnimation];
            self.selItem = item;
        }else{
            [item deselectedWithoutAnimation];
        }
        [self.scrollView addSubview:item];
    }
}
- (void)makeStyle
{
    CGRect frame = CGRectZero;
    if (self.style == YZMenuViewStyleDefault) {
        return;
    }
    if (self.style == YZMenuViewStyleLine) {
        self.progressHeight = self.progressHeight > 0 ? self.progressHeight : YZProgressHeight;
        frame = CGRectMake(0, self.frame.size.height - self.progressHeight - self.progressViewBottonSpace, self.scrollView.contentSize.width, self.progressHeight);
    }else{
        self.progressHeight = self.progressHeight > 0 ? self.progressHeight : self.frame.size.height * 0.8;
        frame = CGRectMake(0, (self.frame.size.height - self.progressHeight) / 2.0, self.scrollView.contentSize.width, self.progressHeight);
        self.progressViewCornerRadius = self.progressViewCornerRadius > 0 ? self.progressViewCornerRadius : self.progressHeight / 2.0;
    }
    [self yz_addProgressViewWithFrame:frame isTriangle:(self.style == YZMenuViewStyleTriangle) hasBorder:(self.style == YZMenuViewStyleSegmented) hollow:(self.style == YZMenuViewStyleFloodHollow) cornerRadius:self.progressViewCornerRadius];
}

- (void)deselectedItemsIfNeeded
{
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[YZMenuItem class]] || obj == self.selItem) {
            return ;
        }
        [(YZMenuItem *)obj deselectedWithoutAnimation];
    }];
}

- (void)addBadgeViews
{
    for (int i = 0; i < self.titleCount; i++) {
        [self addBadgeViewAtIndex:i];
    }
}

- (void)resetItemFrame:(NSInteger)index
{
    YZMenuItem *item = (YZMenuItem *)[self viewWithTag:(YZMenuItemTagOffSet + index)];
    CGRect frame = [self.frames[index] CGRectValue];
    item.frame = frame;
    if ([self.delegate respondsToSelector:@selector(menuView:didLayoutItemFrame:atIndex:)]) {
        [self.delegate menuView:self didLayoutItemFrame:item atIndex:index];
    }
}

- (void)addBadgeViewAtIndex:(NSInteger)index
{
    UIView *badgeView = [self badgeViewAtIndex:index];
    if (badgeView) {
        [self.scrollView addSubview:badgeView];
    }
    
}

- (void)resetBadgeFrame:(NSUInteger)index
{
    CGRect frame = [self.frames[index] CGRectValue];
    UIView *badgeView = [self.scrollView viewWithTag:(YZBadgeViewTagOffset + index)];
    if (badgeView) {
        CGRect badgeFrame = [self badgeViewAtIndex:index].frame;
        badgeFrame.origin.x += frame.origin.x;
        badgeView.frame = badgeFrame;
    }
}

- (NSArray *)convertProgressWidthsToFrames
{
    if (self.frames.count == 0) {
        NSAssert(NO, @"bug 不应该到这里，如果崩溃在这里说明没有frames");
    }
    if (self.progressWidths.count < self.titleCount) {
        return self.frames;
    }
    
    NSMutableArray *progressFrames = [NSMutableArray array];
    NSInteger count = (self.frames.count <= self.progressWidths.count) ? self.frames.count : self.progressWidths.count;
    for (int i = 0; i < count; i++) {
        CGRect itemFrame = [self.frames[i] CGRectValue];
        CGFloat progressWidth = [self.progressWidths[i] floatValue];
        CGFloat x = itemFrame.origin.x + (itemFrame.size.width = progressWidth) / 2.0;
        CGRect progressFrame = CGRectMake(x, itemFrame.origin.y, progressWidth, 0);
        [progressFrames addObject:[NSValue valueWithCGRect:progressFrame]];
    }
    return progressFrames;
    
}

- (void)yz_addProgressViewWithFrame:(CGRect)frame isTriangle:(BOOL)isTriangle hasBorder:(BOOL)hasBorder hollow:(BOOL)isHollow cornerRadius:(CGFloat)corneRadius
{
    YZProgressView *progressView = [[YZProgressView alloc] initWithFrame:frame];
    progressView.itemFrames = [self convertProgressWidthsToFrames];
    progressView.color = self.lineColor.CGColor;
    progressView.isTriangle = isTriangle;
    progressView.hasBorder = hasBorder;
    progressView.hollow = isHollow;
    progressView.cornerRadius = corneRadius;
    progressView.naughty = self.progressViewIsNaugty;
    progressView.speedFactor = self.speedFactor;
    progressView.backgroundColor = [UIColor clearColor];
    self.progressView = progressView;
    [self.scrollView insertSubview:self.progressView atIndex:0];
}

#pragma mark - Menu itemDelegate<代理方法>
- (void)didPressedMenuItem:(YZMenuItem *)menuItem
{
    if (self.selItem == menuItem) {
        return;
    }
    CGFloat progress = menuItem.tag - YZMenuItemTagOffSet;
    [self.progressView moveToposition:progress];
    
    NSInteger currentIndex = self.selItem.tag - YZMenuItemTagOffSet;
    if ([self.delegate respondsToSelector:@selector(menuView:didSeleSctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSeleSctedIndex:menuItem.tag - YZMenuItemTagOffSet currentIndex:currentIndex];
    }
    
    menuItem.selected = YES;
    self.selItem.selected = NO;
    self.selItem = menuItem;
    
    NSTimeInterval delay = self.style == YZMenuViewStyleDefault ? 0 : 0.3f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 让选中的item位于中间
        [self refreshContentOffset];
    });
}

@end

























































