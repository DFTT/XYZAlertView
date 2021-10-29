//
//  XYZAlertView.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/19.
//

#import <UIKit/UIKit.h>
#import "XYZAlertProtocol.h"
NS_ASSUME_NONNULL_BEGIN


@interface XYZAlertView : UIView <XYZAlertEnableDispatchProtocal>

/// 容器Alert
@property (nonatomic, strong) UIView *containerAlertView;

/// 容器Alert最大size
/// defult screenWitdh==320 ? CGSizeMake(280, 400) : CGSizeMake(310, 500);
@property (nonatomic, assign) CGSize containerAlertViewMaxSize;

/// 容器Alert圆角半径
@property (nonatomic, assign) CGFloat containerAlertViewRoundValue;

/// 背景透明度
/// defult 0.3
@property (nonatomic, assign) CGFloat backAlpha;

/// 点击空白区域时自动隐藏
/// defult YES
@property (nonatomic, assign) BOOL hideOnTouchOutside;

/// 自动躲避键盘 (键盘弹出时 自动往上便宜键盘的高度)
/// defult YES
@property (nonatomic, assign) BOOL autoAvoidKeyboard;

/// 自动躲避键盘时修正偏移量
/// 键盘弹出时 默认自动往上偏移键盘的高度 此值<0时 会增加向上偏移的距离, 此值>0时 会减小向上偏移的距离
/// defult 0
@property (nonatomic, assign) CGFloat avoidKeyboardOffsetY;


/// 可以提前指定一个父视图 展示时会优先添加到这个视图上
@property (nonatomic, weak  ) UIView *showOnView;

/// 直接展现
- (void)showOnView:(UIView *)view;
/// 直接消失
- (void)dismissWithAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
