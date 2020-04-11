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
        let WIDTH = occupyingRelativeWidth * canvasFrame.size.width
        let HEIGHT = canvasFrame.size.height
        let lineSectionLength = (WIDTH/CGFloat(values.count - 1))
        
        let (highest, lowest) = findHighestAndLowest(values: values)
        
        if highest == lowest {
            // All data points are equal, just draw a straight line in the middle
            return Path { path in
                path.move(to: CGPoint(x: 0, y: HEIGHT/2))
                path.addLine(to: CGPoint(x: WIDTH, y: HEIGHT/2))
            }
        }
        let inverseValueHeightDifference = 1/CGFloat(highest - lowest)
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = (1 - inverseValueHeightDifference * CGFloat(values[0] - lowest)) * HEIGHT
        
        return Path { path in
            path.move(to: CGPoint(x: currentX, y: currentY))
            for i in (1..<values.count) {
                currentX += lineSectionLength
                currentY = (1 - inverseValueHeightDifference * CGFloat(values[i] - lowest)) * HEIGHT
                path.addLine(to: CGPoint(x: currentX, y: currentY))
            }
        }
    }
    
    func drawPlotWithOneLine(canvasFrame: CGRect) -> some View {
        plotPathWithOneLine(canvasFrame: canvasFrame)
            .stroke(style: StrokeStyle(
                lineWidth: self.rhLinePlotConfig.plotLineWidth,
                lineCap: .round,
                lineJoin: .round
            ))
    }
}
