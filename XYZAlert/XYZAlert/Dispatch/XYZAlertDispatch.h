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
- (void)tryDispatch;




// 添加一个Alert 并尝试展示
- (void)dispatchAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;

// 添加多个Alert 并尝试展示
- (void)dispatchAlert:(id<XYZAlertEnableDispatchProtocal>)alert;
@end

NS_ASSUME_NONNULL_END
