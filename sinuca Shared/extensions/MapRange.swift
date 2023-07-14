//
//  MapRange.swift
//  sinuca
//
//  Created by Hilton Pintor on 12/07/23.
//

import Foundation

func map(range:ClosedRange<Double>, domain:ClosedRange<Double>, value:Double) -> Double {
    if value > range.upperBound {
        return domain.upperBound
    }
    
    return domain.lowerBound + (domain.upperBound - domain.lowerBound) * (value - range.lowerBound) / (range.upperBound - range.lowerBound)
}
