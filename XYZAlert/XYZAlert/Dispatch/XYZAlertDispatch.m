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
    // 显示在上层的 排序在后面
    NSMutableArray<id<XYZAlertEnableDispatchProtocal>> *_showingAlerts;
    
    UIView * (^_verifyBlock)(void); // 展示前需要验证 当前VC/Window是否在展示中
    
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[XYZAlertQueue alloc] init];
        _showingAlerts = [[NSMutableArray alloc] init];
    }
    return self;
}
+ (instancetype)distachWithVerifyBlock:(UIView * _Nonnull (^)(void))block {
    XYZAlertDispatch *tmp = [[XYZAlertDispatch alloc] init];
    tmp->_verifyBlock = [block copy];
    return tmp;
}

- (void)addAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts {
    for (id<XYZAlertEnableDispatchProtocal> tmp in alerts) {
        tmp.weakDispatch = self;
    }
    [_queue addItems:alerts];
    [self p__tryDispatch];
}
- (void)bindedVCDidAppear {
    for (id<XYZAlertEnableDispatchProtocal> tmp in _showingAlerts) {
        [tmp dispatchAlertTmpHidden:NO];
    }
    [self p__tryDispatch];
}
- (void)bindedVCDidDisappear {
    for (id<XYZAlertEnableDispatchProtocal> tmp in _showingAlerts) {
        [tmp dispatchAlertTmpHidden:YES];
    }
}

- (void)p__tryDispatch {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 主要是为了延迟一次runloop ()
        // 其次保证主线程
        [self p___dispatch];
    });
}
- (void)p___dispatch {
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
        [alert dispatchAlertViewShowOn:view];
        [_showingAlerts addObject:alert];
    }
}

#pragma mark - XYZAlertLifeProtocal
- (void)alertDidReady:(id<XYZAlertEnableDispatchProtocal>)alert {
    [self p__tryDispatch];
}
- (void)alertDidRemoveFromSuperView:(id<XYZAlertEnableDispatchProtocal>)alert {
    [_showingAlerts removeObject:alert];
    [self p__tryDispatch];
}

@end
