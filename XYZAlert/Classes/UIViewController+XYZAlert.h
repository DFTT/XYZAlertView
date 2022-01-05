//
//  UIViewController+XYZAlert.h
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import <UIKit/UIKit.h>
#import "XYZAlertDispatch.h"


NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XYZAlert)

- (void)dispathNewAlerts:(NSArray<id<XYZAlertEnableDispatchProtocal>> *)alerts;

@end

NS_ASSUME_NONNULL_END
