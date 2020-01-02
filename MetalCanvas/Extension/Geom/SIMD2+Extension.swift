//
//  SIMD2+Extension.swift
//  MetalCanvas
//
//  Created by hideyuki machida on 2020/01/02.
//  Copyright © 2020 hideyuki machida. All rights reserved.
//

import Foundation

public extension SIMD2 {
    func toCGSize() ->CGSize {
        return CGSize(self.x as! CGFloat , self.y as! CGFloat)
    }
}
