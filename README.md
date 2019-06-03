# MetalCanvas

[![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Xcode 10.2+](https://img.shields.io/badge/Xcode-10.2+-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)



## 概要

このフレームワークは、processingの思想に影響を受けています。<br>
processingにおけるOpenGLのように、Metalを少ない手続き・インターフェースで使えることを目指しています。<br>

少ないコードで キャンバスに絵を描くようにコードで絵を描きます。<br>
点や四角などのプリミティブの描画や画像処理。<br>
そういった事を簡単に行なえます。

---

Processing is a flexible software sketchbook and a language for learning how to code within the context of the visual arts. Since 2001, Processing has promoted software literacy within the visual arts and visual literacy within technology. There are tens of thousands of students, artists, designers, researchers, and hobbyists who use Processing for learning and prototyping.

---

#### 参考

* [processing](https://processing.org/)
* [openframeworks](https://openframeworks.cc/)
* [Flash BitmapData](https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/BitmapData.html)


#### Metal学習参考

* [Metal Programming Guide](https://developer.apple.com/library/archive/documentation/Miscellaneous/Conceptual/MetalProgrammingGuide/Introduction/Introduction.html
)
* [Metalを基礎から日本語で学べる書籍](https://qiita.com/shu223/items/19c7d98fc186562b4f57)


## Interface

* [MCCore](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/MetalCanvas/MCCore.swift): 初期化やCommandBufferの生成など
* [MCCanvas](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/MetalCanvas/MCCanvas.swift): 描画情報をセット
* [MCImageRenderView](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/MetalCanvas/MCImageRenderView.swift): CanvasのRender
* [MCColor](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/MetalCanvas/Color/MCColor.swift): 色に関する
* [MCGeom](https://github.com/Hideyuki-Machida/MetalCanvas/tree/master/MetalCanvas/Geom): Vector や Matrix
* [MCPrimitive](https://github.com/Hideyuki-Machida/MetalCanvas/tree/master/MetalCanvas/Primitive): PointやRectangle等のプリミティブ
* [MCFilter](https://github.com/Hideyuki-Machida/MetalCanvas/tree/master/MetalCanvas/Filter): 画像処理フィルター


## サンプルコード
* まず AppDelegate.swift → MCCore.setup で初期化します。
=======
## サンプル

### サンプルコード

```
import UIKit
import MetalCanvas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		do {
			// 初期化
			try MCCore.setup(contextPptions: [
				CIContextOption.workingColorSpace : CGColorSpaceCreateDeviceRGB(),
				CIContextOption.useSoftwareRenderer : NSNumber(value: false)
				])
		} catch {
			
		}
		return true
	}

```
<br />

* 実際に使う際には下記のサンプルコードの流れで使用します。
	* MTLCommandBufferを生成（[MTLCommandBufferについて](https://qiita.com/yuky_az/items/b557850ae9dc317f1570))
	* MCCanvasを生成
	* キャンバスに描画したいプリミティブをセット
	* MCImageRenderViewを更新（描画）
<br />

<span style="color: red">
<font color="red">
	※ 生成した commandBuffer は MCImageRenderView. updateでcommitされ、MCImageRenderViewに描画されます。
	<br />
	※ MTLCommandBufferは一度 commit されると、無効になります。
	<br />
	※ 動画のフレーム毎の処理のような繰り返し描画を行う場合には、都度 MTLCommandBuffer生成 → commit を繰り返します。
	
</font>
</span>

```
do {
	// MTLCommandBufferを生成
	var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
	
	// キャンバスを生成
	let canvas: MCCanvas = try MCCanvas.init(destination: &destinationTexture, orthoType: .topLeft)
	
	// キャンバスに描画したいプリミティブをセット
	try canvas.draw(commandBuffer: &commandBuffer, objects: [
	
		// キャンバスにポイントを描画
		MCPoint.init(
			psition: MCGeom.Vec3D.init(x: 0, y: 0, z: 0),
			color: MCColor.init(hex: "0xFF0000"), size: 200.0
		),
		MCPoint.init(
			psition: MCGeom.Vec3D.init(x: 300, y: 10, z: 0),
			color: MCColor.init(hex: "0xFFFF00"), size: 300.0
		)
	])
	
	// MCImageRenderViewを更新（描画）
	self.imageRender?.update(
		commandBuffer: commandBuffer,
		texture: destinationTexture,
		renderSize: renderSize,
		queue: nil
	)

} catch {
}
```


### サンプルコード 画像描画

* [DrawSample01VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample01VC.swift)


### サンプルコード リアルタイム描画

* [DrawSample02VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample02VC.swift)


## Installation

### [Carthage](https://github.com/Carthage/Carthage)

```
github "Hideyuki-Machida/MetalCanvas"
```


## Coming Soon

* Noise
* Filter
* Morphing
* Vision



