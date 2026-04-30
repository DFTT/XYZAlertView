//
//  XYZDispatchDemoTabVC.m
//  XYZAlert
//
//  父子调度域 Demo 入口：TabBarController
//  结构：tabVC -> [SubVC-A, SubVC-B, SubVC-C]
//  调度域：tabVC 为 root，各 subVC 为子 dispatch
//

#import "XYZDispatchDemoTabVC.h"
#import "XYZDispatchDemoSubVC.h"
#import "UIViewController+XYZAlert.h"

@implementation XYZDispatchDemoTabVC

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray<NSString *> *tabTitles = @[@"Tab A", @"Tab B", @"Tab C"];
    NSArray<UIColor *> *bgColors = @[
        [UIColor colorWithRed:0.90 green:0.95 blue:1.00 alpha:1.0],
        [UIColor colorWithRed:0.90 green:1.00 blue:0.92 alpha:1.0],
        [UIColor colorWithRed:1.00 green:0.95 blue:0.88 alpha:1.0],
    ];

    NSMutableArray *vcs = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        XYZDispatchDemoSubVC *vc = [[XYZDispatchDemoSubVC alloc] init];
        vc.tabIndex = i + 1;
        vc.view.backgroundColor = bgColors[i];
        vc.tabBarItem = [[UITabBarItem alloc] initWithTitle:tabTitles[i] image:nil tag:i];
        [vcs addObject:vc];
    }
    self.viewControllers = vcs;

    // 父子调度域建立必须在 viewControllers 赋值后、用户交互前完成
    [self p__setupDispatch];
}

- (void)p__setupDispatch {
    __weak typeof(self) weakSelf = self;

    // 1. root dispatch 提供当前激活的子 dispatch
    self.alertDispatch.activeChildDispatchProvider = ^XYZAlertDispatch * _Nullable{
        return weakSelf.selectedViewController.alertDispatch;
    };

    // 2. 每个子 VC 绑定父 dispatch（setParent: 不会触发调度，可安全提前设置）
    for (UIViewController *vc in self.viewControllers) {
        vc.alertDispatch.parent = self.alertDispatch;
    }

    // 3. 监听 tabVC 级别弹窗事件（不会跨 dispatch 冒泡，仅收到 tabVC 自身 dispatch 的事件）
    self.alertDispatch.someAlertDidShow = ^(id<XYZAlertDispatchAble> alert) {
        NSLog(@"[TabVC Dispatch] ⬆️ 展示: %@", alert.alertID);
    };
    self.alertDispatch.someAlertDidDismiss = ^(id<XYZAlertDispatchAble> alert) {
        NSLog(@"[TabVC Dispatch] ⬇️ 结束: %@", alert.alertID);
    };
}

@end
