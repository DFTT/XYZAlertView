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
- (void)addAlerts:(NSArray<id<XYZAlertDispatchAble>> *)alerts;

// 根据alertID找到AlertView (可能不存在, 或已经结束展示销毁, 也可能存在多个重名的, 所以要确保id不重复)
- (NSArray<id<XYZAlertDispatchAble>> *)findAlertWithID:(NSString *)alertID;

// 有弹窗展示时调用
@property (nonatomic, nullable, copy) void(^someAlertDidShow)(id<XYZAlertDispatchAble>);

// 有弹窗结束时调用
@property (nonatomic, nullable, copy) void(^someAlertDidDismiss)(id<XYZAlertDispatchAble>);

@end


// 当有父/子控制器且需要跨dispatch协调弹窗时, 可以手动设置这个关系
@interface XYZAlertDispatch (Parent)

/// 父控制器弹窗调度器。
/// 注意: 需要在子VC触发展示调度前绑定。默认不会自动绑定, 避免普通场景额外创建父级dispatch。
@property (nonatomic, weak, nullable) XYZAlertDispatch *parent;

/// 子VC弹窗调度器(提供当前激活态的子vc)
/// 需要在触发展示前设置并返回正确的子VC。
@property (nonatomic, copy, nullable) XYZAlertDispatch *_Nullable (^activeChildDispatchProvider)(void);

@end



/// 内部私有方法 勿直接调用
@interface XYZAlertDispatch (Private_Internal)

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
