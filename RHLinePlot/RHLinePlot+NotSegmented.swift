//
//  RHLinePlot+NotSegmented.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

extension RHLinePlot {
    
    private func plotPathWithOneLine(canvasFrame: CGRect) -> Path {
        let WIDTH = occupyingRelativeWidth * canvasFrame.width
        let HEIGHT = canvasFrame.height
        let lineSectionLength = (WIDTH/CGFloat(values.count - 1))
        
        let (highest, lowest) = findHighestAndLowest(values: values)
        
        if highest == lowest {
            // All data points are equal, just draw a straight line in the middle
            return Path { path in
                path.move(to: CGPoint(x: canvasFrame.minX + 0, y: canvasFrame.minY + HEIGHT/2))
                path.addLine(to: CGPoint(x: canvasFrame.minX + WIDTH, y: canvasFrame.minY + HEIGHT/2))
            }
        }
        let inverseValueHeightDifference = 1/CGFloat(highest - lowest)
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = (1 - inverseValueHeightDifference * CGFloat(values[0] - lowest)) * HEIGHT
        
        return Path { path in
            path.move(to: CGPoint(x: canvasFrame.minX + currentX, y: canvasFrame.minY + currentY))
            for i in (1..<values.count) {
                currentX += lineSectionLength
                currentY = (1 - inverseValueHeightDifference * CGFloat(values[i] - lowest)) * HEIGHT
                path.addLine(to: CGPoint(x: canvasFrame.minX + currentX,
                                         y: canvasFrame.minY + currentY))
            }
        }
    }
    
    func drawPlotWithOneLine(canvasFrame: CGRect) -> some View {
        let lineWidth = self.rhLinePlotConfig.plotLineWidth
        if self.rhLinePlotConfig.useLaserLightLinePlotStyle {
            return AnyView(plotPathWithOneLine(canvasFrame: canvasFrame)
                .laserLightStroke(lineWidth: lineWidth))
        } else {
            return AnyView(plotPathWithOneLine(canvasFrame: canvasFrame)
                .stroke(style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    lineJoin: .round
                )))
        }
    }
}
