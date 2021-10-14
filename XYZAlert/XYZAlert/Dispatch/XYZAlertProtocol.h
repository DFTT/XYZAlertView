//
//  XYZAlertProtocol.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/20.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol XYZAlertEnableDispatchProtocal;


@protocol XYZAlertLifeProtocal <NSObject>

/// 准备结束的主动回调
/// @param alert alert
/// @param ready YES: 调度管理将立即开始尝试展示, NO: 放弃展示并从队列中移除
- (void)alert:(id<XYZAlertEnableDispatchProtocal>)alert readyed:(BOOL)ready;

// 展示完毕已经移除的主动回调
- (void)alertDidRemoveFromSuperView:(id<XYZAlertEnableDispatchProtocal>)alert;

@end





typedef NS_ENUM(NSInteger, XYZAlertExclusiveBehaviorType) {
    XYZAlertExclusiveBehaviorNone = 0,   // 不能排它, 即当前有展示中的alert 自己不能被展示
    XYZAlertExclusiveBehaviorCoverOther, // 覆盖其它, 即当前有展示中的alert 自己覆盖在上层
    XYZAlertExclusiveBehaviorHiddenOther,// 隐藏其它, 即当前有展示中的alert 自己把下层的hidden掉
};


typedef NS_ENUM(NSInteger, XYZAlertState) {
    XYZAlertStatePrepare = 0,   // 准备中
    XYZAlertStateReady,     // 已经准备好 可以接受展现调度
    XYZAlertStateShowing,   // 展现中
    XYZAlertStateTmpHidden, // 绑定的页面消失/被其它弹窗排斥 所以临时被隐藏
    XYZAlertStateEnd,       // 结束销毁
};

@protocol XYZAlertEnableDispatchProtocal <NSObject>

// 唯一标示
@property (nonatomic, copy, nullable) NSString *alertID;

// 状态
@property (nonatomic, assign, readonly) XYZAlertState curState;
// 标记已准备好, 立即尝试进行展示
- (void)setReadyAndTryDispath;
// 准备结束, 需要放弃本次展示并从队列中移除
- (void)setCancelAndRemoveFromDispatch;

// 优先级
/// 1. 调度时高优先级的优先处理
/// 2. 展示时优先级高的才能互斥掉其它Alert
@property (nonatomic, assign) int priority;

// 发生互斥时的行为
/// 展示时如果已经存在展示中的alert 则按照此行为进行排它操作
@property (nonatomic, assign) XYZAlertExclusiveBehaviorType exclusiveBehavior;

// 依赖其他弹窗的id组
/// 如果依赖的弹窗未能结束展示 自己将不会被展示
@property (nonatomic, readonly) NSSet<NSString *> *dependencyAlertIDSet;
// 添加展示前对其他弹窗的依赖 (依赖的alert展示结束后 自己才允许展示)
- (void)addDependencyAlertID:(NSString *)alertid;





// 调度器
@property (nonatomic, weak  ) id<XYZAlertLifeProtocal> weakDispatch;

// 被调度->展现
- (void)dispatchAlertViewShowOn:(UIView *)view;

// 被调度->临时隐藏/展现
- (void)dispatchAlertTmpHidden:(BOOL)hidden;
@end


NS_ASSUME_NONNULL_END
