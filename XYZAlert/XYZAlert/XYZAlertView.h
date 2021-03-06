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
/// screenWitdh==320 ? CGSizeMake(280, 400) : CGSizeMake(310, 500);
@property (nonatomic, assign) CGSize containerAlertViewMaxSize;

/// 容器Alert圆角半径
@property (nonatomic, assign) CGFloat containerAlertViewRoundValue;

/// 点击空白区域时自动隐藏
/// defult YES
@property (nonatomic, assign) BOOL hideOnTouchOutside;

/// 背景透明度
/// defult 0.3
@property (nonatomic, assign) CGFloat backAlpha;

/// 自动躲避键盘 (键盘弹出时 自动往上便宜键盘的高度)
/// defult YES
@property (nonatomic, assign) BOOL autoAvoidKeyboard;


/// 可以提前指定一个父视图 展示时会优先添加到这个视图上
@property (nonatomic, weak  ) UIView *showOnView;

/// 展现
- (void)showOnView:(UIView *)view;
/// 消失
- (void)dismissWithAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
