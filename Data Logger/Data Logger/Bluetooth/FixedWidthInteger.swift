//
//  FixedWidthInteger.swift
//  Data Logger
//
//  Created by Adam Kopec on 28/09/2022.
//

import Foundation

public extension FixedWidthInteger {
    typealias Bytes = [UInt8]
    /// A collection containing the bytes of this value’s binary representation, in order from the least significant to most significant.
    var bytes: Bytes {
        let bufferPointer = withUnsafePointer(to: self) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
                UnsafeBufferPointer(start: $0, count: MemoryLayout<Self>.size)
            }
        }
        return Bytes(bufferPointer)
    }
}
