//
//  MCVisionNameSpace.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/01/14.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

#if targetEnvironment(simulator)
public class MCVision {}
#else

public struct MCVision {
	public enum ErrorType: Error {
		case rendering
	}

	public struct Depth { }
	public struct Detection { }
}
#endif
