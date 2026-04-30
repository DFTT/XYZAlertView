//
//  XYZAlertDispatch.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "XYZAlertDispatch.h"
#import "XYZAlertQueue.h"

@interface XYZAlertDispatch ()
// 当前调度器持有的弹窗队列
@property(nonatomic, strong) XYZAlertQueue *queue;
// 当前显示中的弹窗数组 (显示在上层的 即高优先级的 排序在前面)
@property(nonatomic, strong) NSMutableArray<id<XYZAlertDispatchAble>> *showingAlerts;

// 展示前验证当前VC/Window是否在展示中
/// 如果可以展示 需要返回vc.view
@property(nonatomic, copy) UIView * (^verifyBlock)(void);
@end

@implementation XYZAlertDispatch
{
    //
    __weak XYZAlertDispatch *_parent;
    XYZAlertDispatch * _Nullable (^_activeChildDispatchProvider)(void);

    // 处理中标记
    BOOL _dispatchScheduled;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = [[XYZAlertQueue alloc] init];
        _showingAlerts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray<id<XYZAlertDispatchAble>> *)findAlertWithID:(NSString *)alertID {
    if (!alertID || alertID.length == 0) {
        return @[];
    }
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:2];
    [_showingAlerts enumerateObjectsUsingBlock:^(id<XYZAlertDispatchAble>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.alertID isEqualToString:alertID]) {
            [marr addObject:obj];
        }
    }];
    [marr addObjectsFromArray:[_queue findItemsWithID:alertID]];
    
    return marr;
}

- (void)addAlerts:(NSArray<id<XYZAlertDispatchAble>> *)alerts {
    for (id<XYZAlertDispatchAble> tmp in alerts) {
        tmp.weakDispatch = self;
    }
    [_queue addItems:alerts];
    [self p__setNeedsDispatch];
}

#pragma mark - Private M
- (void)p__setNeedsDispatch {
    // 确保主线程调用
    if ([NSThread isMainThread]) {
        XYZAlertDispatch *root = [self p__rootDispatch];
        [root p__scheduleDispatch];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            XYZAlertDispatch *root = [self p__rootDispatch];
            [root p__scheduleDispatch];
        });
    }
}

- (XYZAlertDispatch *)p__rootDispatch {
    XYZAlertDispatch *root = self;
    NSHashTable<XYZAlertDispatch *> *visited = [NSHashTable weakObjectsHashTable];
    while (root.parent && NO == [visited containsObject:root]) {
        [visited addObject:root];
        root = root.parent;
    }
    return root;
}

- (void)p__scheduleDispatch {
    if (_dispatchScheduled) {
        return;
    }
    _dispatchScheduled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 主要是为了延迟一次runloop 合并多次调用, 其次保证主线程
        self->_dispatchScheduled = NO;
        [self p___dispatchInCurrentScope];
    });
}

- (NSArray<XYZAlertDispatch *> *)p__currentDispatchScope {
    if (_verifyBlock() == nil) {
        return @[];
    }
    
    NSMutableArray<XYZAlertDispatch *> *scope = [NSMutableArray arrayWithObject:self];
    NSHashTable<XYZAlertDispatch *> *visited = [NSHashTable weakObjectsHashTable];
    [visited addObject:self];
    
    XYZAlertDispatch *dispatch = self;
    while (dispatch) {
        XYZAlertDispatch *child = nil;
        if (dispatch.activeChildDispatchProvider) {
            child = dispatch.activeChildDispatchProvider();
        }
        if (child == nil || [visited containsObject:child]) {
            break;
        }
        if (child.verifyBlock() == nil) {
            break;
        }
        [scope addObject:child];
        [visited addObject:child];
        dispatch = child;
    }
    return scope;
}

- (NSArray<id<XYZAlertDispatchAble>> *)p__showingAlertsInScope:(NSArray<XYZAlertDispatch *> *)scope {
    NSMutableArray<id<XYZAlertDispatchAble>> *alerts = [NSMutableArray array];
    for (XYZAlertDispatch *dispatch in scope) {
        [alerts addObjectsFromArray:dispatch.showingAlerts];
    }
    [alerts sortUsingComparator:^NSComparisonResult(id<XYZAlertDispatchAble>  _Nonnull obj1, id<XYZAlertDispatchAble>  _Nonnull obj2) {
        if (obj1.priority < obj2.priority) {
            return NSOrderedDescending;
        }else if (obj1.priority > obj2.priority) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    return alerts;
}

- (void)p___dispatchInCurrentScope {
    // 获取当前链上所有的dispatch
    NSArray<XYZAlertDispatch *> *scope = [self p__currentDispatchScope];
    if (scope.count == 0) {
        return;
    }
    
    if (scope.count == 1 && scope.firstObject == self) {
        // 单页调度
        UIView *view = _verifyBlock();
        if (nil == view) {
            return;
        }
        id<XYZAlertDispatchAble> alert = nil;
        if (_showingAlerts.count > 0) {
            //
            [self p__restoreShowingAlerts:_showingAlerts];
            //
            __weak typeof(self) weakSelf = self;
            alert = [_queue next:^BOOL(id<XYZAlertDispatchAble> _Nonnull obj) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf == nil) {
                    return NO;
                }
                return [strongSelf p___isCanShowCheck:obj showingAlerts:strongSelf.showingAlerts];
            }];
            if (alert == nil) { return; }
            // 移除
            [_queue removeItem:alert];
            // 即将显示 是否需要隐藏其它显示中的
            if (alert.exclusiveBehavior == XYZAlertExclusiveBehaviorHiddenOther) {
                for (id<XYZAlertDispatchAble> tmp in _showingAlerts) {
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
            //
            if (self.someAlertDidShow != nil) {
                self.someAlertDidShow(alert);
            }
        }
        
    }else {
        // 跨dispatch调度
        
        // 恢复临时隐藏的
        NSArray<id<XYZAlertDispatchAble>> *showingAlerts = [self p__showingAlertsInScope:scope];
        [self p__restoreShowingAlerts:showingAlerts];
        // 开始新一轮的调度
        NSMutableArray<id<XYZAlertDispatchAble>> *queuedAlerts = [NSMutableArray array];
        for (XYZAlertDispatch *dispatch in scope) {
            [queuedAlerts addObjectsFromArray:[dispatch.queue itemsSnapshot]];
        }
        if (queuedAlerts.count == 0) {
            return;
        }
        XYZAlertQueue *scopeQueue = [[XYZAlertQueue alloc] init];
        [scopeQueue addItems:queuedAlerts];
        
        id<XYZAlertDispatchAble> alert = nil;
        XYZAlertDispatch *alertOwnerDispatch = nil;
        if (showingAlerts.count > 0) {
            alert = [scopeQueue next:^BOOL(id<XYZAlertDispatchAble>  _Nonnull obj) {
                return [self p___isCanShowCheck:obj showingAlerts:showingAlerts];
            }];
            if (alert == nil) {
                return;
            }
            alertOwnerDispatch = alert.weakDispatch;
            
            // 即将显示 是否需要隐藏其它显示中的
            if (alert.exclusiveBehavior == XYZAlertExclusiveBehaviorHiddenOther) {
                for (id<XYZAlertDispatchAble> tmp in showingAlerts) {
                    [tmp dispatchAlertTmpHidden:YES];
                }
            }
        }else {
            alert = [scopeQueue popItem];
            if (alert == nil) {
                return;
            }
            alertOwnerDispatch = alert.weakDispatch;
        }
        
        UIView *view = alertOwnerDispatch.verifyBlock();
        if (view == nil) {
            return;
        }
        
        // 从原owner队列中移除
        [alertOwnerDispatch.queue removeItem:alert];
        
        [alert dispatchAlertViewShowOn:view];
        [alertOwnerDispatch.showingAlerts insertObject:alert atIndex:0];
        //
        if (alertOwnerDispatch.someAlertDidShow != nil) {
            alertOwnerDispatch.someAlertDidShow(alert);
        }
    }
}

- (void)p__restoreShowingAlerts:(NSArray<id<XYZAlertDispatchAble>> *)showingAlerts {
    if (showingAlerts.count == 0) {
        return;
    }
    
    __block BOOL thisAfterNeedHidden = NO;
    [showingAlerts enumerateObjectsUsingBlock:^(id<XYZAlertDispatchAble>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
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

- (BOOL)p___isCanShowCheck:(id<XYZAlertDispatchAble>)alert
             showingAlerts:(NSArray<id<XYZAlertDispatchAble>> *)showingAlerts {
    if (showingAlerts.count == 0) {
        return YES;
    }
    
    for (id<XYZAlertDispatchAble> showingObj in showingAlerts) {
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
- (void)alertDidReady:(id<XYZAlertDispatchAble>)alert {
    [self p__setNeedsDispatch];
}
- (void)alertDidRemoveFromSuperView:(id<XYZAlertDispatchAble>)alert {
    [_showingAlerts removeObject:alert];
    [_queue removeItem:alert]; // 这行其实是为了容错 可以不加
    if (self.someAlertDidDismiss != nil) { self.someAlertDidDismiss(alert); }

    [self p__setNeedsDispatch];
}

@end


@implementation XYZAlertDispatch (Parent)

- (XYZAlertDispatch *)parent {
    return _parent;
}

- (void)setParent:(XYZAlertDispatch *)parent {
    _parent = parent;
}

- (XYZAlertDispatch * _Nullable (^)(void))activeChildDispatchProvider {
    return _activeChildDispatchProvider;
}
- (void)setActiveChildDispatchProvider:(XYZAlertDispatch * _Nullable (^)(void))activeChildDispatchProvider {
    _activeChildDispatchProvider = [activeChildDispatchProvider copy];
}
@end






@implementation XYZAlertDispatch (Private_Internal)

+ (instancetype)distachWithVerifyBlock:(UIView * _Nonnull (^)(void))block {
    XYZAlertDispatch *tmp = [[XYZAlertDispatch alloc] init];
    tmp.verifyBlock = [block copy];
    return tmp;
}

- (void)bindedVCDidAppear {
    [self p__setNeedsDispatch];
}

- (void)bindedVCDidDisappear {
    for (id<XYZAlertDispatchAble> tmp in _showingAlerts) {
        [tmp dispatchAlertTmpHidden:YES];
    }
}
@end
