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

extension MCDebug {
    public class Device {
        private static var threadList: UnsafeMutablePointer<UInt32> = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        private static let basicInfoCount = mach_msg_type_number_t(MemoryLayout<task_basic_info_data_t>.size /  MemoryLayout<UInt32>.size)

        public init() {}

        public static func usedMemory() -> UInt64? {
            // タスク情報を取得
            var info = mach_task_basic_info()
            // `info`の値からその型に必要なメモリを取得
            var count = UInt32(MemoryLayout.size(ofValue: info) / MemoryLayout<integer_t>.size)
            let result = withUnsafeMutablePointer(to: &info) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          // `task_info`の引数にするためにInt32のメモリ配置と解釈させる必要がある
                    $0.withMemoryRebound(to: Int32.self, capacity: 1) { pointer in
                        UnsafeMutablePointer<Int32>(pointer)
                }, &count)
            }
            // MB表記に変換して返却
            return result == KERN_SUCCESS ? info.resident_size / 1024 / 1024 : nil
        }

        public func thredBasicInfo(machTID: mach_port_t) -> thread_basic_info? {
            var threadInfo = thread_basic_info()
            var threadCount: UInt32 = MCDebug.Device.basicInfoCount
            let result: Int32 = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(machTID, thread_flavor_t(THREAD_BASIC_INFO), $0, &threadCount)
                }
            }
            guard result == KERN_SUCCESS else { return nil }

            return threadInfo

        }

        public static func usedCPU() -> Float {
            // カーネル処理の結果
            var result: Int32
            var threadList = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            var threadCount: UInt32 = UInt32(MemoryLayout<mach_task_basic_info_data_t>.size / MemoryLayout<natural_t>.size)
            var threadInfo: thread_basic_info = thread_basic_info()

            // スレッド情報を取得
            result = withUnsafeMutablePointer(to: &threadList) {
                $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                    task_threads(mach_task_self_, $0, &threadCount)
                }
            }

            if result != KERN_SUCCESS { return 0 }

            // 各スレッドからCPU使用率を算出し合計を全体のCPU使用率とする
            return (0 ..< Int(threadCount))
                // スレッドのCPU使用率を取得
                .flatMap { index -> Float? in
                    var threadInfoCount = UInt32(THREAD_INFO_MAX)
                    result = withUnsafeMutablePointer(to: &threadInfo) {
                        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                            thread_info(threadList[index], UInt32(THREAD_BASIC_INFO), $0, &threadInfoCount)
                        }
                    }
                    // スレッド情報が取れない = 該当スレッドのCPU使用率を0とみなす(基本nilが返ることはない)
                    if result != KERN_SUCCESS { return nil }
                    let isIdle = threadInfo.flags == TH_FLAGS_IDLE

                    // CPU使用率がスケール調整済みのため`TH_USAGE_SCALE`で除算し戻す
                    return !isIdle ? (Float(threadInfo.cpu_usage) / Float(TH_USAGE_SCALE)) * 100 : nil
                }
                // 合計算出
                .reduce(0, +)
        }

        
    }
}

extension MCDebug {
    public class Framerate {
        private var count: Int = 0
        private var beforDate: Date = Date()
        private var afterDate: Date = Date()

        public init() {}

        public func update() {
            self.beforDate = self.afterDate
            self.afterDate = Date()
            self.count += 1
        }

        public func time() -> TimeInterval {
            return self.afterDate.timeIntervalSince1970 - self.beforDate.timeIntervalSince1970
        }

        public func fps() -> Int {
            let updateCount: Int = self.count
            self.count = 0
            return updateCount
        }
    }
}
