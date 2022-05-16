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
/// 规则:
/// 第一步: 按照优先级高->低进行判断
/// 第二部: 已经ready & 无未展示dependency -> 展示
- (void)bindedVCDidAppear;

/// 暂时隐藏当前VC绑定的Alerts
- (void)bindedVCDidDisappear;

// 建议使用此方法 添加Alert 并尝试展示
- (void)addAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;

/// 根据alertID找到AlertView (可能不存在, 或已经结束展示销毁, 也可能存在多个重名的, 所以要确保id不重复)
- (NSArray<id<XYZAlertEnableDispatchProtocal>> *)findAlertWithID:(NSString *)alertID;
@end

NS_ASSUME_NONNULL_END
