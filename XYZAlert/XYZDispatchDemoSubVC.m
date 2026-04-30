//
//  XYZDispatchDemoSubVC.m
//  XYZAlert
//
//  每个 Tab 子页面，提供 4 个测试场景：
//  ① SubVC 低优先级弹窗
//  ② TabVC 高优先级弹窗（HiddenOther，会隐藏 SubVC 弹窗）
//  ③ SubVC 超高优先级弹窗（CoverOther，打断当前展示）
//  ④ 依赖弹窗组（SubVC 弹窗依赖 TabVC 弹窗先结束）
//

#import "XYZDispatchDemoSubVC.h"
#import "UIViewController+XYZAlert.h"
#import "XYZSystemAlertView.h"
#import "ViewController.h"

@interface XYZDispatchDemoSubVC ()
@property (nonatomic, strong) UILabel *statusLabel;
@end

@implementation XYZDispatchDemoSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self p__setupUI];
    [self p__setupDispatchCallbacks];
}

#pragma mark - UI

- (void)p__setupUI {
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = [NSString stringWithFormat:@"Tab %ld — 父子调度域测试", (long)self.tabIndex];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];

    // 关闭按钮（右上角）
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"关闭 Demo" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(p__closeDemo) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:closeBtn];

    // 测试用例按钮（②③ 为自动时序演示，点击后无需额外操作）
    NSDictionary *cases = @{
        @0: @[@"① SubVC 弹窗（单独展示）",                          NSStringFromSelector(@selector(p__case1_subvcLow))],
        @1: @[@"② [自动] TabVC HiddenOther 打断 SubVC 弹窗",       NSStringFromSelector(@selector(p__case2_tabvcHigh))],
        @2: @[@"③ [自动] SubVC 紧急弹窗 CoverOther 叠加打断",      NSStringFromSelector(@selector(p__case3_subvcUrgent))],
        @3: @[@"④ [自动] 依赖链：SubVC 等待 TabVC 弹窗先结束",     NSStringFromSelector(@selector(p__case4_dependency))],
    };

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    for (int i = 0; i < (int)cases.count; i++) {
        NSArray *info = cases[@(i)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:info[0] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:NSSelectorFromString(info[1]) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderColor = UIColor.systemBlueColor.CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = 8;
        btn.contentEdgeInsets = UIEdgeInsetsMake(12, 14, 12, 14);
        [stack addArrangedSubview:btn];
    }
    [self.view addSubview:stack];

    // 状态日志
    UILabel *logTitle = [[UILabel alloc] init];
    logTitle.text = @"最近事件（SubVC dispatch 回调）：";
    logTitle.font = [UIFont systemFontOfSize:12];
    logTitle.textColor = UIColor.grayColor;
    logTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:logTitle];

    _statusLabel = [[UILabel alloc] init];
    _statusLabel.text = @"—";
    _statusLabel.textAlignment = NSTextAlignmentLeft;
    _statusLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    _statusLabel.textColor = UIColor.darkGrayColor;
    _statusLabel.numberOfLines = 0;
    _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_statusLabel];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [closeBtn.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [closeBtn.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-16],

        [titleLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:16],
        [titleLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:closeBtn.leadingAnchor constant:-8],

        [stack.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:30],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        [logTitle.topAnchor constraintEqualToAnchor:stack.bottomAnchor constant:28],
        [logTitle.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [logTitle.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        [_statusLabel.topAnchor constraintEqualToAnchor:logTitle.bottomAnchor constant:6],
        [_statusLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [_statusLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
    ]];
}

- (void)p__closeDemo {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Dispatch Callbacks

- (void)p__setupDispatchCallbacks {
    // 注意：someAlertDidShow/Dismiss 只监听本 dispatch 自身的事件，不会跨 dispatch 冒泡
    // tabVC dispatch 的事件通过 XYZDispatchDemoTabVC 内的 NSLog 查看
    __weak typeof(self) weakSelf = self;
    self.alertDispatch.someAlertDidShow = ^(id<XYZAlertDispatchAble> alert) {
        NSString *msg = [NSString stringWithFormat:@"[Tab %ld] ⬆️ 展示: %@",
                         (long)weakSelf.tabIndex, alert.alertID];
        NSLog(@"%@", msg);
        weakSelf.statusLabel.text = msg;
    };
    self.alertDispatch.someAlertDidDismiss = ^(id<XYZAlertDispatchAble> alert) {
        NSString *msg = [NSString stringWithFormat:@"[Tab %ld] ⬇️ 结束: %@",
                         (long)weakSelf.tabIndex, alert.alertID];
        NSLog(@"%@", msg);
        weakSelf.statusLabel.text = msg;
    };
}

#pragma mark - Alert Helper

- (XYZSystemAlertView *)p__makeAlertTitle:(NSString *)title
                                      msg:(NSString *)msg
                                  alertID:(NSString *)alertID {
    XYZSystemAlertView *alert = [[XYZSystemAlertView alloc] initWithTitle:title msg:msg];
    alert.alertID = alertID;
    __weak XYZSystemAlertView *weakAlert = alert;
    XYZSystemAlertViewActionBtn *closeBtn = [XYZSystemAlertViewActionBtn
                                             actionWithName:@"关闭"
                                             clickCallback:^{ [weakAlert dismissWithAnimation:true]; }];
    
    XYZSystemAlertViewActionBtn *pushBtn = [XYZSystemAlertViewActionBtn
                                             actionWithName:@"push"
                                             clickCallback:^{
        [self.navigationController pushViewController:[ViewController new] animated:true];
    }];
    [alert addActionBtn:closeBtn];
    [alert addActionBtn:pushBtn];
    [alert setReadyAndTryDispath];
    return alert;
}

#pragma mark - Case 1: SubVC 低优先级弹窗

/**
 预期行为：
 - 无其他弹窗时：立即展示在 SubVC.view 上
 - TabVC 高优先级弹窗存在时：排队等待
 */
- (void)p__case1_subvcLow {
    NSString *alertID = [NSString stringWithFormat:@"subvc-tab%ld-low", (long)self.tabIndex];
    XYZSystemAlertView *alert = [self p__makeAlertTitle:@"SubVC 弹窗"
                                                    msg:[NSString stringWithFormat:
                                                         @"来自 Tab %ld\npriority = 2\nexclusiveBehavior = CoverOther",
                                                         (long)self.tabIndex]
                                                alertID:alertID];
    alert.priority = 2;
    alert.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
    [self.alertDispatch addAlerts:@[alert]];
}

#pragma mark - Case 2: [自动] TabVC HiddenOther 打断 SubVC 弹窗

/**
 自动时序：
   t=0s  : SubVC 低优先级弹窗（priority=2）出现在 SubVC.view
   t=2.5s: TabVC 高优先级弹窗（priority=5, HiddenOther）自动入队
            → SubVC 弹窗被临时隐藏，TabVC 弹窗覆盖整个 tabVC.view
   关闭 TabVC 弹窗后：SubVC 弹窗自动恢复
 */
- (void)p__case2_tabvcHigh {
    __weak typeof(self) weakSelf = self;

    // Step 1 (t=0): SubVC 低优先级弹窗立即入队
    NSString *subID = [NSString stringWithFormat:@"case2-sub-tab%ld", (long)self.tabIndex];
    XYZSystemAlertView *subAlert = [self p__makeAlertTitle:@"SubVC 低优先级弹窗"
                                                       msg:@"priority = 2\n\n⏱ 2.5 秒后 TabVC 高优先级弹窗\n将自动打断并隐藏本弹窗"
                                                   alertID:subID];
    subAlert.priority = 2;
    subAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
    [self.alertDispatch addAlerts:@[subAlert]];

    // Step 2 (t=2.5s): TabVC 高优先级弹窗自动入队
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        NSString *tabID = [NSString stringWithFormat:@"case2-tab-tab%ld", (long)weakSelf.tabIndex];
        XYZSystemAlertView *tabAlert = [weakSelf p__makeAlertTitle:@"TabVC 高优先级弹窗"
                                                               msg:@"priority = 5 | HiddenOther\n\nSubVC 弹窗已被临时隐藏。\n关闭本弹窗后 SubVC 弹窗自动恢复。"
                                                           alertID:tabID];
        tabAlert.priority = 5;
        tabAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorHiddenOther;
        // 加入 tabVC dispatch，显示在 tabVC.view（覆盖 TabBar + 所有子页面）
        [weakSelf.tabBarController.alertDispatch addAlerts:@[tabAlert]];
    });
}

#pragma mark - Case 3: [自动] SubVC 紧急弹窗 CoverOther 叠加打断

/**
 自动时序：
   t=0s  : SubVC 低优先级弹窗（priority=2）出现
   t=2.5s: SubVC 紧急弹窗（priority=10, CoverOther）自动入队
            → 叠加在低优先级弹窗上方（不隐藏，直接覆盖）
   关闭紧急弹窗后：低优先级弹窗仍在，继续等待用户关闭
 */
- (void)p__case3_subvcUrgent {
    __weak typeof(self) weakSelf = self;

    // Step 1 (t=0): SubVC 低优先级弹窗立即入队
    NSString *lowID = [NSString stringWithFormat:@"case3-sub-low-tab%ld", (long)self.tabIndex];
    XYZSystemAlertView *lowAlert = [self p__makeAlertTitle:@"SubVC 低优先级弹窗"
                                                       msg:@"priority = 2\n\n⏱ 2.5 秒后紧急弹窗将自动叠加\n在本弹窗上方（CoverOther）"
                                                   alertID:lowID];
    lowAlert.priority = 2;
    lowAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
    [self.alertDispatch addAlerts:@[lowAlert]];

    // Step 2 (t=2.5s): SubVC 紧急弹窗自动入队
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!weakSelf) return;
        NSString *urgentID = [NSString stringWithFormat:@"case3-sub-urgent-tab%ld", (long)weakSelf.tabIndex];
        XYZSystemAlertView *urgentAlert = [weakSelf p__makeAlertTitle:@"⚠️ SubVC 紧急弹窗"
                                                                  msg:@"priority = 10 | CoverOther\n\n直接叠加在低优先级弹窗上方。\n关闭本弹窗后，低优先级弹窗依然存在。"
                                                              alertID:urgentID];
        urgentAlert.priority = 10;
        urgentAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
        [weakSelf.alertDispatch addAlerts:@[urgentAlert]];
    });
}

#pragma mark - Case 4: 依赖弹窗组

/**
 预期行为：
 1. TabVC 前置弹窗先展示（priority=5）
 2. SubVC 弹窗因依赖前置弹窗而排队等待，即使 priority < 5 也不会中途插入
 3. 关闭 TabVC 前置弹窗后，SubVC 弹窗自动展示

 注意：addDependencyAlertID: 表示"我依赖的那个弹窗必须先结束（被移出队列+消失）我才能展示"
 */
- (void)p__case4_dependency {
    NSString *triggerID = [NSString stringWithFormat:@"tabvc-dep-trigger-tab%ld", (long)self.tabIndex];
    NSString *depID     = [NSString stringWithFormat:@"subvc-dep-tab%ld", (long)self.tabIndex];

    // TabVC 前置弹窗（触发者）
    XYZSystemAlertView *tabAlert = [self p__makeAlertTitle:@"TabVC 前置弹窗"
                                                       msg:[NSString stringWithFormat:
                                                            @"priority = 5\n关闭后将触发\nSubVC 依赖弹窗（%@）", depID]
                                                   alertID:triggerID];
    tabAlert.priority = 5;
    tabAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorHiddenOther;

    // SubVC 依赖弹窗（等待者）
    XYZSystemAlertView *subAlert = [self p__makeAlertTitle:@"SubVC 依赖弹窗"
                                                       msg:[NSString stringWithFormat:
                                                            @"来自 Tab %ld\npriority = 3\n依赖：%@ 结束后才展示",
                                                            (long)self.tabIndex, triggerID]
                                                   alertID:depID];
    subAlert.priority = 3;
    subAlert.exclusiveBehavior = XYZAlertExclusiveBehaviorCoverOther;
    [subAlert addDependencyAlertID:triggerID];

    // 注意顺序：先加 tabVC 弹窗，再加 subVC 弹窗
    [self.tabBarController.alertDispatch addAlerts:@[tabAlert]];
    [self.alertDispatch addAlerts:@[subAlert]];
}

@end
