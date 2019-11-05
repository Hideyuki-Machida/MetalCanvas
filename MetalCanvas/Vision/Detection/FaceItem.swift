//
//  FaceItem.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/14.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Vision

extension MCVision.Detection.Face {
    public class Item {
		public let id: Int
		private let queue: DispatchQueue
		public var boundingBox: CGRect = CGRect.init()
		public var allPoints: [CGPoint] = []
		public var landmarks: VNFaceLandmarks2D?
		private var renderSize: CGSize
		var faceTrackingRequest: VNTrackObjectRequest? = nil
		let sequenceRequestHandler: VNSequenceRequestHandler = VNSequenceRequestHandler()
        var isDetection: Bool = true
        var observation: VNDetectedObjectObservation

		public init(id: Int, observation: VNFaceObservation, landmarks: VNFaceLandmarks2D?, renderSize: CGSize) {
			self.id = id
            let uuid = NSUUID().uuidString
			self.queue = DispatchQueue(label: "MetalCanvas.FaceDetection.FaceItem.\(uuid).queue")
            //self.queue = DispatchQueue(label: "MetalCanvas.FaceDetection.FaceItem.queue")
			//self.faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
			self.renderSize = renderSize
            self.observation = observation
			
			guard let landmarks: VNFaceLandmarks2D = landmarks else { return }
			self.landmarks = landmarks
			if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
				let points: [CGPoint] = faceContour.pointsInImage(imageSize: self.renderSize)
				self.allPoints = points
			}
            
		}
		
		public func landmarkDetection(pixelBuffer: inout CVPixelBuffer, observation: VNDetectedObjectObservation) throws {
			let start: TimeInterval = Date().timeIntervalSince1970
			let faceLandmarksRequest: VNDetectFaceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { [weak self] (request, error) in
				guard let self = self else { return }
				if error != nil {
					print("FaceDetection error: \(String(describing: error)).")
				}
				
				guard let faceDetectionRequest = request as? VNDetectFaceLandmarksRequest,
					let results = faceDetectionRequest.results as? [VNFaceObservation] else {
						return
				}
				
				print(results)
				let end: TimeInterval = Date().timeIntervalSince1970 - start
				print("VNDetectFaceLandmarksRequest time: \(end)")
				
				for faceObservation: VNFaceObservation in results {
                    //self.observation = faceObservation
                    guard let landmarks: VNFaceLandmarks2D = faceObservation.landmarks else { continue }
					if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
						let points: [CGPoint] = faceContour.pointsInImage(imageSize: self.renderSize)
						self.boundingBox = observation.boundingBox
						self.allPoints = points
						self.landmarks = landmarks
					}
				}
				
			})
			let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
			faceLandmarksRequest.inputFaceObservations = [faceObservation]

			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try imageRequestHandler.perform([faceLandmarksRequest])
		}
		
		public func tracking(pixelBuffer: inout CVPixelBuffer) throws {
			let start: TimeInterval = Date().timeIntervalSince1970
			var pixelBuffer = pixelBuffer
            //guard let faceTrackingRequest: VNTrackObjectRequest = self.faceTrackingRequest else { return }

            self.queue.async {
                var faceTrackingRequest = VNTrackObjectRequest.init(detectedObjectObservation: self.observation) { (_ request: VNRequest, error: Error?) in
                    do {
                        let end: TimeInterval = Date().timeIntervalSince1970 - start
                        print("tracking time: \(end)")

                        try self.faceTrackingComplete(request, pixelBuffer: &pixelBuffer, error: error)

                    } catch {
                        self.isDetection = false
                    }
                }

                do {
                    try self.sequenceRequestHandler.perform([faceTrackingRequest], on: pixelBuffer)
                } catch {
                        self.isDetection = false
                }

            }
            /*
            //////////////////////////////////////////////////////////////
            self.queue.async { [weak self] in
                guard let self = self else { return }
                do {
                    try self.sequenceRequestHandler.perform([faceTrackingRequest], on: pixelBuffer)
                    
                    //print(self.faceTrackingRequest.results?.first)
                    guard let observation: VNDetectedObjectObservation = faceTrackingRequest.results?.first as? VNDetectedObjectObservation else { return }

                    let size: CGSize = observation.boundingBox.size + 0.01
                    let origin: CGPoint = observation.boundingBox.origin - 0.005
                    let bounds: CGRect = CGRect.init(origin: origin, size: size)

                    let o = VNDetectedObjectObservation.init(boundingBox: bounds)
                    self.boundingBox = observation.boundingBox
                    let end: TimeInterval = Date().timeIntervalSince1970 - start
                    print("tracking time: \(end)")
                    if !faceTrackingRequest.isLastFrame {
                        if observation.confidence > 0.3 {
                            faceTrackingRequest.inputObservation = o
                        } else {
                            faceTrackingRequest.isLastFrame = true
                        }
                        self.faceTrackingRequest = faceTrackingRequest
                        try self.landmarkDetection(pixelBuffer: &pixelBuffer, observation: observation)
                        self.isDetection = true
                    } else {
                        self.isDetection = false
                    }
                } catch {
                    self.isDetection = false
                }
            }
            //////////////////////////////////////////////////////////////
             */
        }
        
        public func faceTrackingComplete(_ request: VNRequest, pixelBuffer: inout CVPixelBuffer, error: Error?) throws {
            guard let faceTrackingRequest: VNTrackObjectRequest = request as? VNTrackObjectRequest else { return }
            guard let observation: VNDetectedObjectObservation = request.results?.first as? VNDetectedObjectObservation else { return }
            self.boundingBox = observation.boundingBox
            if !faceTrackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    faceTrackingRequest.inputObservation = observation
                } else {
                    faceTrackingRequest.isLastFrame = true
                }
                try self.landmarkDetection(pixelBuffer: &pixelBuffer, observation: observation)
                self.isDetection = true
            } else {
                self.isDetection = false
            }
        }

	}
}
