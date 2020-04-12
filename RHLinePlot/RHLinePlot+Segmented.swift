//
//  RHLinePlot+Segmented.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

extension RHLinePlot {
    
    func drawPlotWithSegmentedLines(canvasFrame: CGRect, lineSegmentStartingIndices: [Int]) -> some View {
        // In laser light mode for segmented lines, we use `drawingGroup()` to make it more responsive,
        // but the blurry parts at the edges will be clipped off
        // at the edge of the path canvas.
        //
        // FIX: Here we make the canvas virtually larger to provide padding
        // so that when the edges are cut off, blurry part is still there.
        let adjustedEachBorderDueToBlur: CGFloat = {
            if rhLinePlotConfig.useLaserLightLinePlotStyle {
                return 7.5 * rhLinePlotConfig.plotLineWidth
            } else {
                return 0
            }
        }()
        let largerCanvas = canvasFrame.insetBy(dx: -adjustedEachBorderDueToBlur, dy: -adjustedEachBorderDueToBlur)
        
        let pathBaseX: CGFloat = adjustedEachBorderDueToBlur
        let pathBaseY: CGFloat = adjustedEachBorderDueToBlur
        
        let WIDTH = canvasFrame.width * occupyingRelativeWidth
        let HEIGHT = canvasFrame.height
        
        let lineSectionLength = (WIDTH/CGFloat(values.count - 1))
        
        let (highest, lowest) = findHighestAndLowest(values: values)
        let allValuesAreEqual = highest == lowest
        
        let inverseValueHeightDifference: CGFloat? = allValuesAreEqual ? nil : 1/CGFloat(highest - lowest)
        
        // Draw each segment
        func drawSegment(path: inout Path, segment: (from: Int, to: Int)) {
            let segmentValues = values[segment.from..<segment.to]
            
            // The starting point of this segment (previous data point)
            // Note that when from is 0, this will be -1.
            let previousIndex = segment.from - 1
            
            // Previous Y (if previousIndex is -1, just use 0)
            let previousYPosition = CGFloat(previousIndex < 0 ? 0 : values[previousIndex] - lowest)
            
            var currentX = CGFloat(previousIndex) * lineSectionLength
            
            // If all values equal, simply draw a straight line in the middle
            if allValuesAreEqual {
                path.move(to:
                    CGPoint(
                        x: pathBaseX + currentX,
                        y: pathBaseY + HEIGHT * (1 - self.rhLinePlotConfig.relativeYForStraightLine)))
                
                currentX += lineSectionLength * CGFloat(segmentValues.count)
                
                path.addLine(to:
                    CGPoint(
                        x: pathBaseX + currentX,
                        y: pathBaseY + HEIGHT/2))
                return
            }
            
            assert(inverseValueHeightDifference != nil)
            var currentY = (1 - inverseValueHeightDifference! * previousYPosition) * HEIGHT
            
            path.move(to: CGPoint(x: pathBaseX + currentX,
                                  y: pathBaseY + currentY))
            
            // Draw segments of (currentX, nextX)
            for v in segmentValues {
                let nextX = currentX + lineSectionLength
                let nextY = (1 - inverseValueHeightDifference! * CGFloat(v - lowest)) * HEIGHT
                if currentX < 0 {
                    // *Handle when previousIndex is -1,  currentX will be negative. We won't addLine here yet, just move.
                    path.move(to: CGPoint(x: pathBaseX + nextX, y: pathBaseY + nextY))
                } else {
                    path.addLine(to: CGPoint(x: pathBaseX + nextX, y: pathBaseY + nextY))
                }
                currentX = nextX
                currentY = nextY
            }
        }
        
        // Build tuples of segments: [(from ,to)], `to` is exclusive.
        let allSplitPoints = lineSegmentStartingIndices + [values.count]
        let segments = Array(zip(allSplitPoints, allSplitPoints[1...]).enumerated())
        
        func pathForSegment(i: Int, s: (from: Int, to: Int)) -> some View {
            let path = Path { path in
                return drawSegment(path: &path, segment: s)
            }
            let lineWidth = self.rhLinePlotConfig.plotLineWidth
            if self.rhLinePlotConfig.useLaserLightLinePlotStyle {
                return AnyView(
                    path.laserLightStroke(lineWidth: lineWidth)
                        // much more responsive for laser mode to opacity animation,
                        // but we have to fix its unintended effects.
                        .drawingGroup()
                        .opacity(self.getOpacity(forSegment: i))
                )
            } else {
                return AnyView(path.stroke(style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )).opacity(self.getOpacity(forSegment: i)))
            }
        }
        
        // These invisible overlays are just for working in different coordinates
        // due to the adjustment hack above.
        return Rectangle().opacity(0) // Original plot size
            .overlay(
                Rectangle().opacity(0) // Adjusted edges (canvasFrame) size
                    .frame(width: canvasFrame.width, height: canvasFrame.height)
                    .overlay(
                        ZStack { // *Actual plot content*
                            ForEach(segments, id: \.self.0) { (i, s) in
                                pathForSegment(i: i, s: s)
                            }
                            .animation(
                                .linear(duration: self.rhLinePlotConfig.segmentSelectionAnimationDuration)
                            )
                        }
                        .frame(width: largerCanvas.width, height: largerCanvas.height) // Plot in a larger canvas
                        .offset(x: canvasFrame.minX, y: canvasFrame.minY) // Offset to the right adjust edge location.
                )
                ,
                alignment: .topLeading)
    }
}
