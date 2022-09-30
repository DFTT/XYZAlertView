//
//  XYZAlertDispatch.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "XYZAlertProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYZAlertDispatch : NSObject <XYZAlertLifeProtocal>

// 使用此方法 添加Alert 并尝试展示
- (void)addAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;

/// 根据alertID找到AlertView (可能不存在, 或已经结束展示销毁, 也可能存在多个重名的, 所以要确保id不重复)
- (NSArray<id<XYZAlertEnableDispatchProtocal>> *)findAlertWithID:(NSString *)alertID;

@end



/// 内部私有方法
@interface XYZAlertDispatch (PrivateInternal)

/// 创建一个调度器 绑定
/// @param block 用来检测VC是否显示中, 如果显示中返回一个vc.view用来承载alert
+ (instancetype)distachWithVerifyBlock:(UIView *_Nullable (^)(void))block;

/// 调度合适的Alert进行展示
/// 规则:
/// 第一步: 按照优先级高->低进行判断
/// 第二部: 已经ready & 无未展示dependency -> 展示
- (void)bindedVCDidAppear;

/// 暂时隐藏当前VC绑定的Alerts
- (void)bindedVCDidDisappear;

@end
NS_ASSUME_NONNULL_END
