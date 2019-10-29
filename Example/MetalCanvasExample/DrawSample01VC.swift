//
//  ViewController.swift
//  MetalCanvasExample
//
//  Created by hideyuki machida on 2018/12/29.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import UIKit
import MetalKit
import MetalCanvas

class DrawSample01VC: UIViewController {

    @IBOutlet weak var imageRender: MCImageRenderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let renderSize: CGSize = CGSize.init(width: 720, height: 1280)

        // MTLCommandBufferを生成
        var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
        
        do {
            var destinationTexture: MCTexture = try MCTexture.init(renderSize: renderSize)

            // 画像テクスチャを生成
            let texture01: MCTexture = try MCTexture.init(URL: Bundle.main.url(forResource: "https___www.pakutaso.com_shared_img_thumb_YUK85_ossu15095452", withExtension: "jpg")!)
            let texture02: MCTexture = try MCTexture.init(URL: Bundle.main.url(forResource: "https___www.pakutaso.com_shared_img_thumb_SAYA151005538606", withExtension: "jpg")!)

            // キャンバスを生成
            let canvas: MCCanvas = try MCCanvas.init(destination: &destinationTexture, orthoType: .topLeft)

            var image01Mat: MCGeom.Matrix4x4 = MCGeom.Matrix4x4.init(scaleX: 0.1, scaleY: 0.1, scaleZ: 1.0)
            image01Mat.rotateAroundX(xAngleRad: 0.0, yAngleRad: 0.0, zAngleRad: 0.5)
            
            // キャンバスにプリミティブを描画
            try canvas.draw(commandBuffer: &commandBuffer, objects: [

                // キャンバスに画像を描画
                try MCPrimitive.Image.init(
                    texture: texture01,
                    ppsition: SIMD3<Float>.init(x: Float(renderSize.width / 2.0), y: Float(renderSize.height / 2.0), z: 0),
                    transform: image01Mat,
                    anchorPoint: .center
                ),
                try MCPrimitive.Image.init(
                    texture: texture02,
                    ppsition: SIMD3<Float>.init(x: 0, y: 0, z: 0),
                    transform: MCGeom.Matrix4x4.init(scaleX: 0.1, scaleY: 0.1, scaleZ: 1.0),
                    anchorPoint: .topLeft
                ),

                // キャンバスにポイントを描画
                MCPoint.init(
                    ppsition: SIMD3<Float>.init(x: 0, y: 0, z: 0),
                    color: MCColor.init(hex: "0xFF0000"), size: 200.0
                ),
                MCPoint.init(
                    ppsition: SIMD3<Float>.init(x: 300, y: 10, z: 0),
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
            print("エラー")
        }
    }


}

