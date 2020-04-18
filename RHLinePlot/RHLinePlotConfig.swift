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
    
    /// Use laser stroke mode to plot lines.
    ///
    /// Note that your plot will be automatically shrinked so that the blurry part fits inside the canvas.
    public var useLaserLightLinePlotStyle: Bool = false
    
    /// Use drawing group for laser light mode.
    ///
    /// This will increase responsiveness if there's a lot of segments.
    /// **But, the blurry parts will be clipped off the canvas bounds.**
//    public var useDrawingGroupForLaserLightLinePlotStyle: Bool = false
    
    /// The edges to fit the line strokes within canvas. This interacts with `plotLineWidth`. Default is `[]`.
    ///
    /// By default only the line skeletons (*paths*) exactly fits in the canvas,** without considering the `plotLineWidth`**.
    /// So when you increase the line width, the edge of the extreme values could go out of the canvas.
    /// You can provide a set of edges to consider to adjust to fit in canvas.
    public var adjustedEdgesToFitLineStrokeInCanvas: Edge.Set = []
    
    // MARK:- RHInteractiveLinePlot
    
    public var valueStickWidth: CGFloat = 1.2
    public var valueStickColor: Color = .gray
    
    /// Padding from the highest point of line plot to value stick. If `0`, the top of value stick will be at the same level of the highest point in plot.
    public var valueStickTopPadding: CGFloat = 28
    
    /// Padding from the lowest point of line plot to value stick. If `0`, the end of value stick will be at the same level of the lowest point in plot.
    public var valueStickBottomPadding: CGFloat = 28
    
    public var spaceBetweenValueStickAndStickLabel: CGFloat = 8
    
    /// Duration of long press before the value stick is activated and draggable.
    ///
    /// The more it is, the less likely the interactive part is activated accidentally on scroll view. Default is `0.1`.
    ///
    /// There's some lower-bound on this value that I guess coming from delaysContentTouches of
    /// the ScrollView. So long press of 0 won't 
    public var minimumPressDurationToActivateInteraction: Double = 0.1
    
    public static let `default` = RHLinePlotConfig()
    
    public func custom(f: (inout RHLinePlotConfig) -> Void) -> RHLinePlotConfig {
        var new = self
        f(&new)
        return new
    }
}
