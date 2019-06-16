//
//  FaceItem.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/14.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import Vision

@available(iOS 11.0, *)
extension MCVision.Detection.FaceDetection {
	public class Item {
		public let id: Int
		private let queue: DispatchQueue
		public var boundingBox: CGRect = CGRect.init()
		public var allPoints: [CGPoint] = []
		public var landmarks: VNFaceLandmarks2D?
		private var renderSize: CGSize
		var faceTrackingRequest: VNTrackObjectRequest
		let sequenceRequestHandler: VNSequenceRequestHandler = VNSequenceRequestHandler()
		
		public init(id: Int, observation: VNFaceObservation, landmarks: VNFaceLandmarks2D?, renderSize: CGSize) {
			self.id = id
			let uuid = NSUUID().uuidString
			self.queue = DispatchQueue(label: "MetalCanvas.FaceDetection.FaceItem.\(uuid).queue")
			self.faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
			self.renderSize = renderSize
			
			guard let landmarks: VNFaceLandmarks2D = landmarks else { return }
			self.landmarks = landmarks
			if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
				let points: [CGPoint] = faceContour.pointsInImage(imageSize: self.renderSize)
				self.allPoints = points
			}
		}
		
		public func landmarkDetection(pixelBuffer: inout CVPixelBuffer, observation: VNDetectedObjectObservation) {
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
					guard let landmarks: VNFaceLandmarks2D = faceObservation.landmarks else { continue }
					if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
						let points: [CGPoint] = faceContour.pointsInImage(imageSize: self.renderSize)
						self.boundingBox = faceObservation.boundingBox
						self.allPoints = points
						self.landmarks = landmarks
					}
				}
				
			})
			let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
			faceLandmarksRequest.inputFaceObservations = [faceObservation]
			print(observation.boundingBox)
			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
			do {
				try imageRequestHandler.perform([faceLandmarksRequest])
			} catch {
				print("######")
			}
		}
		
		public func tracking(pixelBuffer: inout CVPixelBuffer) {
			let start: TimeInterval = Date().timeIntervalSince1970
			var pixelBuffer = pixelBuffer
			var faceTrackingRequest: VNTrackObjectRequest = self.faceTrackingRequest
			self.queue.async {
				do {
					try self.sequenceRequestHandler.perform([faceTrackingRequest], on: pixelBuffer)
					//print(self.faceTrackingRequest.results?.first)
					guard let observation: VNDetectedObjectObservation = self.faceTrackingRequest.results?.first as? VNDetectedObjectObservation else { return }
					print(observation.boundingBox)
					self.boundingBox = observation.boundingBox
					let end: TimeInterval = Date().timeIntervalSince1970 - start
					print("tracking time: \(end)")
					if !faceTrackingRequest.isLastFrame {
						if observation.confidence > 0.3 {
							faceTrackingRequest.inputObservation = observation
						} else {
							faceTrackingRequest.isLastFrame = true
						}
						self.faceTrackingRequest = faceTrackingRequest
						self.landmarkDetection(pixelBuffer: &pixelBuffer, observation: observation)
					}
					
				} catch {
					print("@@@@@")
				}
			}
		}
	}
}
