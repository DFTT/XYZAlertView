//
//  XYZAlertQueue.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "XYZAlertQueue.h"

@implementation XYZAlertQueue
{
    NSMutableArray<id<XYZAlertDispatchAble>> *_items;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

- (int)count {
    return (int)_items.count;
}
- (BOOL)isEmpty {
    return [self count] == 0;
}

- (NSArray<id<XYZAlertDispatchAble>> *)findItemsWithID:(NSString *)alertID {
    if (!alertID || alertID.length == 0) {
        return @[];
    }
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:2];
    [_items enumerateObjectsUsingBlock:^(id<XYZAlertDispatchAble>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.alertID isEqualToString:alertID]) {
            [marr addObject:obj];
        }
    }];
    return marr;
}

- (void)addItem:(id<XYZAlertDispatchAble>)item {
    if (!item || NO == [item conformsToProtocol:@protocol(XYZAlertDispatchAble)]) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    // 添加
    [_items addObject:item];
    // 按照优先级"降序"排列
    [_items sortUsingComparator:^NSComparisonResult(id<XYZAlertDispatchAble>  _Nonnull obj1, id<XYZAlertDispatchAble>  _Nonnull obj2) {
        
        if (obj1.priority < obj2.priority) {
            return NSOrderedDescending;
        }else if ((obj1.priority > obj2.priority)) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    dispatch_semaphore_signal(_lock);
}
- (void)addItems:(NSArray<id<XYZAlertDispatchAble>> *)items {
    if (!items || 0 == items.count) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    // 添加
    [_items addObjectsFromArray:items];
    // 按照优先级"降序"排列
    [_items sortUsingComparator:^NSComparisonResult(id<XYZAlertDispatchAble>  _Nonnull obj1, id<XYZAlertDispatchAble>  _Nonnull obj2) {
        
        if (obj1.priority < obj2.priority) {
            return NSOrderedDescending;
        }else if ((obj1.priority > obj2.priority)) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    dispatch_semaphore_signal(_lock);
}
- (void)removeItem:(id<XYZAlertDispatchAble>)item {
    if (nil == item || [self isEmpty]) {
        return ;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_items removeObject:item];
    dispatch_semaphore_signal(_lock);
}
- (id<XYZAlertDispatchAble>)next:(BOOL (^)(id<XYZAlertDispatchAble> _Nonnull))canShowCheck {
    if ([self isEmpty]) {
        return nil;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    __block id<XYZAlertDispatchAble> target = nil;
    [_items enumerateObjectsUsingBlock:^(id<XYZAlertDispatchAble> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (XYZAlertStateReady != obj.curState) {
            // 未准备好 跳过
            return;
        }
        if (obj.dependencyAlertIDSet.count <= 0) {
            if (NO == canShowCheck(obj)) {
                return;
            }
            // 准备好了 & 无依赖 直接使用
            target = obj;
            *stop  = YES;
            return;
        }
        for (id<XYZAlertDispatchAble> alert in _items) {
            if ([obj.dependencyAlertIDSet containsObject:alert.alertID]) {
                // 有依赖未展示 跳过
                return;
            }
        }
        if (NO == canShowCheck(obj)) {
            return;
        }
        // 准备好了 & 有依赖但都已完成 直接使用
        target = obj;
        *stop  = YES;
    }];
    dispatch_semaphore_signal(_lock);
    return target;
}
- (id<XYZAlertDispatchAble>)popItem {
    if ([self isEmpty]) {
        return nil;
    }
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    __block NSInteger targetIdx = -1;
    __block id<XYZAlertDispatchAble> target = nil;
    [_items enumerateObjectsUsingBlock:^(id<XYZAlertDispatchAble> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (XYZAlertStateReady != obj.curState) {
            // 未准备好 跳过
            return;
        }
        if (obj.dependencyAlertIDSet.count <= 0) {
            // 准备好了 & 无依赖 直接使用
            target = obj;
            targetIdx = idx;
            *stop  = YES;
            return;
        }
        for (id<XYZAlertDispatchAble> alert in _items) {
            if ([obj.dependencyAlertIDSet containsObject:alert.alertID]) {
                // 有依赖未展示 跳过
                return;
            }
        }
        // 准备好了 & 有依赖但都已完成 直接使用
        target = obj;
        targetIdx = idx;
        *stop  = YES;
    }];
    if (targetIdx >= 0) {
        [_items removeObjectAtIndex:targetIdx];
    }
    dispatch_semaphore_signal(_lock);
    
    return target;
}
@end
