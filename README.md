## 前言
之前也写过很多小东西，只怪自己懒没有整理。庆幸我本人封装意识比较强，之后摘出来整理还算方便就一并放在了这个项目里。之前的东西都是用OC写的，这次用了Swift(api对OC做了兼融)，有不对的地方欢迎指正。欢迎加入`我的QQ群：700276016`交流心得。

## 代码目录

* `KSPageControl`
    *  一个类似于系统UIPageControl的东西，但是有个小小的原点过渡效果。
    *  demo中的媒体浏览页（KSMediaPickerViewer）中的页标指示就是用了这个。
* `KSButton`
    *  目录中有两个控件源文件，KSButton和KSBorderButton
    *  就是为UIButton增加了两个方法，可以根据UIControl.State设置背景色/边框颜色
* `KSDisclosureIndicator`
    *  目录中有三个控件源文件，KSIndicatorLabelControl、KSTriangleDisclosureIndicator和KSTriangleIndicatorButton
    *  KSIndicatorLabelControl为指示器类型Button的基类用CATextLayer实现，可继承后为Button自定义增加自己喜欢的指示器
    *  KSTriangleDisclosureIndicator为三角指示器，仅仅是不会切图也不想麻烦UI而已
    *  KSTriangleIndicatorButton继承自KSIndicatorLabelControl增加了可旋转的三角指示器，demo中选取器首页面导航栏中间的按钮就是利用了这个
* `KSMediaViewer`
    *  此类为范型类不可以被直接使用，主要功能就是浏览媒体或其他资源，为其增加放大的转场功能。
    *  demo中的媒体浏览页（KSMediaPickerViewer）就是继承了这个。
    *  demo源文件中有详细使用方法备注
* `KSSegmentedControl`
    *  类似于系统的UISegmentedControl为其增加了下标指示器，还增加了左右滑动时的下标移动动画
* `KSVideoPlayerView`
    *  一个简单的单例视频播放器，其中核心KSVideoLayer为单例，以免出现多个视频同时播放的问题
* `KSMediaPicker`
    *  今天的主角，一个按照《小红书》《Instagram》做的媒体选取器，拍照和录像都是简单实现。
    *  由于本人才疏学浅不知道如何录制1:1的视频，所以就阉割了视频1:1录制的功能，如有哪位大神知晓 请务必联系我，感激不尽。

## 个性化
* demo中所有的颜色全部使用KSExtension中的UIColor extension可以直接控制颜色。
* demo中的所有文字可以在KSMediaPicker.strings 中更改

## KSMediaPicker的部分截图
![pg1](https://github.com/kinsunlu/KSMediaPicker/blob/master/EG_1.PNG?raw=false)
![pg2](https://github.com/kinsunlu/KSMediaPicker/blob/master/EG_2.PNG?raw=false)
![pg3](https://github.com/kinsunlu/KSMediaPicker/blob/master/EG_3.PNG?raw=false)
![pg4](https://github.com/kinsunlu/KSMediaPicker/blob/master/EG_4.PNG?raw=false)
![pg5](https://github.com/kinsunlu/KSMediaPicker/blob/master/EG_5.PNG?raw=false)

## KSMediaPicker的视频介绍
点击查看[视频介绍](https://raw.githubusercontent.com/kinsunlu/KSMediaPicker/master/EG_Video.MP4)

