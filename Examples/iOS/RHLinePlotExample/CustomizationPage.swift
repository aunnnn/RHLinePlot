//
//  CustomizationPage.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI
import Combine
import RHLinePlot


struct CustomizationPage: View {
    let values: [CGFloat] = (0...30).map { _ in CGFloat.random(in: (0...100)) }
    
    @State var relativeWidth: CGFloat = 1
    @State var lineWidth: CGFloat = 1.5
    @State var showGlowingIndicator: Bool = true
    @State var indicatorWidth: CGFloat = 6
    @State var glowingIndicatorScaleEffect: CGFloat = 5
    @State var glowingDuration: Double = 0.8
    @State var glowingDelayBetweenGlows: Double = 0.5
    @State var segmentAnimationDuration: Double = 0.1
    @State var isLaserModeOn = false
    
    func refreshPlot() {
        print("Refresh plot...")
        showGlowingIndicator.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showGlowingIndicator.toggle()
        }
    }
    
    func withRefresh<T>(_ state: Binding<T>) -> Binding<T> {
        Binding<T>(
            get: { state.wrappedValue },
            set: {
                state.wrappedValue = $0;
                self.refreshPlot()
        }
        )
    }
    
    var body: some View {
        let segments = Array(stride(from: 0, to: values.count, by: 4))
        let config = RHLinePlotConfig.default.custom { c in
            c.plotLineWidth = self.lineWidth
            c.glowingIndicatorWidth = self.indicatorWidth
            c.glowingIndicatorBackgroundScaleEffect = self.glowingIndicatorScaleEffect
            c.glowingIndicatorGlowAnimationDuration = self.glowingDuration
            c.glowingIndicatorDelayBetweenGlow = self.glowingDelayBetweenGlows
            c.segmentSelectionAnimationDuration = self.segmentAnimationDuration
            c.useLaserLightLinePlotStyle = self.isLaserModeOn
        }
        
        return Form {
            Section {
                Toggle(isOn: $isLaserModeOn) {
                    Text("Laser Mode")
                }
                
                VStack {
                    RHInteractiveLinePlot(
                        values: values,
                        occupyingRelativeWidth: relativeWidth,
                        showGlowingIndicator: showGlowingIndicator,
                        lineSegmentStartingIndices: segments,
                        didSelectValueAtIndex: { value in
                            print("Select \(String(describing: value))")
                    },
                        valueStickLabel: { value in
                            Text("\(String(format: "%.2f", value))")
                                .padding(2)
                    })
                        .environment(\.rhLinePlotConfig, config)
                        .foregroundColor(.green)
                        .border(Color.black)
                        .frame(maxWidth: .infinity, minHeight: 200)
                }
                
                Group {
                    HStack {
                        Text("Relative width \(String(format: "%.2f", relativeWidth))")
                        Slider(value: $relativeWidth, in: (0...1))
                    }
                    
                    Toggle(isOn: $showGlowingIndicator) {
                        Text("Show glowing indicator")
                    }
                    
                    Text("Appearance below is configured via RHLinePlotConfig environment.")
                        .font(.callout)
                        .foregroundColor(.green)
                    
                    HStack {
                        Text("Line width \(String(format: "%.2f", lineWidth))")
                        Slider(value: $lineWidth, in: (1...4))
                    }
                    HStack {
                        Text("Segment animation duration \(String(format: "%.2f", segmentAnimationDuration))")
                        Slider(value: $segmentAnimationDuration, in: (0.01...0.6))
                    }
                    HStack {
                        Text("Indicator width \(String(format: "%.2f", indicatorWidth))")
                        Slider(value: $indicatorWidth, in: (4...20))
                    }
                    
                    Group {
                        Text("For config below, we automatically toggle \"Show glowing indicator\" to refresh the plot:")
                            .font(.callout)
                            .foregroundColor(.orange)
                        
                        HStack {
                            Text("Glowing scale effect \(String(format: "%.2f", glowingIndicatorScaleEffect))")
                            Slider(value: withRefresh($glowingIndicatorScaleEffect), in: (1...15))
                        }
                        
                        HStack {
                            Text("Glowing duration \(String(format: "%.2f", glowingDuration))")
                            Slider(value: withRefresh($glowingDuration), in: (0.1...2))
                        }
                        
                        HStack {
                            Text("Delay between glows \(String(format: "%.2f", glowingDelayBetweenGlows))")
                            Slider(value: withRefresh($glowingDelayBetweenGlows), in: (0.01...1))
                        }
                    }
                }
            }
        }.navigationBarTitle("Customization")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizationPage()
    }
}
