# XYZAlertView


### 是什么
实现了一个调度逻辑，以实现单页面中多个弹窗的管理```XYZAlertDispatch``` 通过扩展绑定在了```UIViewController```，可以方便的访问到.
由于UI在各项目中通用性较差，所以简单实现了UI基类 ```XYZAlertView（默认实现了调度协议）```，实现了一个类似系统的简单Alert```XYZSystemAlertView``` .
UI类的使用可以脱离调度类

#### 已支持：
1. 队列颗粒度ViewController
2. 支持按照 优先级 顺序展示
3. 支持各弹窗之间添加依赖 依赖弹窗全部展示后 再展示自己
4. 支持先添加进队列 完成某些操作后在展示（比如请求数据后） 合适的时机调用```XYZAlertView: -setReadyAndTryDispath```即可, 状态可参见```XYZAlertView: curStete```
5. VC消失后 自动隐藏当前VC的弹窗 (目前直接hidden相应的Alert)
6. 可以任意弹窗单独覆盖全屏（提前设置```XYZAlertView: showOnView```为一个可以可以覆盖全屏的View即可, 比如NavVC.view / TabVC.view / KeyWindow ...）

#### TODO：
1. ... 
