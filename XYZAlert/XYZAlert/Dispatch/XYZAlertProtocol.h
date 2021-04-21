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








@protocol XYZAlertEnableDispatchProtocal <NSObject>

// 通知调度器
@property (nonatomic, weak  ) id<XYZAlertLifeProtocal> weakDispatch;

// 唯一标示
@property (nonatomic, copy  ) NSString *alertID;

// 优先级
@property (nonatomic, assign) int priority;

// 是否已经准备完成
@property (nonatomic, assign, readonly) BOOL ready;
// 如果设置YES, 则立即尝试进行展示
- (void)setDidReady:(BOOL)ready;

// 可以覆盖其它弹窗
@property (nonatomic, assign) BOOL enableCoverOther;

// 依赖其他弹窗的标识数组
@property (nonatomic, readonly) NSSet<NSString *> *dependencyAlertIDSet;
// 添加展示前对其他弹窗的依赖 (依赖的alert展示结束后 自己才允许展示)
- (void)addDependencyAlerID:(NSString *)alertid;

// 展现
- (void)dispatchAlertViewShowOn:(UIView *)view;

@end


NS_ASSUME_NONNULL_END
