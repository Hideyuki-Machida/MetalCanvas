//
//  MCFilterNameSpace.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/03.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

public struct MCFilter {
	public enum ErrorType: Error {
		case setupError
		case drawError
		case endError
	}

	public struct ColorSpace {}
	public struct ColorProcessing {}
}
