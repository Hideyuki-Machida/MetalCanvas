//
//  DrawSample04VC.swift
//  MetalCanvasExample
//
//  Created by hideyuki machida on 2019/06/16.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import UIKit
import MetalKit
import MetalCanvas
import Photos

@available(iOS 12.0, *)
class DrawSample04VC: UIViewController {
    /////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var imageRender: MCImageRenderView!
    /////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let renderSize: CGSize = CGSize.init(width: 720, height: 1280)
        
		let url = Bundle.main.url(forResource: "matte_sample", withExtension: "jpg")!
		print("url")
		print(url)
		let imageSource: CGImageSource = CGImageSourceCreateWithURL(url as CFURL, nil)!
		let portraitEffectsMatteDataInfo: [String : AnyObject]! = CGImageSourceCopyAuxiliaryDataInfoAtIndex(imageSource, 0, kCGImageAuxiliaryDataTypePortraitEffectsMatte) as? [String : AnyObject]
		
		do {
			var matteData: AVPortraitEffectsMatte = try AVPortraitEffectsMatte(fromDictionaryRepresentation: portraitEffectsMatteDataInfo)
			var depthDataMap: CVPixelBuffer = matteData.mattingImage
		} catch {
			
		}
		
		
        // MTLCommandBufferを生成
        var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
        
        do {
            var destinationTexture: MCTexture = try MCTexture.init(renderSize: renderSize)
            
            // 画像テクスチャを生成
            var texture01: MCTexture = try MCTexture.init(
                URL: Bundle.main.url(
                    //forResource: "https___www.pakutaso.com_shared_img_thumb_SAYA151005538606",
                    forResource: "https___www.pakutaso.com_shared_img_thumb_YUK85_ossu15095452",
                    withExtension: "jpg"
                    )!
            )
            
            // キャンバスを生成
            let canvas: MCCanvas = try MCCanvas.init(destination: &destinationTexture, orthoType: .topLeft)
            
            var faceItem: MCVision.Detection.FaceDetection = MCVision.Detection.FaceDetection.init()
            //face
            var pb: CVPixelBuffer = try texture01.getPixelBuffer()
            var img = CIImage.init(cvImageBuffer: pb)
            
            let faces: [MCVision.Detection.FaceDetection.Item] = try faceItem.detection(pixelBuffer: &pb, renderSize: CGSize.init(width: texture01.width, height: texture01.width), onDetection: { (faces: [MCVision.Detection.FaceDetection.Face]) in
            })
            
            // キャンバスに描画したいプリミティブをセット
            try canvas.draw(commandBuffer: &commandBuffer, objects: [
                
                // キャンバスに画像を描画
                try MCPrimitive.Image.init(
                    texture: texture01,
                    ppsition: MCGeom.Vec3D.init(x: Float(renderSize.width / 2.0), y: Float(renderSize.height / 2.0), z: 0),
                    transform: MCGeom.Matrix4x4.init(scaleX: 0.3, scaleY: 0.3, scaleZ: 1.0),
                    anchorPoint: .center
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
            print("エラー")
        }
    }
}
