//
//  XYZAlertView.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/19.
//

#import "XYZAlertView.h"

@interface XYZAlertView ()

@end

@implementation XYZAlertView

#pragma mark - XYZAlertEnableDispatchProtocal

@synthesize weakDispatch;
@synthesize alertID;
@synthesize priority;
@synthesize curState;
@synthesize exclusiveBehavior;
@synthesize dependencyAlertIDSet;

- (void)setReadyAndTryDispath {
    if (curState == XYZAlertStatePrepare) {
        curState = XYZAlertStateReady;
        [weakDispatch alertDidReady:self];
    }
}
- (void)setCancelAndRemoveFromDispatch {
    if (curState != XYZAlertStateEnd) {
        [self removeFromSuperview];
        curState = XYZAlertStateEnd;
        [weakDispatch alertDidRemoveFromSuperView:self];
    }
}
- (void)addDependencyAlertID:(NSString *)alertid {
    if (!alertid || alertid.length == 0) {
        return;
    }
    NSMutableSet<NSString *> *mset = nil;
    NSSet<NSString *>         *set = dependencyAlertIDSet;
    if (set) {
        if ([set isKindOfClass:[NSMutableSet class]]) {
            mset = (NSMutableSet *)set;
        }else {
            mset = [set mutableCopy];
        }
    }else {
        mset = [[NSMutableSet alloc] init];
    }
    [mset addObject:alertid];
    dependencyAlertIDSet = mset;
}
- (void)dispatchAlertViewShowOn:(UIView *)view {
    [self showOnView:view];
    curState = XYZAlertStateShowing;
}
- (void)dispatchAlertTmpHidden:(BOOL)hidden {
    if (hidden) {
        curState = XYZAlertStateTmpHidden;
        self.hidden = YES;
    }else {
        curState = XYZAlertStateShowing;
        self.hidden = NO;
    }
}
#pragma mark - avoidKeyBoard
- (void)setAutoAvoidKeyboard:(BOOL)autoAvoidKeyboard {
    if (_autoAvoidKeyboard != autoAvoidKeyboard) {
        _autoAvoidKeyboard = autoAvoidKeyboard;
        if (autoAvoidKeyboard) {
            [self observeKeyboardNotify];
        }else {
            [self rmKeyboardNotifyObserver];
        }
    }
}
- (void)observeKeyboardNotify {
    [self rmKeyboardNotifyObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kb_willShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kb_willHidden:) name:UIKeyboardWillHideNotification object:nil];

}
- (void)rmKeyboardNotifyObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
- (void)kb_willShow:(NSNotification *)notify {
    [self p_reciveKeyboardNotification:notify frWillShow:YES];
}
- (void)kb_willHidden:(NSNotification *)notify {
    [self p_reciveKeyboardNotification:notify frWillShow:NO];
}
- (void)p_reciveKeyboardNotification:(NSNotification *)notify frWillShow:(BOOL)willShow {
    if (self.window == nil) {
        return;
    }

    CGRect kbToRect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    CGRect alertRect = [self.containerAlertView convertRect:self.containerAlertView.bounds toView:self.window];

    CGFloat offsetY = CGRectGetMaxY(alertRect) - CGRectGetMinY(kbToRect);
    CGAffineTransform transf = CGAffineTransformIdentity;
    if (willShow) {
        if (offsetY <= 0) {
            return;
        }
        transf = CGAffineTransformMakeTranslation(0, -offsetY + self.avoidKeyboardOffsetY);
    }
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 animations:^{
        self.containerAlertView.transform = transf;
    }];
}


- (void)reciveKeyboardNotification:(NSNotification *)notify {
    if (self.window == nil) {
        return;
    }
    CGRect kbToRect = [notify.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration = [notify.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    BOOL kbToShow = CGRectGetMinY(kbToRect) < [UIScreen mainScreen].bounds.size.height;
    CGRect alertRect = [self.containerAlertView convertRect:self.containerAlertView.bounds toView:self.window];
    
    CGFloat offsetY = CGRectGetMaxY(alertRect) - CGRectGetMinY(kbToRect);
    CGAffineTransform transf = CGAffineTransformIdentity;
    if (kbToShow) {
        if (offsetY <= 0) {
            return;
        }
        transf = CGAffineTransformMakeTranslation(0, -offsetY);
    }
    
    [UIView animateWithDuration:animationDuration > 0 ? animationDuration : 0.2 animations:^{
        self.containerAlertView.transform = transf;
    }];
}
#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        if ([UIScreen mainScreen].bounds.size.width == 320) {
            _containerAlertViewMaxSize = CGSizeMake(280, 400);
        }else {
            _containerAlertViewMaxSize = CGSizeMake(310, 500);
        }
        curState = XYZAlertStatePrepare;
        _containerAlertViewRoundValue = 10;
        _backAlpha  = 0.3;
        
        _hideOnTouchOutside = YES;
        self.autoAvoidKeyboard = YES;
    }
    return self;
}



- (void)showOnView:(UIView *)view {
    if (_showOnView) {
        view = _showOnView;
    }
    if (!view) {
        return;
    }
    [view addSubview:self];
    
    
    self.frame = view.bounds;
    self.backgroundColor = nil;
    
    self.containerAlertView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerAlertView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.containerAlertView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.containerAlertView.widthAnchor constraintEqualToConstant:_containerAlertViewMaxSize.width].active =YES;
    [self.containerAlertView.heightAnchor constraintLessThanOrEqualToConstant:_containerAlertViewMaxSize.height].active =YES;
    
    self.containerAlertView.alpha = 0.2;
    self.containerAlertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.backAlpha];
        self.containerAlertView.transform = CGAffineTransformIdentity;
        self.containerAlertView.alpha = 1.0;
    }];
}

- (void)dismissWithAnimation:(BOOL)animation {
    void(^completion)(void) = ^(){
        [self removeFromSuperview];
        self->curState = XYZAlertStateEnd;
        [self->weakDispatch alertDidRemoveFromSuperView:self];
    };

    if (animation) {
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundColor = nil;
            self.containerAlertView.transform = CGAffineTransformMakeScale(.8, .8);
            self.containerAlertView.alpha = 0.2;
        }completion:^(BOOL finished) {
            completion();
        }];
    }else {
        completion();
    }
}


#pragma mark - override
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];

    if (_hideOnTouchOutside == NO) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    CGPoint point = [touches.anyObject locationInView:self];
    if (NO == CGRectContainsPoint(_containerAlertView.frame, point)) {
        [self dismissWithAnimation:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_containerAlertView.frame.size.height > 0 && _containerAlertView.layer.cornerRadius != _containerAlertViewRoundValue) {
        _containerAlertView.layer.cornerRadius = _containerAlertViewRoundValue;
    }
}

#pragma mark - Lazy
- (UIView *)containerAlertView {
    if (!_containerAlertView) {
        _containerAlertView = [[UIView alloc] init];
        _containerAlertView.clipsToBounds = YES;
        _containerAlertView.backgroundColor = UIColor.whiteColor;
        [self addSubview:_containerAlertView];
    }
    return _containerAlertView;
}

@end
