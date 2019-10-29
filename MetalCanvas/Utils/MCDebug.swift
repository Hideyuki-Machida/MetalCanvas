//
//  Debug.swift
//  MetalCanvas
//
//  Created by machida.hideyuki on 2019/10/25.
//  Copyright © 2019 hideyuki machida. All rights reserved.
//

import Foundation

public class MCDebug {
    public static func log<T>(_ object: T) {
        func log<T>(_ object: T) {
            print("📔 \(object)")
        }
        #if RELEASE
        #else
        log(object)
        #endif
    }
    public static func successLog<T>(_ object: T) {
        func log<T>(_ object: T) {
            print("🍏 SuccessLog: \(object)")
        }
        #if RELEASE
        #else
        log(object)
        #endif
    }
    public static func errorLog<T>(_ object: T) {
        func log<T>(_ object: T) {
            print("🍎 ErrorLog: \(object)")
        }
        #if RELEASE
        #else
        log(object)
        #endif
    }
    public static func deinitLog<T>(_ object: T) {
        func log<T>(_ object: T) {
            print("🗑 DeinitLog: \(object)")
        }
        #if RELEASE
        #else
        log(object)
        #endif
    }
}
