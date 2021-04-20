//
//  XYZHookTool.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XYZHookTool : NSObject
+ (void)xyz_swizzleMethodForClass:(Class)aClass originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;
@end

NS_ASSUME_NONNULL_END
