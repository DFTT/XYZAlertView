//
//  UIViewController+XYZAlert.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "UIViewController+XYZAlert.h"
#import <objc/runtime.h>

@implementation UIViewController (XYZAlert)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void(^__swizzleSel)(Class, SEL, SEL) = ^(Class aClass, SEL originalSelector, SEL swizzledSelector) {
            
            Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
            BOOL didAddMethod = class_addMethod(aClass,
                                                originalSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod));
            if (didAddMethod) {
                class_replaceMethod(aClass,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        };
        
        SEL originalSelector_1 = @selector(viewDidAppear:);
        SEL swizzledSelector_1 = @selector(xyzAlert_viewDidAppear:);
        __swizzleSel([self class], originalSelector_1, swizzledSelector_1);
        

        SEL originalSelector_2 = @selector(viewDidDisappear:);
        SEL swizzledSelector_2 = @selector(xyzAlert_viewDidDisappear:);
        __swizzleSel([self class], originalSelector_2, swizzledSelector_2);
    });
}


#pragma mark - Visiable
- (BOOL)canShowAlert {
    if (self.isAppear == NO) {
        return NO;
    }
    if (self.view.window == nil) {
        return NO;
    }
    BOOL transitioning = NO;
    @try {
        transitioning = [[self.navigationController valueForKey:@"_isTransitioning"] boolValue];
    }
    @catch (NSException *exception) {
        
    }
    if (transitioning) {
        // 转场中
        return NO;
    }
    return YES;
}

- (BOOL)isAppear {
    return [objc_getAssociatedObject(self, @selector(isAppear)) boolValue];
}
- (void)setIsAppear:(BOOL)appear {
    objc_setAssociatedObject(self, @selector(isAppear), @(appear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - VC life
- (void)xyzAlert_viewDidAppear:(BOOL)animation {
    [self xyzAlert_viewDidAppear:animation];
    
    [self setIsAppear:YES];
    
    [[self alertDispahIfExist] bindedVCDidAppear];
}

- (void)xyzAlert_viewDidDisappear:(BOOL)animation {
    [self xyzAlert_viewDidDisappear:animation];
    
    [self setIsAppear:NO];
    
    [[self alertDispahIfExist] bindedVCDidDisappear];
}

#pragma mark - Lazy
- (nullable XYZAlertDispatch *)alertDispahIfExist {
    return objc_getAssociatedObject(self, @selector(alertDispah));
}

- (XYZAlertDispatch *)alertDispah {
    XYZAlertDispatch *dispath = objc_getAssociatedObject(self, @selector(alertDispah));
    if (nil == dispath) {
        __weak typeof(self) weakSelf = self;
        dispath = [XYZAlertDispatch distachWithVerifyBlock:^UIView *{
            return [weakSelf canShowAlert] ? weakSelf.view : nil;
        }];
        objc_setAssociatedObject(self, @selector(alertDispah), dispath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dispath;
}


@end
