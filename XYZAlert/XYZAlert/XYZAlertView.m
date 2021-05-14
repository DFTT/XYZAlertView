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
@synthesize enableCoverOther;
@synthesize dependencyAlertIDSet;

- (void)setReadyAndTryDispath {
    if (curState == XYZAlertStatePrepare) {
        curState = XYZAlertStateReady;
        [weakDispatch alertDidReady:self];
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
-  (void)dispatchAlertTmpHidden:(BOOL)hidden {
    if (hidden) {
        curState = XYZAlertStateTmpHidden;
        self.hidden = YES;
    }else {
        curState = XYZAlertStateShowing;
        self.hidden = NO;
    }
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
        [self->weakDispatch alertDidRemoveFromSuperView:self];
        self->curState = XYZAlertStateEnd;
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
