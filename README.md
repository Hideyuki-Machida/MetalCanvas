# MetalCanvas


## サンプルコード

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

```
do {
	// MTLCommandBufferを生成
	var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
	
	// キャンバスを生成
	let canvas: MCCanvas = try MCCanvas.init(destination: &destinationTexture, orthoType: .topLeft)
	
	// キャンバスにプリミティブを描画
	try canvas.draw(commandBuffer: &commandBuffer, objects: [
	
		// キャンバスにポイントを描画
		MCPoint.init(
			ppsition: MCGeom.Vec3D.init(x: 0, y: 0, z: 0),
			color: MCColor.init(hex: "0xFF0000"), size: 200.0
		),
		MCPoint.init(
			ppsition: MCGeom.Vec3D.init(x: 300, y: 10, z: 0),
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


## サンプルコード 画像描画

[DrawSample01VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample01VC.swift)


## サンプルコード リアルタイム描画

[DrawSample02VC.swift](https://github.com/Hideyuki-Machida/MetalCanvas/blob/master/Example/MetalCanvasExample/DrawSample02VC.swift)
