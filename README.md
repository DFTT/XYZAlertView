# XYZAlertView


### 是什么
- 实现了一个调度逻辑，用来对单页面(VC)中多个弹窗的管理```XYZAlertDispatch``` , 可以通过```vc.alertDispah```方便的访问.
- 实现了一个UI基类```XYZAlertView```, 内部实现了调度协议```XYZAlertEnableDispatchProtocal```用来支持各种调度
- 由于各项目UI差异, 可以继承实现自己的AlertView基类, AlertView可以单独脱离调度类使用(在无多弹窗场景, 可以直接用来展示/移除) 
- 继承```XYZAlertView```实现了一个类似系统的通用Alert```XYZSystemAlertView```


#### 已支持：
1. 调度队列颗粒度ViewController
2. 支持按照```优先级```顺序展示 (如果是后添加的高优先级弹窗, 可以根据配置 覆盖/隐藏 已显示的低优先级弹窗)
3. 支持各弹窗之间添加```依赖```, 依赖弹窗全部展示结束后, 再展示自己
4. 支持先添加进队列, 完成异步操作后再展示（比如请求数据后）, 只需要在合适的时机调用```XYZAlertView: -setReadyAndTryDispath```即可, 状态可参见```XYZAlertView: curStete```
5. 支持ViewController消失后, 自动隐藏当前VC绑定的弹窗 (目前直接hidden相应的Alert), ViewController再次出现时, 自动恢复未结束的Alert
6. 支持弹窗覆盖全屏, 即可以展示在非绑定的vc.view上, 可以自动控制弹窗仅覆盖当前VC.View/全屏/任意其他view（提前设置```XYZAlertView: showOnView```为一个可以可以覆盖全屏的View即可, 比如NavVC.view / TabVC.view / KeyWindow ...）
7. 支持自动躲避键盘, 自动向上偏移/恢复 (可修正偏移距离)

#### 使用:
    - 源码安装: 拖拽XYZAlert文件夹到项目中即可
    - cocoapods: 
    ```
        source "https://github.com/DFTT/XYZPodspecs.git"
        pod 'XYZAlert'
    ``` 
    
