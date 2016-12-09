//
//  YZMenuItem.m
//  YZPageController
//
//  Created by cyz on 16/12/7.
//  Copyright © 2016年 yuze. All rights reserved.
//

#import "YZMenuItem.h"
#import "YZPageConfig.h"

@interface YZMenuItem (){
    CGFloat _selectedRed, _selectedGreen, _selectedBlue, _selectedAlpha;
    CGFloat _normalRed, _normalGreen, _normalBlue, _normalAlpha;
    int _sign;
    CGFloat _gap;
    CGFloat _step;
    __weak CADisplayLink *_link;
}
@end

@implementation YZMenuItem

#pragma mark - Publick Methods 公共方法
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.normalColor = [UIColor blackColor];
        self.selectedColor = [UIColor blackColor];
        self.normalSize = 15;
        self.seletedSize = 18;
        self.numberOfLines = 0;
    }
    return self;
}
#pragma mark - 懒加载，初始化滚动速度
- (CGFloat)speedFactor
{
    if (_speedFactor <= 0) {
        _speedFactor = 15.0;
    }
    return _speedFactor;
}

// 设置选中，隐式动画
- (void)setSelected:(BOOL)selected
{
    if (self.selected == selected) {
        return;
    }
    _selected = selected;
    _sign = (selected == YES) ? 1 : -1;
    _gap = (selected == YES) ? (1.0 - self.rate) : (self.rate - 0.0);
    _step = _gap / self.speedFactor;
    // 暂时未知link表示什么？？？
    if (_link) {
        [_link invalidate];
    }
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rateChange)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _link = link;
}

- (void)rateChange{
    if (_gap > 0.000001) {
        _gap -= _step;
        if (_gap < 0.0) {
            self.rate = (int)(self.rate + +_sign + _step + 0.5);
            return;
        }
        self.rate += _sign * _step;
    }else {
        self.rate = (int)(self.rate + 0.5);
        [_link invalidate];
        _link = nil;
    }
}

// 设置rate，并刷新标题状态
- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    CGFloat r = _normalRed + (_selectedRed - _normalRed) * rate;
    CGFloat g = _normalGreen + (_selectedGreen - _normalGreen) * rate;
    CGFloat b = _normalBlue + (_selectedBlue - _normalBlue) * rate;
    CGFloat a = _normalAlpha + (_selectedAlpha - _normalAlpha) * rate;
    
    self.textColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
    CGFloat minScale = self.normalSize / self.seletedSize;
    CGFloat trueScale = minScale + (1 - minScale)*rate;
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
    
}

- (void)selectedWithoutAnimation
{
    self.rate = 1.0;
    _selected = YES;
}

- (void)deselectedWithoutAnimation
{
    self.rate = 0;
    _selected = NO;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    [selectedColor getRed:&_selectedRed green:&_selectedGreen blue:&_selectedBlue alpha:&_selectedAlpha];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    [normalColor getRed:&_normalRed green:&_normalGreen blue:&_normalBlue alpha:&_normalAlpha];
}

#pragma mark - 点击触发方法
/**
 当点击标题结束的时候触发
 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //  调用代理方法
    if ([self.delegate respondsToSelector:@selector(didPressedMenuItem:)]) {
        [self.delegate didPressedMenuItem:self];
    }
}

@end






































