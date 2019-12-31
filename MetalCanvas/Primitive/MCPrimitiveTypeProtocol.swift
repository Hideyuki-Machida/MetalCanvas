//
//  MTLCPrimitiveTypeProtocol.swift
//  CameraCore
//
//  Created by hideyuki machida on 2018/12/25.
//  Copyright © 2018 町田 秀行. All rights reserved.
//

import Foundation

public protocol MCPrimitiveTypeProtocol {
    func draw(commandBuffer: inout MTLCommandBuffer, drawInfo: MCPrimitive.DrawInfo) throws
}
