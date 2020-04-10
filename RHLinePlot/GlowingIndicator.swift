//
//  GlowingIndicator.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

/// Default indicator with glowing effect. Used to show latest value in a line plot.
public struct GlowingIndicator: View {
    
    @State var isGlowing: Bool = false
    @Environment(\.rhLinePlotConfig) var rhLinePlotConfig
    
    public init() {}
    
    private var glowingAnimation: Animation {
        Animation
            .easeInOut(duration: rhLinePlotConfig.glowingIndicatorGlowAnimationDuration)
            .delay(rhLinePlotConfig.glowingIndicatorDelayBetweenGlow)
            .repeatForever(autoreverses: false)
    }
    
    private var glowingBackground: some View {
        Circle()
            .scaleEffect(isGlowing ? rhLinePlotConfig.glowingIndicatorBackgroundScaleEffect : 1)
            .opacity(isGlowing ? 0.0 : 1)
            .animation(glowingAnimation, value: self.isGlowing)
            .frame(width: rhLinePlotConfig.glowingIndicatorWidth, height: rhLinePlotConfig.glowingIndicatorWidth)
    }
    
    public var body: some View {
        Circle()
            .frame(width: rhLinePlotConfig.glowingIndicatorWidth, height: rhLinePlotConfig.glowingIndicatorWidth)
            .background(glowingBackground)
            .onAppear {
                withAnimation {
                    self.isGlowing = true
                }
            }
            .onDisappear {
                withAnimation {
                    self.isGlowing = false
                }
        }
    }
}


struct GlowingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GlowingIndicator()
        }.previewLayout(.fixed(width: 200, height: 200))
    }
}
