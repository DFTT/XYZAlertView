//
//  XYZAlertView.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/19.
//

#import <UIKit/UIKit.h>
#if __has_include("XYZAlertProtocol.h")
#import "XYZAlertProtocol.h"
#else
#import "Dispatch/XYZAlertProtocol.h"
#endif
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XYZAlertViewShowAnimatonType) {
    XYZAlertViewShowAnimatonSystem,  // 仿系统
    XYZAlertViewShowAnimatonBounces, // 中间方法带抖动
    XYZAlertViewShowAnimatonDown,    // 从上落下
};


/// 视图、状态和调度相关 API 均在主线程使用。
@interface XYZAlertView : UIView <XYZAlertDispatchAble>

/// 容器Alert
@property (nonatomic, strong, readonly) UIView *containerAlertView;

/// Alert出现/消失的动画类型
@property (nonatomic, assign) XYZAlertViewShowAnimatonType animationType UI_APPEARANCE_SELECTOR;

/// 容器Alert最大size
/// 默认 CGSizeMake(310, 500)，实际宽度受当前安全区限制。
@property (nonatomic, assign) CGSize containerAlertViewMaxSize UI_APPEARANCE_SELECTOR;

/// 容器Alert圆角半径
/// /// defult 10
@property (nonatomic, assign) CGFloat containerAlertViewRoundValue UI_APPEARANCE_SELECTOR;

/// 背景透明度
/// defult 0.3
@property (nonatomic, assign) CGFloat backAlpha UI_APPEARANCE_SELECTOR;

/// 点击空白区域时自动隐藏
/// defult YES
@property (nonatomic, assign) BOOL hideOnTouchOutside UI_APPEARANCE_SELECTOR;

/// 自动躲避底部停靠的键盘
/// defult YES
@property (nonatomic, assign) BOOL autoAvoidKeyboard UI_APPEARANCE_SELECTOR;

/// 自动躲避键盘时修正偏移量
/// 键盘遮挡弹窗时，此值<0增加避让距离，此值>0减少避让距离。
/// defult 0
@property (nonatomic, assign) CGFloat avoidKeyboardOffsetY;


/// 可以提前指定一个父视图 展示时会优先添加到这个视图上
@property (nonatomic, weak  ) UIView *showOnView;

/// 直接展现
/// 子类覆盖且不调用 super 时，需自行处理布局、键盘避让和动画。
- (void)showOnView:(UIView *)view;
/// 直接消失
- (void)dismissWithAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
