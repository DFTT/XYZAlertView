//
//  XYZAlertQueue.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import <Foundation/Foundation.h>
#import "XYZAlertProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface XYZAlertQueue : NSObject

- (BOOL)isEmpty;

- (int)count;

/// 下个展示的
/// - Parameter canShowCheck: 和显示中的那部分比较
- (nullable id<XYZAlertDispatchAble>)next:(BOOL(^)(id<XYZAlertDispatchAble>))canShowCheck;

// 根据优先级 取出
- (nullable id<XYZAlertDispatchAble>)popItem;

// 移除
- (void)removeItem:(id<XYZAlertDispatchAble>)item;

// 根据优先级 进入队列
- (void)addItem:(id<XYZAlertDispatchAble>)item;
- (void)addItems:(NSArray<id<XYZAlertDispatchAble>> *)items;

/// 根据alertID找到AlertView (可能不存在, 或已经结束展示销毁, 也可能存在多个重名的, 所以要确保id不重复)
- (NSArray<id<XYZAlertDispatchAble>> *)findItemsWithID:(NSString *)alertID;
@end

NS_ASSUME_NONNULL_END
