//
//  XYZSystemAlertView.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/20.
//

#import "XYZSystemAlertView.h"

@implementation XYZSystemAlertViewActionBtn
{
    CALayer *_topLine;
    CALayer *_leftLine;
    CALayer *_righrLine;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat onePointLine = 1 / [UIScreen mainScreen].scale;
    
    if (_topLine) _topLine.frame = CGRectMake(0, 0, self.frame.size.width, onePointLine);
    
    if (_leftLine) _leftLine.frame = CGRectMake(0, 0, onePointLine, self.frame.size.height);
    
    if (_righrLine) _righrLine.frame = CGRectMake(0, self.frame.size.width - onePointLine, onePointLine, self.frame.size.height);
}

+ (instancetype)actionWithName:(NSString *)name clickCallback:(dispatch_block_t)action {
    XYZSystemAlertViewActionBtn *act = [XYZSystemAlertViewActionBtn buttonWithType:UIButtonTypeCustom];
    [act setTitle:name forState:UIControlStateNormal];
    [act setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
    [act addTarget:act action:@selector(p_clickAction) forControlEvents:UIControlEventTouchUpInside];
    act.action = action;
    return act;
}


- (void)addLineWith:(UIRectEdge)edges {
    if (edges & UIRectEdgeTop) {
        [_topLine removeFromSuperlayer];
        _topLine = [self crearLayer];
        [self.layer addSublayer:_topLine];

    }
    if (edges & UIRectEdgeRight) {
        [_righrLine removeFromSuperlayer];
        _righrLine = [self crearLayer];
        [self.layer addSublayer:_righrLine];
    }
    if (edges & UIRectEdgeLeft) {
        [_leftLine removeFromSuperlayer];
        _leftLine = [self crearLayer];
        [self.layer addSublayer:_leftLine];
    }
}
- (void)p_clickAction {
    _action();
}
- (CALayer *)crearLayer {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    return layer;
}

@end




@interface XYZSystemAlertView()
{
    NSMutableArray<XYZSystemAlertViewActionBtn *> *_actions;
}
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *msgLabel;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@end
@implementation XYZSystemAlertView


- (instancetype)initWithTitle:(NSString *)title msg:(NSString *)msg {
    if (self = [self initWithFrame:CGRectZero]) {
        _title = title;
        _message = msg;
    }
    return self;
}

- (void)addActionBtn:(XYZSystemAlertViewActionBtn *)action {
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

- (void)showOnView:(UIView *)view {
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
        [_actions enumerateObjectsUsingBlock:^(XYZSystemAlertViewActionBtn * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            [hstack addArrangedSubview:obj];
            if (idx == 0) {
                [obj addLineWith:UIRectEdgeTop];
            }else {
                [obj addLineWith:UIRectEdgeTop | UIRectEdgeLeft];
            }
        }];
        [bgview addSubview:hstack];
        hstack.translatesAutoresizingMaskIntoConstraints = NO;
        [hstack.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:15].active = YES;
        [hstack.leftAnchor constraintEqualToAnchor:bgview.leftAnchor].active = YES;
        [hstack.rightAnchor constraintEqualToAnchor:bgview.rightAnchor].active = YES;
        [hstack.bottomAnchor constraintEqualToAnchor:bgview.bottomAnchor].active = YES;
        [hstack.heightAnchor constraintEqualToConstant:49].active = YES;
    }
    
    
    [super showOnView:view];
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


@end
