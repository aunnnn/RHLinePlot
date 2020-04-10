//
//  BasicUsagePage.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI
import RHLinePlot

struct BasicUsagePage: View {
    static let numValues = 40
    let values: [CGFloat] = (0...numValues).map { _ in CGFloat.random(in: (0...100)) }
    let segments = Array(stride(from: 0, to: numValues, by: 5))
    
    func valueStickLabel(value: CGFloat) -> some View {
        Text("\(String(format: "%.2f", value))")
    }
    
    var isLaserModeOn = false
    
    var body: some View {
        List {
            
            VStack {
                Text("Unsegmented")
                RHLinePlot(
                    values: values,
                    occupyingRelativeWidth: 0.6,
                    showGlowingIndicator: true
                )
                    .border(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
            
            VStack {
                Text("Segmented")
                RHLinePlot(
                    values: values,
                    occupyingRelativeWidth: 0.8,
                    lineSegmentStartingIndices: segments,
                    activeSegment: 2
                )
                    .border(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
            
            VStack {
                Text("Interactive + Unsegmented")
                RHInteractiveLinePlot(
                    values: values,
                    occupyingRelativeWidth: 0.9,
                    showGlowingIndicator: true, valueStickLabel: { value in
                        self.valueStickLabel(value: value)
                })
                    .border(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
            
            VStack {
                Text("Interactive + Segmented")
                RHInteractiveLinePlot(
                    values: values,
                    occupyingRelativeWidth: 0.9,
                    showGlowingIndicator: true,
                    lineSegmentStartingIndices: segments,
                    valueStickLabel: { value in
                        self.valueStickLabel(value: value)
                })
                    .border(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
            
            VStack {
                Text("Custom indicator")
                Text("Note that you should provide a fixed-size* frame to contain the content of your custom indicator before returning. Else the size would be wrong.")
                    .foregroundColor(.red)
                    .font(.subheadline)
                RHLinePlot(
                    values: values,
                    occupyingRelativeWidth: 0.8,
                    showGlowingIndicator: true,
                    lineSegmentStartingIndices: segments,
                    activeSegment: 2,
                    customLatestValueIndicator: {
                        Text("HOLY!")
                        .frame(width: 100, height: 44)
                    }
                )
                    .border(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .foregroundColor(.green)
        .font(.headline)
        .navigationBarTitle("Basic Usage")
        .environment(\.rhLinePlotConfig, RHLinePlotConfig.default.custom(f: { (c) in
            c.useLaserLightLinePlotStyle = isLaserModeOn
        }))
    }
}

struct BasicUsagePage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BasicUsagePage()
        }
    }
}
