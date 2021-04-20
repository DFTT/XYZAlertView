//
//  XYZAlertDispatch.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "XYZAlertDispatch.h"
#import "XYZAlertQueue.h"

@implementation XYZAlertDispatch
{
    XYZAlertQueue *_queue;
    // 显示在上层的 排序在前面
    NSMutableArray<id<XYZAlertEnableDispatchProtocal>> *_showingAlerts;
    
    UIView * (^_verifyBlock)(void); // 展示前需要验证 当前VC/Window是否在展示中
    
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[XYZAlertQueue alloc] init];
    }
    return self;
}
+ (instancetype)distachWithVerifyBlock:(UIView * _Nonnull (^)(void))block {
    XYZAlertDispatch *tmp = [[XYZAlertDispatch alloc] init];
    tmp->_verifyBlock = [block copy];
    return tmp;
}
- (void)dispatchAlert:(id<XYZAlertEnableDispatchProtocal>)alert {
    [_queue addItem:alert];
    alert.weakDispatch = self;
    [self tryDispatch];
}
- (void)dispatchAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts {
    [_queue addItems:alerts];
    for (id<XYZAlertEnableDispatchProtocal> tmp in alerts) {
        tmp.weakDispatch = self;
    }
    [self tryDispatch];
}
- (void)tryDispatch {
    UIView *view = _verifyBlock();
    if (nil == view) {
        return;
    }
    id<XYZAlertEnableDispatchProtocal> alert = nil;
    if (_showingAlerts.count > 0) {
        alert = [_queue next];
        if (alert.enableCoverOther == NO) {
            // 本次不展示
            return;
        }
        [_queue removeItem:alert];
    }else {
        alert = [_queue popItem];
    }
    
    if (alert) {
        [_showingAlerts insertObject:alert atIndex:0];
        [alert dispatchAlertViewShowOn:view];
    }
}

#pragma mark - XYZAlertLifeProtocal
- (void)alertDidReady:(id<XYZAlertEnableDispatchProtocal>)alert {
    [self tryDispatch];
}
- (void)alertDidRemoveFromSuperView:(id<XYZAlertEnableDispatchProtocal>)alert {
    [_showingAlerts removeObject:alert];
    [self tryDispatch];
}

@end
