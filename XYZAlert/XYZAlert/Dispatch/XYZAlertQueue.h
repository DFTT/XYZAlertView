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

// 下个展示的
- (nullable id<XYZAlertEnableDispatchProtocal>)next;

// 根据优先级 取出
- (nullable id<XYZAlertEnableDispatchProtocal>)popItem;

// 移除
- (void)removeItem:(id<XYZAlertEnableDispatchProtocal>)item;

// 根据优先级 进入队列
- (void)addItem:(id<XYZAlertEnableDispatchProtocal>)item;
- (void)addItems:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)items;

@end

NS_ASSUME_NONNULL_END
