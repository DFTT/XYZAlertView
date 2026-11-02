//
//  ViewController.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "ViewController.h"
#import "UIViewController+XYZAlert.h"
#import "XYZSystemAlertView.h"
#import "XYZDispatchDemoTabVC.h"
@interface ViewController ()
{
    int  _aa ;
    XYZSystemAlertView *_alert;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    NSArray<NSArray<NSString *> *> *items = @[
        @[@"系统样式：循环展示", NSStringFromSelector(@selector(_____XYZSimpleAlet))],
        @[@"依赖展示", NSStringFromSelector(@selector(_____dependAlert))],
        @[@"键盘避让示例", NSStringFromSelector(@selector(showKeyboardDemo))],
        @[@"父子调度域 Demo", NSStringFromSelector(@selector(showDispatchDemo))]
    ];
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:stack];
    for (NSArray<NSString *> *item in items) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:item[0] forState:UIControlStateNormal];
        [button addTarget:self action:NSSelectorFromString(item[1]) forControlEvents:UIControlEventTouchUpInside];
        [button.heightAnchor constraintEqualToConstant:44].active = YES;
        [stack addArrangedSubview:button];
    }
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor constant:16],
        [stack.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor constant:-16],
        [stack.leadingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.leadingAnchor constant:16],
        [stack.trailingAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.trailingAnchor constant:-16],
        [stack.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor constant:-32]
    ]];
}

- (void)showKeyboardDemo {
    XYZAlertView *alert = [[XYZAlertView alloc] init];
    UIView *container = alert.containerAlertView;
    UITextField *field = [[UITextField alloc] init];
    field.placeholder = @"输入文字，观察键盘避让";
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:field];
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    [close setTitle:@"完成" forState:UIControlStateNormal];
    [close addTarget:alert action:@selector(setCancelAndRemoveFromDispatch) forControlEvents:UIControlEventTouchUpInside];
    close.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:close];
    [NSLayoutConstraint activateConstraints:@[
        [field.topAnchor constraintEqualToAnchor:container.topAnchor constant:24],
        [field.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:16],
        [field.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-16],
        [field.heightAnchor constraintEqualToConstant:44],
        [close.topAnchor constraintEqualToAnchor:field.bottomAnchor constant:16],
        [close.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [close.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-16],
        [close.heightAnchor constraintEqualToConstant:44]
    ]];
    [alert showOnView:self.view];
    [field becomeFirstResponder];
}

- (void)showDispatchDemo {
    XYZDispatchDemoTabVC *demoVC = [[XYZDispatchDemoTabVC alloc] init];
    demoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:demoVC animated:true];
}
- (void)_____dependAlert {
    XYZSystemAlertView *first = [[XYZSystemAlertView alloc] initWithTitle:@"前置弹窗" msg:@"关闭后展示依赖弹窗。"];
    first.alertID = @"demo-dependency-first";
    first.priority = 1;
    __weak XYZSystemAlertView *weakFirst = first;
    [first addActionBtn:[XYZSystemAlertViewActionBtn actionWithName:@"关闭" clickCallback:^{
        [weakFirst dismissWithAnimation:YES];
    }]];

    XYZSystemAlertView *second = [[XYZSystemAlertView alloc] initWithTitle:@"依赖弹窗" msg:@"前置弹窗结束后展示。"];
    second.priority = 2;
    second.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
    [second addDependencyAlertID:first.alertID];
    __weak XYZSystemAlertView *weakSecond = second;
    [second addActionBtn:[XYZSystemAlertViewActionBtn actionWithName:@"关闭" clickCallback:^{
        [weakSecond dismissWithAnimation:YES];
    }]];

    [self.alertDispatch addAlerts:@[first, second]];
    [first setReadyAndTryDispath];
    [second setReadyAndTryDispath];
}
- (void)_____XYZSimpleAlet {
    [_alert dismissWithAnimation:NO];
    
    int maxIdx = 8;
    
    _aa++;
    
    if (_aa % maxIdx == 0) {
        _aa++;
    }
    
    
    if (_aa % maxIdx == 1) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:nil];
    }else if (_aa % maxIdx == 2) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:nil];
        XYZSystemAlertViewActionBtn *act = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
            NSLog(@"0");
        }];
        [act setImage:UIImage.actionsImage forState:UIControlStateNormal];
        [_alert addActionBtn:act];
    }
    else if (_aa % maxIdx == 3) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:nil msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述"];
    }else if (_aa % maxIdx == 4) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:nil msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述"];
        XYZSystemAlertViewActionBtn *act = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
            NSLog(@"0");
        }];
        XYZSystemAlertViewActionBtn *act1 = [XYZSystemAlertViewActionBtn actionWithName:@"取消" clickCallback:^{
            NSLog(@"1");
        }];
        [_alert addActionBtn:act];
        [_alert addActionBtn:act1];
    }
    else if (_aa % maxIdx == 5) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述"];
    }else if (_aa % maxIdx == 6) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述"];
        XYZSystemAlertViewActionBtn *act = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
            NSLog(@"0");
        }];
        [_alert addActionBtn:act];

    }else if (_aa % maxIdx == 7) {
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描"];
        XYZSystemAlertViewActionBtn *act = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
            NSLog(@"0");
        }];
        [act setImage:UIImage.removeImage forState:UIControlStateNormal];

        XYZSystemAlertViewActionBtn *act1 = [XYZSystemAlertViewActionBtn actionWithName:@"取消" clickCallback:^{
            NSLog(@"1");
        }];
        [_alert addActionBtn:act];
        [_alert addActionBtn:act1];
    }
    
    _alert.animationType = arc4random() % 3;
    [_alert showOnView:self.view];
}

@end
