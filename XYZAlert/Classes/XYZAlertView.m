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
{
    UIViewPropertyAnimator *_dismissAnimator;
    NSLayoutConstraint *_containerWidthConstraint;
    NSLayoutConstraint *_containerHeightConstraint;
    NSLayoutConstraint *_containerCenterYConstraint;
}
@synthesize containerAlertView = _containerAlertView;

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
    if (curState == XYZAlertStateEnd) {
        return;
    }
    // 先结束状态，防止移除视图的子类回调再次取消。
    curState = XYZAlertStateEnd;
    id<XYZAlertLifeProtocal> dispatch = weakDispatch;
    UIViewPropertyAnimator *animator = _dismissAnimator;
    _dismissAnimator = nil;
    // 主动取消时丢弃旧动画的完成回调，避免影响同一实例再次展示。
    if (animator.state == UIViewAnimatingStateActive) {
        [animator stopAnimation:YES];
    }
    _containerAlertView.transform = CGAffineTransformIdentity;
    _containerAlertView.alpha = 1.0;
    [self removeFromSuperview];
    [dispatch alertDidRemoveFromSuperView:self];
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
    curState = XYZAlertStateShowing;
    [self showOnView:view];
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
#pragma mark - layout configuration
- (void)setAutoAvoidKeyboard:(BOOL)autoAvoidKeyboard {
    _autoAvoidKeyboard = autoAvoidKeyboard;
    [self setNeedsLayout];
}

- (void)setAvoidKeyboardOffsetY:(CGFloat)avoidKeyboardOffsetY {
    _avoidKeyboardOffsetY = avoidKeyboardOffsetY;
    [self setNeedsLayout];
}

- (void)setContainerAlertViewMaxSize:(CGSize)containerAlertViewMaxSize {
    _containerAlertViewMaxSize = containerAlertViewMaxSize;
    _containerHeightConstraint.constant = containerAlertViewMaxSize.height;
    [self setNeedsLayout];
}

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _containerAlertViewMaxSize = CGSizeMake(310, 500);
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
    if (!view || _dismissAnimator) {
        return;
    }
    [view addSubview:self];
    self.frame = view.bounds;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = UIColor.clearColor;
    self.hidden = NO;
    curState = XYZAlertStateShowing;

    UIView *container = self.containerAlertView;
    if (!_containerWidthConstraint) {
        container.translatesAutoresizingMaskIntoConstraints = NO;
        UILayoutGuide *safe = self.safeAreaLayoutGuide;
        _containerWidthConstraint = [container.widthAnchor constraintEqualToConstant:_containerAlertViewMaxSize.width];
        _containerHeightConstraint = [container.heightAnchor constraintLessThanOrEqualToConstant:_containerAlertViewMaxSize.height];
        _containerCenterYConstraint = [container.centerYAnchor constraintEqualToAnchor:safe.centerYAnchor];
        [NSLayoutConstraint activateConstraints:@[
            _containerWidthConstraint, _containerHeightConstraint, _containerCenterYConstraint,
            [container.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor]
        ]];
    }
    container.transform = CGAffineTransformIdentity;
    container.alpha = 1.0;
    [self layoutIfNeeded];

    if (_animationType == XYZAlertViewShowAnimatonBounces) {
        container.transform = CGAffineTransformMakeScale(0.7, 0.7);
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.8
                            options:UIViewAnimationOptionCurveEaseInOut animations:^{
            container.transform = CGAffineTransformIdentity;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.backAlpha];
        } completion:nil];
    }else if (_animationType == XYZAlertViewShowAnimatonDown) {
        container.transform = CGAffineTransformMakeTranslation(0, -CGRectGetMaxY(container.frame));
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.3
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            container.transform = CGAffineTransformIdentity;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.backAlpha];
        } completion:nil];
    }else {
        container.transform = CGAffineTransformMakeScale(1.1, 1.1);
        container.alpha = 0.2;
        [UIView animateWithDuration:0.25 animations:^{
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.backAlpha];
            container.transform = CGAffineTransformIdentity;
            container.alpha = 1.0;
        }];
    }
}

- (void)dismissWithAnimation:(BOOL)animation {
    if (curState == XYZAlertStateEnd) {
        return;
    }
    if (!animation) {
        [self setCancelAndRemoveFromDispatch];
        return;
    }
    if (_dismissAnimator) {
        return;
    }
    _dismissAnimator = [[UIViewPropertyAnimator alloc] initWithDuration:0.2 curve:UIViewAnimationCurveEaseInOut animations:^{
        self.backgroundColor = UIColor.clearColor;
        self.containerAlertView.transform = CGAffineTransformMakeScale(.8, .8);
        self.containerAlertView.alpha = 0.2;
    }];
    _dismissAnimator.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    [_dismissAnimator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [weakSelf setCancelAndRemoveFromDispatch];
    }];
    [_dismissAnimator startAnimation];
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
    // shortcut: 仅避让停靠键盘，需支持浮动键盘时再添加边缘追踪。
    UIKeyboardLayoutGuide *keyboard = self.keyboardLayoutGuide;
    CGRect safe = self.safeAreaLayoutGuide.layoutFrame;
    _containerWidthConstraint.constant = MIN(_containerAlertViewMaxSize.width, MAX(0, CGRectGetWidth(safe)));
    [super layoutSubviews];

    CGFloat keyboardTop = CGRectGetMinY(keyboard.layoutFrame);
    CGFloat centeredBottom = CGRectGetMidY(safe) + CGRectGetHeight(_containerAlertView.bounds) / 2;
    CGFloat offsetY = 0;
    if (_autoAvoidKeyboard && keyboardTop < CGRectGetMaxY(safe) && centeredBottom > keyboardTop) {
        offsetY = keyboardTop - centeredBottom + _avoidKeyboardOffsetY;
    }
    if (_containerCenterYConstraint.constant != offsetY) {
        _containerCenterYConstraint.constant = offsetY;
    }

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
