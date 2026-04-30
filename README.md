# XYZAlertView

轻量、可扩展的 Alert 弹窗组件，支持与 ViewController 绑定、优先级/依赖/互斥/延迟展示、页面消失自动隐藏恢复等弹窗调度逻辑。

SheetView见 https://github.com/DFTT/XYZSheetView

## 一、特性

* 支持将弹窗绑定到特定 UIViewController 实例，管理同一页面内的多个弹窗。
* 支持弹窗优先级调度：高优先级弹窗可覆盖或隐藏低优先级弹窗（即使高优先级弹窗是后添加进队列的）。
* 支持弹窗之间的依赖关系：可指定某弹窗在其依赖的全部弹窗展示完毕(关闭)后再显示。
* 支持延迟或异步展示：弹窗可先加入队列，异步任务完成后调用 `setReadyAndTryDispath` 进行展示。
* 支持 UIViewController 消失后自动隐藏当前绑定弹窗，并在页面再次出现时自动恢复未结束的弹窗。
* 支持弹窗在任意 UIView 上显示（当前 VC.view／ window／自定义 view ），通过 `showOnView` 属性可提前设置承载层。
* 支持键盘弹出情况下自动偏移弹窗以避免遮挡，同时可自定义偏移距离。
* 支持手动开启父子调度域，在少量需要跨 VC 协调的场景中统一处理优先级、依赖和互斥。
* 核心类为 `XYZAlertView` 基类，可直接使用或继承定制。亦开箱提供类似系统样式的通用弹窗 `XYZSystemAlertView`。

## 二、安装

iOS 9.0 及以上。使用 Objective-C 编写，可在 Swift 项目中混编使用。

* 源码方式：将 `XYZAlert` 文件夹拖拽至项目中即可。

* CocoaPods：

  ```ruby
  source "https://github.com/DFTT/XYZPodspecs.git"
  pod 'XYZAlert'
  ```

## 三、核心类 & API 介绍

### `XYZAlertView`

弹窗基类，实现了调度协议 `XYZAlertEnableDispatchProtocol`，可单独使用或配合调度系统使用，可继承并实现自定义 UI、动画等。

* `priority`：弹窗优先级，值越大优先级越高，高优先级弹窗可中断低优先级弹窗展示。
* `dependencyAlerts`：设置本弹窗依赖的其他弹窗（可多个），当所有依赖弹窗结束后本弹窗才可展示（**注意：避免循环依赖**）。
* `showOnView`：默认弹窗显示在 VC.view 上；可设置为其它 UIView（如 window / 导航 VC.view / TabVC.view ）以实现覆盖全屏。
* `curState`：当前弹窗状态（如 ready／waiting／showing／finished）以便调度管理。
* `setReadyAndTryDispatch`：当异步任务完成、准备好展示弹窗时调用，应触发调度机制检查能否展示。
* 键盘适配相关属性（如 keyboardAvoidOffset 等）可调整弹窗在键盘弹起时的偏移。

### `XYZSystemAlertView`

系统样式弹窗，继承自 `XYZAlertView`，提供类似系统 Alert 的界面。

### `XYZAlertDispatch`

弹窗调度器，管理VC中的多个弹窗展示逻辑。

* 绑定于每个 UIViewController （通常通过 `vc.alertDispatch` 访问）用于管理该页面所有加入队列的弹窗。
* 方法如 `addAlerts:`、`findAlertWithID:` 用于弹窗队列的添加和查询。
* 自动监听 UIViewController 的 viewWillDisappear/viewDidAppear 生命周期，以实现页面消失时隐藏弹窗、页面重新出现时恢复弹窗的能力。
* `someAlertDidShow` / `someAlertDidDismiss` 可监听当前 dispatch 中弹窗的展示和结束。

默认情况下，每个 VC 的 dispatch 独立调度，互不影响。跨 VC 的统一调度是显式开启能力，库不会默认创建或绑定父子 dispatch，避免普通页面产生额外调度成本。

### 父子调度域

当页面结构类似 `navVC -> tabVC(vc1, vc2, vc3...)` 时，可能会有一个弹窗属于 `tabVC`，另一个弹窗属于当前选中的 `vc1`。如果它们需要统一处理优先级、依赖或互斥，可以手动将相关 dispatch 组成同一个调度域。

父级 dispatch 提供当前激活的子 dispatch：

```objc
tabVC.alertDispatch.activeChildDispatchProvider = ^XYZAlertDispatch *{
    return tabVC.selectedViewController.alertDispatch;
};
```

子级 dispatch 手动绑定父级 dispatch：

```objc
vc1.alertDispatch.parent = tabVC.alertDispatch;
vc2.alertDispatch.parent = tabVC.alertDispatch;
vc3.alertDispatch.parent = tabVC.alertDispatch;
```

弹窗仍然添加到自己的页面 dispatch：

```objc
[tabVC.alertDispatch addAlerts:@[globalAlert]];
[vc1.alertDispatch addAlerts:@[pageAlert]];
```

当父子关系建立后，任一 dispatch 中的 ready、dismiss、didAppear 都会向 root dispatch 合并触发一次调度。root 会收集当前 active 链路上的 queue/showing alerts 后统一仲裁。例如当前链路为 `tabVC.dispatch -> vc1.dispatch` 时，`tabVC` 级弹窗和 `vc1` 级弹窗会参与同一套优先级、依赖和互斥判断。

注意：

* `parent` 和 `activeChildDispatchProvider` 都需要在子 VC 触发展示调度前设置。
* 库不会自动为 `UINavigationController` / `UITabBarController` 设置调度域；需要跨 dispatch 协调时请手动设置。
* `showOnView` 只决定弹窗显示在哪个 view 上，不决定它和哪些弹窗一起调度。跨 VC 互斥/依赖请使用父子调度域。
