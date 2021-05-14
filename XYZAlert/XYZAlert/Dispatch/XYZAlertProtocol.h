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

// 准备完成的主动回调 (调度管理将立即开始尝试展示)
- (void)alertDidReady:(id<XYZAlertEnableDispatchProtocal>)alert;
// 展示完毕已经移除的主动回调
- (void)alertDidRemoveFromSuperView:(id<XYZAlertEnableDispatchProtocal>)alert;

@end






typedef NS_ENUM(NSInteger, XYZAlertState) {
    XYZAlertStatePrepare = 0,   // 准备中
    XYZAlertStateReady,     // 已经准备好 可以接受展现调度
    XYZAlertStateShowing,   // 展现中
    XYZAlertStateTmpHidden, // 绑定的页面消失 所以临时被隐藏
    XYZAlertStateEnd,       // 结束销毁
};

@protocol XYZAlertEnableDispatchProtocal <NSObject>

// 唯一标示
@property (nonatomic, copy, nullable) NSString *alertID;

// 优先级
@property (nonatomic, assign) int priority;

// 状态
@property (nonatomic, assign, readonly) XYZAlertState curState;
// 标记已准备好, 立即尝试进行展示
- (void)setReadyAndTryDispath;

// 可以覆盖其它弹窗
@property (nonatomic, assign) BOOL enableCoverOther;

// 依赖其他弹窗的标识数组
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
