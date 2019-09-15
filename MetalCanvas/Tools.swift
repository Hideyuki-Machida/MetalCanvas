//
//  Tools.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/09/16.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation
import VideoToolbox

public struct Tools {
	public static let hasHEVCHardwareEncoder: Bool = {
		let spec: [CFString: Any]
		#if os(macOS)
		spec = [ kVTVideoEncoderSpecification_RequireHardwareAcceleratedVideoEncoder: true ]
		#else
		spec = [:]
		#endif
		var outID: CFString?
		var properties: CFDictionary?
		if #available(iOS 11.0, *) {
			let result = VTCopySupportedPropertyDictionaryForEncoder(width: 1280, height: 720, codecType: kCMVideoCodecType_HEVC, encoderSpecification: spec as CFDictionary, encoderIDOut: &outID, supportedPropertiesOut: &properties)
			if result == kVTCouldNotFindVideoEncoderErr {
				return false // no hardware HEVC encoder
			}

			/*
			let result = VTCopySupportedPropertyDictionaryForEncoder(width: 1920, height: 1080, codecType: kCMVideoCodecType_HEVC, encoderSpecification: spec as CFDictionary, encoderIDOut: &outID, supportedPropertiesOut: &properties)
			if result == kVTCouldNotFindVideoEncoderErr {
				return false // no hardware HEVC encoder
			}
			*/
			return result == noErr
		} else {
			return false
		}
	}()
}
