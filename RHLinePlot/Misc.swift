//
//  Misc.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

/// Find highest and lowest values
func findHighestAndLowest<V: Comparable>(values: [V]) -> (highest: V, lowest: V) {
    precondition(values.count > 0, "values must not be empty")
    var highest = values[0]
    var lowest = values[0]
    for v in values {
        if v > highest {
            highest = v
        }
        if v < lowest {
            lowest = v
        }
    }
    return (highest, lowest)
}

/// Find the index of `value` on a **sorted** `array`. If not found, return the index to the left.
///
/// I.e. for `[1, 3, 5, 10, 30, 55]
///
/// Search for `5`  will return `2`. Search for `10` will return `3`. Search for `9` (or any between `5-9`) will return `2` since it's the index on the left.
///
/// In other words, segments of this array are: `1-2`, `3-4`, `5-9`, `10-29`, `30-54`, `55-inf`.
/// and this function will return the active segment in log(N).
func binarySearchOrIndexToTheLeft<A: RandomAccessCollection, T: Comparable>(array: A, value: T) -> Int? where A.Element == T, A.Index == Int {
    if array.isEmpty { return nil }
    
    func search(from: Int, to: Int) -> Int? {
        let middle = (to + from)/2
        
        // Base case: middle is exactly the one
        if array[middle] == value {
            return middle
        }
            
            // Base case: Down to final one,
            // Return only if value is more than itself ("Nearest smaller")
        else if from == to {
            if value >= array[from] {
                return from
            } else { // Nope
                return nil
            }
        }
        else if from > to {
            return nil
        }
        else if value < array[middle] {
            return search(from: from, to: middle-1)
        }
        else {
            // value > array[middle]
            // If right side is nil, should return middle
            return search(from: middle+1, to: to) ?? middle
        }
    }
    return search(from: 0, to: array.count-1)
}

extension Comparable {
    func clamp(low: Self, high: Self) -> Self {
        return min(max(low, self), high)
    }
}

extension Path {
    /// Apply laser light style to the shape
    func laserLightStroke(lineWidth: CGFloat) -> some View {
        let content = self
        return ZStack {
            content.stroke(lineWidth: lineWidth*3)
                .blur(radius: 3*lineWidth)
            content.stroke(lineWidth: lineWidth*2)
                .blur(radius: 2*lineWidth)
            content.stroke(Color.white, style: StrokeStyle(
                lineWidth: lineWidth,
                lineCap: .round,
                lineJoin: .round))
        }
    }
}
