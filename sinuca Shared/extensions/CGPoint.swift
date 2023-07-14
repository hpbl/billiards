//
//  CGPoint.swift
//  sinuca
//
//  Created by Hilton Pintor on 13/07/23.
//

import Foundation

extension CGPoint {
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGVector {
        return  CGVector(dx: lhs.x - rhs.x, dy: lhs.y - rhs.y)
    }
}
