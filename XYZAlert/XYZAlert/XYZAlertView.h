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


/// 展现
- (void)showInView:(UIView *)view;
/// 消失
- (void)dismissWithAnimation:(BOOL)animation;

@end

NS_ASSUME_NONNULL_END
