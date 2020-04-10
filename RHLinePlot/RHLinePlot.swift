//
//  RHLinePlot.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

public struct RHLinePlot: View {
    
    /// TODO: Can I use generic? Already tried but got problems
    /// (i.e. CGFloat/CGPoint conversion) along the road.
    public typealias Value = CGFloat
    
    /// Values to plot
    let values: [Value]
    
    /// If `true`, show glowing indicator at the last value
    let showGlowingIndicator: Bool
    
    /// Relative width for line plot to occupy its container. Must be `0` to `1`.
    let occupyingRelativeWidth: CGFloat
    
    
    /// Split values into line segments, allowing to show focus effect on a segment (by setting `activeSegment`).
    ///
    /// Each element is the beginning index of **values** in each line segment.
    /// I.e. to segment `[1,2,3 | 4,3 | 5,7]` would be `[0, 3]`.
    ///
    /// *Note: First segment must always start at `0`.*
    let lineSegmentStartingIndices: [Int]?
    
    /// Currently active segment index. Must provide `lineSegmentStartingIndices` to work.
    let activeSegment: Int?
    
    /// Custom indicator instead of the glowing indicator.
    ///
    /// Note: You should provide a fixed-size* frame to contain the content of your custom indicator before returning. Otherwise the size shown could be wrong.
    ///
    /// Note 2: We can't keep the generic version  since we don't want to pollute the initializer with generic, when the default glowing indicator is used.
    let customLatestValueIndicator: () -> AnyView
    
    /// Plot Config
    @Environment(\.rhLinePlotConfig) var rhLinePlotConfig
    
    public init<Indicator: View>(values: [Value],
                                 occupyingRelativeWidth: CGFloat = 1,
                                 showGlowingIndicator: Bool = false,
                                 lineSegmentStartingIndices: [Int]? = nil,
                                 activeSegment: Int? = nil,
                                 @ViewBuilder customLatestValueIndicator: @escaping () -> Indicator
    ) {
        #if DEBUG
        if let segments = lineSegmentStartingIndices {
            assert(segments.count > 0, "At least one segment")
            assert(segments[0] == 0, "First segment must start at 0")
            assert(segments.allSatisfy { $0 >= 0 && $0 < values.count }, "Segment must be specified with legal value indices")
            if let activeSegment = activeSegment {
                assert(activeSegment < segments.count, "Illegal active segment")
            }
        }
        #endif
        self.values = values
        self.showGlowingIndicator = showGlowingIndicator
        self.occupyingRelativeWidth = occupyingRelativeWidth
        
        self.lineSegmentStartingIndices = lineSegmentStartingIndices
        self.activeSegment = activeSegment
        self.customLatestValueIndicator = {
            return AnyView(customLatestValueIndicator())
        }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                
                Group {
                    if self.lineSegmentStartingIndices != nil {
                        self.drawPlotWithSegmentedLines(proxy: proxy, lineSegmentStartingIndices: self.lineSegmentStartingIndices!)
                    } else {
                        self.drawPlotWithOneLine(proxy: proxy)
                    }
                }
                
                if self.showGlowingIndicator {
                    bindView(data: self.getGlowingIndicatorLocation(proxy: proxy)) { ind in
                        // We use a small rectangle as a base (and offset it to the latest plot value).
                        // Then we center the indicator on top of this base.
                        Rectangle()
                            .frame(width: 10, height: 10)
                            .opacity(0)
                            .overlay(self.customLatestValueIndicator(), alignment: .center)
                            .transformEffect(.init(translationX: ind.width-5, y: ind.height-5))
                    }
                }
            }
        }
    }
}

// Default glowing indicator
public extension RHLinePlot {
    init(values: [Value],
         occupyingRelativeWidth: CGFloat = 1,
         showGlowingIndicator: Bool = false,
         lineSegmentStartingIndices: [Int]? = nil,
         activeSegment: Int? = nil
    ) {
        self.init(
            values: values,
            occupyingRelativeWidth:
            occupyingRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: lineSegmentStartingIndices,
            activeSegment: activeSegment,
            customLatestValueIndicator: {
                GlowingIndicator()
        })
    }
}

private func bindView<D, V: View>(data: D, transform: (D) -> V) -> V {
    transform(data)
}

// MARK:- Misc
extension RHLinePlot {
    
    func getGlowingIndicatorLocation(proxy: GeometryProxy) -> CGSize {
        let HEIGHT = proxy.size.height
        let (highest, lowest) = findHighestAndLowest(values: values)
        
        let x: CGFloat = occupyingRelativeWidth * proxy.size.width
        
        // If all values are equal, display at the middle
        if highest == lowest {
            return CGSize(width: x, height: HEIGHT/2)
        }
        
        let relativeY = CGFloat(values.last! - lowest) / CGFloat(highest - lowest)
        let y = (1 - relativeY) * HEIGHT
        
        return CGSize(width: x, height: y)
    }
    
    func getOpacity(forSegment segment: Int) -> Double {
        guard let activeSegment = self.activeSegment else {
            // No active segment, all are 1s
            return 1.0
        }
        return activeSegment == segment ? 1.0 : self.rhLinePlotConfig.opacityOfUnselectedSegment
    }
}

struct RHLinePlot_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RHLinePlot(values: [1,2,3,6,3,4,6])
        }.previewLayout(.fixed(width: 300, height: 300))
    }
}
