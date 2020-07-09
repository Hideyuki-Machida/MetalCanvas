//
//  FaceDetection.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/31.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//
/*
import Foundation
import Vision

extension MCVision.Detection {
	public class Face {
		
		//private let queue: DispatchQueue = DispatchQueue(label: "MetalCanvas.FaceDetection.queue", attributes: .concurrent)
        private let queue: DispatchQueue = DispatchQueue(label: "MetalCanvas.FaceDetection.queue")
		
		public struct Face {
			public var boundingBox: CGRect = CGRect.init()
			public var allPoints: [CGPoint] = []
			public init() {}
		}
		

		
		
		public enum ErrorType: Error {
			case trackingError
		}
		
		private var detectionRequests: [VNDetectFaceLandmarksRequest]?
		private var trackingRequests: [VNTrackObjectRequest]?
		lazy var sequenceRequestHandler = VNSequenceRequestHandler()
		
		var faces: [Face] = []
		var faceItems: [MCVision.Detection.Face.Item] = []
		
		public init() {
			self.prepareVisionRequest()
		}
		
		var isRequest: Bool = false
		fileprivate func prepareVisionRequest002(pixelBuffer: inout CVPixelBuffer, renderSize: MCSize) throws {
			self.isRequest = true
			var pixelBuffer = pixelBuffer
			let faceDetectionRequest: VNDetectFaceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { [weak self] (request, error) in
				guard let self = self else { return }
				if error != nil {
					print("FaceDetection error: \(String(describing: error)).")
				}
				
				guard let faceDetectionRequest = request as? VNDetectFaceLandmarksRequest,
					let results = faceDetectionRequest.results as? [VNFaceObservation] else {
						return
				}
				
				print("results.count")
				print(results.count)
				self.faceItems = []
				for observation in results {
					let faceItem: MCVision.Detection.Face.Item = MCVision.Detection.Face.Item.init(id: 0, observation: observation, landmarks: observation.landmarks, renderSize: renderSize)
					//let faceItem: FaceDetection.FaceItem = FaceDetection.FaceItem.init(observation: observation, renderSize: renderSize)
                    do {
                        try faceItem.tracking(pixelBuffer: &pixelBuffer)
                        self.faceItems.append(faceItem)
                    } catch {
                        
                    }
				}
				//var isRequest: Bool = false
			})
			
			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
			try imageRequestHandler.perform([faceDetectionRequest])
		}

		fileprivate func prepareVisionRequest003(pixelBuffer: inout CVPixelBuffer, renderSize: MCSize) throws {
			self.isRequest = true
			var pixelBuffer = pixelBuffer
			let faceDetectionRequest: VNDetectFaceRectanglesRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] (request, error) in
				guard let self = self else { return }
				if error != nil {
					print("FaceDetection error: \(String(describing: error)).")
				}
				
				guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
					let results = faceDetectionRequest.results as? [VNFaceObservation] else {
						return
				}
				
				print("results.count")
				print(results.count)
				self.faceItems = []
				for observation in results {
					let faceItem: MCVision.Detection.Face.Item = MCVision.Detection.Face.Item.init(id: 0, observation: observation, landmarks: nil, renderSize: renderSize)
                    do {
                        try faceItem.tracking(pixelBuffer: &pixelBuffer)
                        self.faceItems.append(faceItem)
                    } catch {
                        
                    }
				}
				//var isRequest: Bool = false
			})
			
			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
			try imageRequestHandler.perform([faceDetectionRequest])
		}
		
		fileprivate func prepareVisionRequest() {
			self.trackingRequests = []
			var requests = [VNTrackObjectRequest]()
			let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { [weak self] (request, error) in
				guard let self = self else { return }
				if error != nil {
					print("FaceDetection error: \(String(describing: error)).")
				}
				
				guard let faceDetectionRequest = request as? VNDetectFaceLandmarksRequest,
					let results = faceDetectionRequest.results as? [VNFaceObservation] else {
						return
				}
				DispatchQueue.main.async {
					// Add the observations to the tracking list
					for observation: VNFaceObservation in results {
						let faceTrackingRequest: VNTrackObjectRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
						requests.append(faceTrackingRequest)
					}
					self.trackingRequests = requests
				}
			})
			
			self.detectionRequests = [faceDetectionRequest]
			self.sequenceRequestHandler = VNSequenceRequestHandler()
		}
		
		var count: Int = 0
		public func detection(pixelBuffer: inout CVPixelBuffer, renderSize: MCSize, onDetection: @escaping ((_ landmarksResults: [MCVision.Detection.Face.Item])->Void)) throws -> [MCVision.Detection.Face.Item] {
			onDetection(self.faceItems)
			var pixelBuffer = pixelBuffer

			if self.faceItems.count >= 1 {
                print("@1:", self.faceItems.count)
                var faceItems: [MCVision.Detection.Face.Item] = []
                for item in self.faceItems {
                    do {
                        try item.tracking(pixelBuffer: &pixelBuffer)
                        if item.isDetection {
                            faceItems.append(item)
                        }
                    } catch {
                        
                    }
                }
                print("@2:", faceItems.count)
                self.faceItems = faceItems
			} else {
				self.queue.async {
					do {
						try self.prepareVisionRequest002(pixelBuffer: &pixelBuffer, renderSize: renderSize)
					} catch {
						print("DetectionError001")
					}
					
				}
			}
			return self.faceItems
		}
    }
}
*/
