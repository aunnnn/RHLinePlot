//
//  RHLinePlotConfig.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

public struct RHLinePlotConfigKey: EnvironmentKey {
    public static let defaultValue = RHLinePlotConfig.default
}

public extension EnvironmentValues {
    var rhLinePlotConfig: RHLinePlotConfig {
        get {
            return self[RHLinePlotConfigKey.self]
        }
        set {
            self[RHLinePlotConfigKey.self] = newValue
        }
    }
}

public struct RHLinePlotConfig {

    /// Width of the rectangle holding the glowing indicator (i.e. not `radius`, but rather `glowingIndicatorWidth = 2*radius`). Default is `8.0`
    public var glowingIndicatorWidth: CGFloat = 8.0
    
    /// Line width of the line plot. Default is `1.5`
    public var plotLineWidth: CGFloat = 1.5
    
    /// If all values are equal, we will draw a straight line. Default is 0.5 which draws a line at the middle.
    public var relativeYForStraightLine: CGFloat = 0.5
    
    /// Opacity of unselected segment. Default is `0.3`.
    public var opacityOfUnselectedSegment: Double = 0.3
    
    /// Animation duration of opacity on select/unselect a segment. Default is `0.1`.
    public var segmentSelectionAnimationDuration: Double = 0.1
    
    /// Scale the fading background of glowing indicator to specified value. Default is `5` (scale to 5 times bigger before disappear)
    public var glowingIndicatorBackgroundScaleEffect: CGFloat = 5
    
    public var glowingIndicatorDelayBetweenGlow: Double = 0.5
    public var glowingIndicatorGlowAnimationDuration: Double = 0.8
    
    public var useLaserLightLinePlotStyle: Bool = false
    
    // MARK:- RHInteractiveLinePlot
    
    public var valueStickWidth: CGFloat = 1.2
    public var valueStickColor: Color = .gray
    public var valueStickTopPadding: CGFloat = 28
    public var valueStickBottomPadding: CGFloat = 28
    public var gapBetweenPlotAndStickLabel: CGFloat = 8
    
    public static let `default` = RHLinePlotConfig()
    
    public func custom(f: (inout RHLinePlotConfig) -> Void) -> RHLinePlotConfig {
        var new = self
        f(&new)
        return new
    }
}
