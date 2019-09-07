//
//  FaceDetection.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2018/12/31.
//  Copyright © 2018 hideyuki machida. All rights reserved.
//

import Foundation
import Vision

@available(iOS 11.0, *)
extension MCVision.Detection {
	public class Face {
		
		private let queue: DispatchQueue = DispatchQueue(label: "MetalCanvas.FaceDetection.queue", attributes: .concurrent)
		
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
		fileprivate func prepareVisionRequest002(pixelBuffer: inout CVPixelBuffer, renderSize: CGSize) throws {
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
					faceItem.tracking(pixelBuffer: &pixelBuffer)
					self.faceItems.append(faceItem)
				}
				//var isRequest: Bool = false
			})
			
			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
			try imageRequestHandler.perform([faceDetectionRequest])
		}

		fileprivate func prepareVisionRequest003(pixelBuffer: inout CVPixelBuffer, renderSize: CGSize) throws {
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
					faceItem.tracking(pixelBuffer: &pixelBuffer)
					self.faceItems.append(faceItem)
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
						print(observation.landmarks)
						//VNTrackObjectRequest(detectedObjectObservation: VNDetectedObjectObservation)
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
		public func detection(pixelBuffer: inout CVPixelBuffer, renderSize: CGSize, onDetection: @escaping ((_ landmarksResults: [Face])->Void)) throws -> [MCVision.Detection.Face.Item] {
			//guard self.count >= 0 else { self.count += 1; return self.faceItems}
			//self.count = 0
			//onDetection(self.faces)
			var pixelBuffer = pixelBuffer
			
			print("self.faceItems.count")
			print(self.faceItems.count)
			if self.faceItems.count >= 1 {
				for (index, item) in self.faceItems.enumerated() {
					self.faceItems[index].tracking(pixelBuffer: &pixelBuffer)
				}
			} else {
						print("DetectionError001----@@@@")
				//guard self.isRequest != true else { return self.faceItems }
						print("DetectionError001----")
				self.queue.async {
					do {
						//try self.prepareVisionRequest003(pixelBuffer: &pixelBuffer, renderSize: renderSize)
						try self.prepareVisionRequest002(pixelBuffer: &pixelBuffer, renderSize: renderSize)
					} catch {
						print("DetectionError001")
					}
					
				}
			}
			guard self.count >= 30 * 1 else { self.count += 1; return self.faceItems}
			self.count = 0
			self.queue.async {
				do {
					self.isRequest = false
					//try self.prepareVisionRequest003(pixelBuffer: &pixelBuffer, renderSize: renderSize)
					try self.prepareVisionRequest002(pixelBuffer: &pixelBuffer, renderSize: renderSize)
				} catch {
					print("DetectionError002")
				}
				
			}
			return self.faceItems
		}
		
		public func detection(pixelBuffer: inout CVPixelBuffer, renderSize: CGSize, onDetection: @escaping ((_ landmarksResults: [Face])->Void)) throws -> [Face] {
			guard self.count >= 1 else { self.count += 1; return self.faces}
			self.count = 0
			//onDetection(self.faces)
			var pixelBuffer = pixelBuffer
			self.queue.async {
				do {
					//guard self.count == true else { return }
					
					//self.count = false
					try self.faceRandmarkDetection(pixelBuffer: &pixelBuffer) { (faceObservations: [VNFaceObservation]) in
						self.faces = []
						for faceObservation: VNFaceObservation in faceObservations {
							guard let landmarks: VNFaceLandmarks2D = faceObservation.landmarks else { continue }
							if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
								//print(faceContour.pointsInImage(imageSize: renderSize))
								//let points: [CGPoint] = faceContour.normalizedPoints
								let points: [CGPoint] = faceContour.pointsInImage(imageSize: renderSize)
								var face: Face = Face()
								face.allPoints = points
								
								self.faces.append(face)
							}
						}
					}
				} catch {
					//self.count = true
				}
			}
			
			return self.faces
		}
		
		/*
		public func detection(texture: inout MCTexture, renderSize: CGSize, onDetection: @escaping ((_ landmarksResults: Result<[Face], Error>)->Void)) -> [MCVision.Detection.Face.Item] {
			self.queue.async {
				do {
					//guard self.count == true else { return }
					
					//self.count = false
					try self.faceRandmarkDetection(pixelBuffer: &pixelBuffer) { (faceObservations: [VNFaceObservation]) in
						self.faces = []
						for faceObservation: VNFaceObservation in faceObservations {
							guard let landmarks: VNFaceLandmarks2D = faceObservation.landmarks else { continue }
							if let faceContour: VNFaceLandmarkRegion2D = landmarks.allPoints {
								//print(faceContour.pointsInImage(imageSize: renderSize))
								//let points: [CGPoint] = faceContour.normalizedPoints
								let points: [CGPoint] = faceContour.pointsInImage(imageSize: renderSize)
								var face: Face = Face()
								face.allPoints = points
								
								self.faces.append(face)
							}
						}
					}
				} catch {
					//self.count = true
				}
			}
			return self.faceItems
		}
		*/
		
		private func tracking(pixelBuffer: inout CVPixelBuffer, trackingRequests: [VNTrackObjectRequest]?, detectionRequests: [VNDetectFaceLandmarksRequest]?) throws -> ([VNTrackObjectRequest], [[VNDetectedObjectObservation]]) {
			guard let requests = trackingRequests, !requests.isEmpty else {
				// No tracking object detected, so perform initial detection
				let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
				
				do {
					guard let detectRequests = detectionRequests else {
						throw ErrorType.trackingError
					}
					try imageRequestHandler.perform(detectRequests)
				} catch let error as NSError {
					NSLog("Failed to perform FaceRectangleRequest: %@", error)
				}
				throw ErrorType.trackingError
			}
			
			do {
				//print(requests)
				try self.sequenceRequestHandler.perform(requests, on: pixelBuffer)
			} catch let error as NSError {
				NSLog("Failed to perform SequenceRequest: %@", error)
			}
			
			// Setup the next round of tracking.
			var newTrackingRequests = [VNTrackObjectRequest]()
			var trackingResults: [[VNDetectedObjectObservation]] = []
			print(requests)
			for trackingRequest in requests {
				
				guard let results = trackingRequest.results as? [VNDetectedObjectObservation] else {
					throw ErrorType.trackingError
				}
				
				guard let observation: VNDetectedObjectObservation = results[0] as? VNDetectedObjectObservation else {
					throw ErrorType.trackingError
				}
				//observation.boundingBox
				
				//print(results)
				if !trackingRequest.isLastFrame {
					if observation.confidence > 0.3 {
						trackingRequest.inputObservation = observation
					} else {
						trackingRequest.isLastFrame = true
					}
					newTrackingRequests.append(trackingRequest)
				}
				
				trackingResults.append(results)
			}
			print(newTrackingRequests.count)
			return (newTrackingRequests, trackingResults)
		}
		
		private func faceRandmarkDetection(newTrackingRequests: [VNTrackObjectRequest], pixelBuffer: inout CVPixelBuffer, onDetection: @escaping (([[VNFaceObservation]]) -> Void)) throws {
			var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
			
			print(newTrackingRequests[0])
			print(newTrackingRequests[1])
			var resultsObservation: [[VNFaceObservation]] = []
			let len: Int = newTrackingRequests.count
			var count: Int = 0
			let callback: (()->Void) = {
				count += 1
				if count >= len {
					onDetection(resultsObservation)
				}
			}
			
			for trackingRequest in newTrackingRequests {
				let start: TimeInterval = Date().timeIntervalSince1970
				let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
					
					if error != nil {
						print("FaceLandmarks error: \(String(describing: error)).")
						callback(); return
					}
					
					guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
						let results: [VNFaceObservation] = landmarksRequest.results as? [VNFaceObservation] else {
							callback(); return
					}
					
					let end: TimeInterval = Date().timeIntervalSince1970 - start
					print("VNDetectFaceLandmarksRequest time: \(end)")
					
					resultsObservation.append(results)
					//onDetection(results)
					callback()
				})
				
				guard let trackingResults = trackingRequest.results else {
					callback(); continue
				}
				
				guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
					callback(); continue
				}
				//print(observation.boundingBox)
				//let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
				//faceLandmarksRequest.inputFaceObservations = [faceObservation]
				
				// Continue to track detected facial landmarks.
				faceLandmarkRequests.append(faceLandmarksRequest)
				
				let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
				
				do {
					
					try imageRequestHandler.perform(faceLandmarkRequests)
					
				} catch let error as NSError {
					NSLog("Failed to perform FaceLandmarkRequest: %@", error)
					callback(); continue
				}
			}
		}
		
		private func faceRandmarkDetection(pixelBuffer: inout CVPixelBuffer, onDetection: @escaping (([VNFaceObservation]) -> Void)) throws {
			let start: TimeInterval = Date().timeIntervalSince1970
			let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { [weak self] (request, error) in
				guard let self = self else { return }
				if error != nil {
					print("FaceDetection error: \(String(describing: error)).")
					onDetection([]); return
				}
				
				guard let faceDetectionRequest = request as? VNDetectFaceLandmarksRequest,
					let results = faceDetectionRequest.results as? [VNFaceObservation] else {
						onDetection([]); return
				}
				
				let end: TimeInterval = Date().timeIntervalSince1970 - start
				print("VNDetectFaceLandmarksRequest time: \(end)")
				onDetection(results)
			})
			let imageRequestHandler: VNImageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
			try imageRequestHandler.perform([faceDetectionRequest])
		}
		
	}
}
