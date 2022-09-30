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
    // 显示在上层的 即高优先级的 排序在前面
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

- (NSArray<id<XYZAlertEnableDispatchProtocal>> *)findAlertWithID:(NSString *)alertID {
    if (!alertID || alertID.length == 0) {
        return @[];
    }
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:2];
    [_showingAlerts enumerateObjectsUsingBlock:^(id<XYZAlertEnableDispatchProtocal>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.alertID isEqualToString:alertID]) {
            [marr addObject:obj];
        }
    }];
    [marr addObjectsFromArray:[_queue findItemsWithID:alertID]];
    
    return marr;
}

- (void)addAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts {
    for (id<XYZAlertEnableDispatchProtocal> tmp in alerts) {
        tmp.weakDispatch = self;
    }
    [_queue addItems:alerts];
    [self p__tryDispatch];
}


- (void)p__restoreShowingAlert {
    if (_showingAlerts.count == 0) {
        return;
    }
    
    __block BOOL thisAfterNeedHidden = NO;
    [_showingAlerts enumerateObjectsUsingBlock:^(id<XYZAlertEnableDispatchProtocal>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == 0) {
            // 第一个直接恢复显示
            [obj dispatchAlertTmpHidden:NO];
        }else {
            // 根据上一个的排它行为 决定自己是否可以取消隐藏
            [obj dispatchAlertTmpHidden:thisAfterNeedHidden];
        }
        // 更新 (一旦有一个高优先级HiddenOther, 后续全部隐藏即可 不需要在判断排它行为)
        if (thisAfterNeedHidden == NO) {
            thisAfterNeedHidden = obj.exclusiveBehavior == XYZAlertExclusiveBehaviorHiddenOther;
        }
    }];
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
        
        [self p__restoreShowingAlert];
        __weak typeof(self) weakSelf = self;
        alert = [_queue next:^BOOL(id<XYZAlertEnableDispatchProtocal> _Nonnull obj) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf == nil) {
                return NO;
            }
            return [strongSelf p___isCanShowCheck:obj];
        }];
        if (alert == nil) { return; }

        [_queue removeItem:alert];
     
        // 即将显示 是否需要隐藏其它显示中的
        if (alert.exclusiveBehavior == XYZAlertExclusiveBehaviorHiddenOther) {
            for (id<XYZAlertEnableDispatchProtocal> tmp in _showingAlerts) {
                [tmp dispatchAlertTmpHidden:YES];
            }
        }
    }else {
        
        alert = [_queue popItem];
        if (alert == nil) { return; }
    }
    
    if (alert) {
        [alert dispatchAlertViewShowOn:view];
        [_showingAlerts insertObject:alert atIndex:0];
    }
}

- (BOOL)p___isCanShowCheck:(id<XYZAlertEnableDispatchProtocal>)alert {
    for (id<XYZAlertEnableDispatchProtocal> showingObj in _showingAlerts) {
        if ([alert.dependencyAlertIDSet containsObject:showingObj.alertID]) {
            // 依赖展示中的 放弃
            return NO;
        }
        if (alert.priority <= showingObj.priority) {
            // 优先级不高于当前展示中的 放弃
            return NO;
        }
    }
    
    // 判断排它
    switch (alert.exclusiveBehavior) {
        case XYZAlertExclusiveBehaviorNone:
            // 不能排它 放弃展示
            return NO;
        case XYZAlertExclusiveBehaviorHiddenOther:
        {
            // 需要隐藏其他的  显示时再隐藏其他的
        }
            break;
            
        case XYZAlertExclusiveBehaviorCoverOther:
            //  nothing 直接展示即可覆盖
            break;
        default:
            break;
    }
    return YES;
}
#pragma mark - XYZAlertLifeProtocal
- (void)alertDidReady:(id<XYZAlertEnableDispatchProtocal>)alert {
    [self p__tryDispatch];
}
- (void)alertDidRemoveFromSuperView:(id<XYZAlertEnableDispatchProtocal>)alert {
    [_showingAlerts removeObject:alert];
    [_queue removeItem:alert]; // 这行其实是为了容错 可以不加
    
    [self p__tryDispatch];
}

@end






@implementation XYZAlertDispatch (PrivateInternal)

+ (instancetype)distachWithVerifyBlock:(UIView * _Nonnull (^)(void))block {
    XYZAlertDispatch *tmp = [[XYZAlertDispatch alloc] init];
    tmp->_verifyBlock = [block copy];
    return tmp;
}

- (void)bindedVCDidAppear {
    
    [self p__restoreShowingAlert];
    
    [self p__tryDispatch];
}

- (void)bindedVCDidDisappear {
    for (id<XYZAlertEnableDispatchProtocal> tmp in _showingAlerts) {
        [tmp dispatchAlertTmpHidden:YES];
    }
}
@end

