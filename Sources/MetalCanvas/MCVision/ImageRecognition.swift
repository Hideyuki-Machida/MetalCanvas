//
//  ImageRecognition.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/01/07.
//  Copyright © 2020 hideyuki machida. All rights reserved.
//

import Foundation

public protocol MCVisionImageRecognitionEventsProtocol {
    var onUpdate: ((_ result: [String : VisionResultProtocol]) ->Void)? {get set}
    init()
}

public extension MCVision {
    class ImageRecognition: NSObject {
        public fileprivate(set) var recognitionLayers: [VisionLayerProtocol] = []
        public fileprivate(set) var events: MCVisionImageRecognitionEventsProtocol?

        public func set(events: MCVisionImageRecognitionEventsProtocol) {
            self.events = events
        }
    }
}

public extension MCVision.ImageRecognition {
    func process(sorce: MCTexture, queue: DispatchQueue) throws {
        try self.process(sorce: sorce, queue: queue, events: self.events)
    }
    func process(sorce: MCTexture, queue: DispatchQueue, events: MCVisionImageRecognitionEventsProtocol?) throws {
        var result: [String : VisionResultProtocol] = [:]
        for index in self.recognitionLayers.indices {
            try self.recognitionLayers[index].process(sorce: sorce, resul: &result, queue: queue)
        }
        self.events?.onUpdate?(result)
    }
}
