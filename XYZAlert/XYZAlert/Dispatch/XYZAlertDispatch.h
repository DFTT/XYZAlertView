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


- (void)dispatchAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;

- (void)dispatchAlert:(id<XYZAlertEnableDispatchProtocal>)alert;

/// 调度合适的Alert进行展示
/// 规则:  已经ready & 无未展示dependency & 优先高优先级
- (void)tryDispatch;

@end

NS_ASSUME_NONNULL_END
