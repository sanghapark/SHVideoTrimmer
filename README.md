# SHVideoTrimmer
[iOS] video trimmer view

You can select a particular interval of video and trim it out.

![ScreenShot](/img/img1.png)

**Usage**
```Swift
let rect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 35)
let options = 
    [SHVideoTrimmerView.MainColor : UIColor.yellowColor(),
    SHVideoTrimmerView.HandleColor : UIColor.brownColor(),
    SHVideoTrimmerView.PositionBarColor: UIColor.whiteColor()]
self.trimmerView = SHVideoTrimmerView(frame: rect, avAsset: avAsset, options: options)
trimmerView!.delegate = self
self.view.addSubview(strongSelf.trimmerView!)
```

**Delegate functions**
```Swift
protocol SHVideoTrimmerViewDelegate {
    func didChangeStartTime(startTime: Float64)
    func didChangePositionBar(startTime: Float64)
}
```
