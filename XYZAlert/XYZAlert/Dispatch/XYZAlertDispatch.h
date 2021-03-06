//
//  XYZAlertDispatch.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "XYZAlertProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYZAlertDispatch : NSObject <XYZAlertLifeProtocal>

+ (instancetype)distachWithVerifyBlock:(UIView *(^)(void))block;

/// 调度合适的Alert进行展示
/// 规则:  已经ready & 无未展示dependency & 优先高优先级
- (void)bindedVCDidAppear;

/// 暂时隐藏当前VC绑定的Alerts
- (void)bindedVCDidDisappear;

// 添加Alert 并尝试展示
- (void)addAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;
@end

NS_ASSUME_NONNULL_END
