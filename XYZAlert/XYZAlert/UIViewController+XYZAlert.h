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

@property (nonatomic, strong, readonly) XYZAlertDispatch *alertDispah;


@end

NS_ASSUME_NONNULL_END
