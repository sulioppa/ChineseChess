![](/icon.png)
# 中国象棋（[English Click Here](/README.md)）
*中国象棋 - 免费的 iOS App（C & Obj-C & Swift）*

## App 一览
### 启动页 & 主页
![](ReadMeMedia/Launch&Home.png)

### 对弈模块
![](ReadMeMedia/Game.png)

![](ReadMeMedia/GameSettings&History.png)

### 摆设棋局模块
![](ReadMeMedia/File&Edit.png)

![](ReadMeMedia/FirstSide&CheckMate.png)

### 棋谱模块
![](ReadMeMedia/History&Play.png)

### 联机模块
![](ReadMeMedia/MultiPeer&Waitting.png)

***

## 版本记录
* 2017.10.11, 正式启动工程.
* 2018.2.24, 完成联机模块，开始开发AI.

## 功能一览
### 对弈模块
- 支持人机对弈，可以选择AI等级（目前 __AI 正在开发__ ， 使用 __PVS__ 算法）。
- 支持立即的悔棋，新局，设置。
- 支持反转棋盘，反向棋子。
- 支持背景音乐的开关。

### 摆设棋局模块
- 支持清除、初始化棋盘。
- 支持在合理的格点处移除、摆放一颗棋子。
- 支持载入棋谱进行对弈。

### 棋谱模块
- 支持棋谱的读(演示)，保存，删除。
- 支持棋谱的任意一步跳转，点击即可跳转到这一步的局面。
- 支持在当前局面跳转对弈。

### 联机模块
- 支持两人对弈，通过蓝牙或者局域网。
- 支持悔棋、认输、提和。
- 支持新局。

## AI一览（[参考前辈黄晨的网站](http://www.xqbase.com/computer/eleeye_intro.htm)）
### 棋盘棋子表示
- 棋盘：长度为256的数组。
- 棋子：16-31为红方棋子，依次为帥、仕仕、相相、馬馬、車車、炮炮、兵兵兵兵兵，32-47为黑方棋子，类似。

### 走法生成
- 短程类：帥仕相馬兵，走法预生成数组。
- 远程类：車炮，位行位列。
