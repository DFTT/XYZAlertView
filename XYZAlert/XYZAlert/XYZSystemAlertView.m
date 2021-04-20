//
//  XYZSystemAlertView.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/20.
//

#import "XYZSystemAlertView.h"

@implementation XYZSystemAlertViewAction
+ (instancetype)actionWithName:(NSString *)name clickCallback:(dispatch_block_t)action {
    XYZSystemAlertViewAction *act = [[XYZSystemAlertViewAction alloc] init];
    act.name  = name;
    act.action = action;
    return act;
}

@end




@interface XYZSystemAlertView()
{
    NSMutableArray<XYZSystemAlertViewAction *> *_actions;
}
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *msgLabel;
@end
@implementation XYZSystemAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDidReady:YES];
    }
    return self;
}
- (instancetype)initWithTitle:(NSString *)title msg:(NSString *)msg {
    if (self = [self initWithFrame:CGRectZero]) {
        _title = title;
        _message = msg;
    }
    return self;
}

- (void)addAction:(XYZSystemAlertViewAction *)action {
    if (!action) {
        return;
    }
    if (!_actions) {
        _actions = [[NSMutableArray alloc] initWithCapacity:2];
    }
    [_actions addObject:action];
    if (_actions.count > 2) {
        [_actions removeObjectAtIndex:0];
    }
}

#pragma mark - override
//- (BOOL)ready {
//    return YES;
//}

- (void)showInView:(UIView *)view {
    UIView *bgview = self.containerAlertView;
    
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 15;
    stack.distribution = UIStackViewDistributionEqualSpacing;
    
    if (_title.length > 0 || _attributeTitle.length > 0) {
        if (_attributeTitle.length > 0) {
            self.titleLabel.attributedText = _attributeTitle;
        }else {
            self.titleLabel.text = _title;
        }
        [stack addArrangedSubview:self.titleLabel];
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel.heightAnchor constraintEqualToConstant:20].active = YES;
    }
    
    if (_message.length > 0 || _attributeMessage.length > 0) {
        if (_attributeMessage.length > 0) {
            self.msgLabel.attributedText = _attributeMessage;
        }else {
            self.msgLabel.text = _message;
        }
        [stack addArrangedSubview:self.msgLabel];
    }
    
    [bgview addSubview:stack];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [stack.topAnchor constraintEqualToAnchor:bgview.topAnchor constant:20].active = YES;
    [stack.leftAnchor constraintEqualToAnchor:bgview.leftAnchor constant:15].active = YES;
    [stack.rightAnchor constraintEqualToAnchor:bgview.rightAnchor constant:-15].active = YES;
    [stack.bottomAnchor constraintLessThanOrEqualToAnchor:bgview.bottomAnchor constant:-20].active = YES;
    
    if (_actions.count > 0) {
        UIStackView *hstack = [[UIStackView alloc] init];
        hstack.spacing = 0;
        hstack.distribution = UIStackViewDistributionFillEqually;
        [_actions enumerateObjectsUsingBlock:^(XYZSystemAlertViewAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton *btn = [self btn_WithAction:obj];
            btn.tag = idx;
            [hstack addArrangedSubview:btn];
        }];
        [bgview addSubview:hstack];
        hstack.translatesAutoresizingMaskIntoConstraints = NO;
        [hstack.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:15].active = YES;
        [hstack.leftAnchor constraintEqualToAnchor:bgview.leftAnchor].active = YES;
        [hstack.rightAnchor constraintEqualToAnchor:bgview.rightAnchor].active = YES;
        [hstack.bottomAnchor constraintEqualToAnchor:bgview.bottomAnchor].active = YES;
        [hstack.heightAnchor constraintEqualToConstant:49].active = YES;
    }
    
    [super showInView:view];
}

#pragma mark - get
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        label.textColor = UIColor.blackColor;
        
        _titleLabel = label;
    }
    return _titleLabel;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:17];
        label.textColor = [UIColor colorWithRed:0x33/255.0 green:0x33/255.0 blue:0x33/255.0 alpha:1];
        _msgLabel = label;
    }
    return _msgLabel;
}
- (UIButton *)btn_WithAction:(XYZSystemAlertViewAction *)act {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [btn setTitle:act.name forState:UIControlStateNormal];
    [btn setAttributedTitle:act.attributeName forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn_clcik:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}
#pragma mark - action
- (void)btn_clcik:(UIButton *)btn {
    _actions[btn.tag].action();
}
@end
