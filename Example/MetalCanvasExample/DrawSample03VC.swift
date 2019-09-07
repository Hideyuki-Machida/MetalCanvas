//
//  DrawSample03VC.swift
//  MetalCanvasExample
//
//  Created by hideyuki machida on 2019/09/01.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import UIKit
import MetalKit
import MetalCanvas

class DrawSample03VC: UIViewController {
	
	/////////////////////////////////////////////////////////////////////////////////////
	@IBOutlet weak var imageRender: MCImageRenderView!
	/////////////////////////////////////////////////////////////////////////////////////

	override func viewDidLoad() {
		super.viewDidLoad()
		if #available(iOS 11.0, *) {
			let faceDetector: MCVision.Detection.Face = MCVision.Detection.Face()
			//faceDetector.detection(pixelBuffer: &<#T##CVPixelBuffer#>, renderSize: <#T##CGSize#>, onDetection: <#T##(([MCVision.Detection.Face.Face]) -> Void)##(([MCVision.Detection.Face.Face]) -> Void)##([MCVision.Detection.Face.Face]) -> Void#>)
		} else {
			// Fallback on earlier versions
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	fileprivate func draw() {
	}
}
