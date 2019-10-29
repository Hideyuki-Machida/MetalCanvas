//
//  DrawSample02VC.swift
//  MetalCanvasExample
//
//  Created by hideyuki machida on 2019/05/15.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import UIKit
import MetalKit
import MetalCanvas

class DrawSample02VC: UIViewController {
    
    /////////////////////////////////////////////////////////////////////////////////////
    struct Dot {
        var position: SIMD3<Float>
        var velocity: SIMD3<Float>
        var color: MCColor
        var size: Float
        var renderSize: CGSize

        var point: MCPoint

        init(position: SIMD3<Float>, velocity: SIMD3<Float>, color: MCColor, size: Float, renderSize: CGSize) {
            self.position = position
            self.color = color
            self.velocity = velocity
            self.size = size
            self.renderSize = renderSize
            
            self.point = MCPoint.init(
                ppsition: position,
                color: color,
                size: size
            )
        }
        
        mutating func update() {
            self.position.x += self.velocity.x
            self.position.y += self.velocity.y
            
            if( self.position.x > Float(self.renderSize.width) ) {
                self.velocity.x = -Float.random(in: 0...10)
            }
            if( self.position.x < 0 ) {
                self.velocity.x = Float.random(in: 0...10)
            }
            
            if( self.position.y > Float(self.renderSize.height) ) {
                self.velocity.y = -Float.random(in: 0...10)
            }
            if( self.position.y < 0 ) {
                self.velocity.y = Float.random(in: 0...10)
            }
            
            self.point = MCPoint.init(
                ppsition: self.position,
                color: self.color,
                size: self.size
            )
        }

    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////////////////////////////////////
    enum DrawMode {
        case clear
        case load
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    /////////////////////////////////////////////////////////////////////////////////////
    @IBOutlet weak var imageRender: MCImageRenderView!
    /////////////////////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////
    let queue: DispatchQueue = DispatchQueue(label: "hideyuki.machida.MetalCanvasExample.queue")
    let len: Int = 100
    let renderSize: CGSize = CGSize.init(width: 720, height: 1280)
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate var dots: [Dot] = []

    var destinationTexture: MCTexture?
    // キャンバスを生成
    var canvas: MCCanvas?
    var drawMode: DrawMode = DrawMode.clear
    /////////////////////////////////////////////////////////////////////////////////////
    
    deinit {
        self.displayLink?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            self.destinationTexture = try MCTexture.init(renderSize: self.renderSize)
            self.canvas = try MCCanvas.init(destination: &self.destinationTexture!, orthoType: .topLeft, loadAction: MTLLoadAction.load)
        } catch {
            
        }

        for _:Int in 0..<self.len {
            let p: SIMD3<Float> = SIMD3<Float>.init(Float.random(in: 0...Float( self.renderSize.width )), Float.random(in: 0...Float( self.renderSize.height )), 0.0)
            let v: SIMD3<Float> = SIMD3<Float>.init(Float.random(in: 0...20) - 10, Float.random(in: 0...20) - 10, 0.0)
            let r: Float = Float.random(in: 0...1)
            let g: Float = Float.random(in: 0...1)
            let b: Float = Float.random(in: 0...1)
            let c: MCColor = MCColor.init(r: r, g: g, b: b, a: 1.0)
            let s: Int = Int.random(in: 1...50)
            self.dots.append( Dot( position: p, velocity: v, color: c, size: Float(s) , renderSize: self.renderSize) )
        }
        self.draw()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidRefresh))
        self.displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.displayLink?.invalidate()
    }
    
    @objc fileprivate func displayLinkDidRefresh() {
        self.draw()
    }

    fileprivate func draw() {
        // MTLCommandBufferを生成
        var commandBuffer: MTLCommandBuffer = MCCore.commandQueue.makeCommandBuffer()!
        
        do {

            ////////////////////////////////////////////////
            // 塗りつぶし
            switch self.drawMode {
            case .clear: try self.canvas!.fill(commandBuffer: &commandBuffer, color: MCColor.init(hex: "0x000000"))
            case .load: break
            }
            ////////////////////////////////////////////////
            
            var points: [MCPoint] = []
            let len: Int = self.dots.count
            for i: Int in 0..<len {
                self.dots[ i ].update()
                let point: MCPoint = self.dots[i].point
                points.append(point)
            }
            // キャンバスにプリミティブを描画
            try self.canvas!.draw(
                commandBuffer: &commandBuffer,
                objects: points
            )

            // MCImageRenderViewを更新（描画）
            self.imageRender?.update(
                commandBuffer: commandBuffer,
                texture: self.destinationTexture!,
                renderSize: self.renderSize,
                queue: self.queue
            )
        } catch {
            print("エラー")
        }
    }
}

extension DrawSample02VC {
    
    @IBAction func openMenu(_ sender: Any) {
        let action: UIAlertController = UIAlertController(title: "メニュー", message: "", preferredStyle:  UIAlertController.Style.actionSheet)
        
        let action001: UIAlertAction = UIAlertAction(title: "clear", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.drawMode = .clear
        })
        
        let action002: UIAlertAction = UIAlertAction(title: "load", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.drawMode = .load
        })
        
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
        })
        
        action.addAction(action001)
        action.addAction(action002)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }

}
