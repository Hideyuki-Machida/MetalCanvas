//
//  SKNode+Extension.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2019/02/21.
//  Copyright © 2019 Donuts. All rights reserved.
//

import Foundation
import SpriteKit

extension SKNode {
    public func setTransform(transform: CGAffineTransform, animated: Bool, duration: TimeInterval = 1.0) {
        if animated {
            let scale: SKAction = SKAction.scale(to: transform.scale, duration: duration)
            let rotate: SKAction = SKAction.rotate(toAngle: transform.radian, duration: duration)
            let move: SKAction = SKAction.move(to: CGPoint(x: transform.tx, y: transform.ty), duration: duration)
            scale.timingMode = SKActionTimingMode.easeOut
            rotate.timingMode = SKActionTimingMode.easeOut
            move.timingMode = SKActionTimingMode.easeOut
            self.run(SKAction.group([scale, rotate, move]))
        } else {
            self.xScale = transform.scale
            self.yScale = transform.scale
            self.zRotation = transform.radian
            self.position = CGPoint(x: transform.tx, y: transform.ty)
        }
    }
}
