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
}

- (void)_____dependAlert {
    XYZSystemAlertView *alert1 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题1" msg:@"我的是描述描述描述描述描述描述"];
    XYZSystemAlertViewActionBtn *ac1 = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
        NSLog(@"0");
    }];
    [alert1 addActionBtn:ac1];
    [alert1 setDidReady:NO];
    alert1.alertID = @"1";
    
    XYZSystemAlertView *alert2 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题2" msg:@"我的是描述描述描述描述描述描述"];
    XYZSystemAlertViewActionBtn *act2 = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
        NSLog(@"0");
    }];
    [alert2 addActionBtn:act2];
    [alert2 setDidReady:NO];
    alert2.alertID = @"2";
    
    XYZSystemAlertView *alert3 = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题3" msg:@"我的是描述描述描述描述描述描述"];
    XYZSystemAlertViewActionBtn *act3 = [XYZSystemAlertViewActionBtn actionWithName:@"确认" clickCallback:^{
        NSLog(@"0");
    }];
    [alert3 setDidReady:NO];
    [alert3 addActionBtn:act3];
    alert3.alertID = @"3";

    
//    [alert1 setDidReady:YES];
//    [alert2 setDidReady:YES];
//    [alert3 setDidReady:YES];
    
    alert1.hideOnTouchOutside = YES;
    alert2.hideOnTouchOutside = YES;
    alert3.hideOnTouchOutside = YES;
    
    
    [alert1 addDependencyAlerID:@"2"];
    [alert2 addDependencyAlerID:@"3"];
    
//    alert1.priority = 1;
//    alert2.priority = 2;
//    alert3.priority = 3;
    
    [self.alertDispah dispatchAlerts:@[alert1, alert2, alert3]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert1 setDidReady:YES];
        NSLog(@"1 已完成 但依赖2未完成");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert2 setDidReady:YES];
            NSLog(@"2 已完成 但依赖3未完成");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"3 已完成 先展示3");
                [alert3 setDidReady:YES];
            });
        });
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
        _alert = [[XYZSystemAlertView alloc] initWithTitle:@"我是标题" msg:@"我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述我是描述"];
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
    
    _alert.hideOnTouchOutside = YES;
    [_alert showInView:self.view];
}

@end
