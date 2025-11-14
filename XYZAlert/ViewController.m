//
//  ViewController.m
//  XYZAlert
//
//  Created by 大大东 on 2021/4/13.
//

#import "ViewController.h"
#import "UIViewController+XYZAlert.h"
#import "XYZSystemAlertView.h"
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
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 200, 50);
    [btn setTitle:@"SimpleAlet样式 点击循环展示" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_____XYZSimpleAlet) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3 * 1);
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(0, 0, 200, 50);
    [btn2 setTitle:@"depend 展示" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(_____dependAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    btn2.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 3 * 2);
    
    
    
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(30, 0, 300, 50)];
    tf.placeholder = @"我是输入框";
    [self.navigationController.navigationBar addSubview:tf];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hiddenKB)];
    [self.navigationItem setRightBarButtonItem:item];
}
- (void)hiddenKB {
    [self.navigationController.view endEditing:YES];
}
- (void)_____dependAlert {
    XYZSystemAlertViewActionBtn *act1 = [XYZSystemAlertViewActionBtn actionWithName:@"点击跳转测试页面" clickCallback:^{
        [self.navigationController pushViewController:[ViewController new] animated:YES];
    }];
    XYZSystemAlertView *alert1 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题1" msg:@"我的是描述描述描述描述描述描述"];
    [alert1 addActionBtn:act1];
    alert1.alertID = @"1";
    
    XYZSystemAlertView *alert2 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题2" msg:@"我的是描述描述描述描述描述描述"];
    [alert2 addActionBtn:act1];
    alert2.alertID = @"2";
    
    XYZSystemAlertView *alert3 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题3" msg:@"我的是描述描述描述描述描述描述"];
    [alert3 addActionBtn:act1];
    alert3.alertID = @"3";
    alert3.showOnView = self.navigationController.view;

    
//    [alert1 setReadyAndTryDispath];
//    [alert2 setReadyAndTryDispath];
//    [alert3 setReadyAndTryDispath];
    
    
//    [alert1 addDependencyAlertID:@"2"];
//    [alert2 addDependencyAlertID:@"3"];
    
    alert1.priority = 3;
    alert2.priority = 2;
    alert3.priority = 1;
    
    alert1.exclusiveBehavior = XYZAlertExclusiveBehaviorHiddenOther;
    
//    [alert1 addDependencyAlertID:@"3"];
    
    [self.alertDispah addAlerts:@[alert1, alert2, alert3]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert1 setCancelAndRemoveFromDispatch];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert2 setReadyAndTryDispath];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert3 setReadyAndTryDispath];
    });

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
