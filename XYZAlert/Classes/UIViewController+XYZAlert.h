//
//  UIViewController+XYZAlert.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import <UIKit/UIKit.h>
#if __has_include("XYZAlertDispatch.h")
#import "XYZAlertDispatch.h"
#else
#import "Dispatch/XYZAlertDispatch.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XYZAlert)

@property (nonatomic, strong, readonly) XYZAlertDispatch *alertDispatch;

@end

NS_ASSUME_NONNULL_END
