//
//  RHInteractiveLinePlot.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

public struct RHInteractiveLinePlot<StickLabel, Indicator>: View
    where StickLabel: View, Indicator: View
{
    public typealias Value = CGFloat
    
    let valueStickLineWidth: CGFloat = 1
    let gapBetweenPlotAndStickLabel: CGFloat = 8
    
    let values: [Value]
    let lineSegmentStartingIndices: [Int]?
    let showGlowingIndicator: Bool
    
    /// Relative width that the line plot is occupying (from 0 to 1)
    let occupyingRelativeWidth: CGFloat
    let valueStickLabelBuilder: (Value) -> StickLabel
    
    /// Notify when the index selected is changed
    let didSelectValueAtIndex: ((Int?) -> Void)?
    
    /// Notify when the segment index selected is changed
    let didSelectSegmentAtIndex: ((Int?) -> Void)?
    
    let customLatestValueIndicator: () -> Indicator
    
    @GestureState var isDragging: Bool = false
    @State private var draggableIndicatorOffset: CGFloat = 0
    @State private var currentlySelectedIndex: Int? = nil
    @State private var currentlySelectedSegmentIndex: Int? = nil
    
    public init(
        values: [Value],
        occupyingRelativeWidth: CGFloat = 1.0,
        showGlowingIndicator: Bool = false,
        lineSegmentStartingIndices: [Int]? = nil,
        didSelectValueAtIndex: ((Int?) -> Void)? = nil,
        didSelectSegmentAtIndex: ((Int?) -> Void)? = nil,
        @ViewBuilder
        customLatestValueIndicator: @escaping () -> Indicator,
        @ViewBuilder
        valueStickLabel: @escaping (Value) -> StickLabel
    ) {
        self.values = values
        self.occupyingRelativeWidth = occupyingRelativeWidth
        self.lineSegmentStartingIndices = lineSegmentStartingIndices
        self.didSelectValueAtIndex = didSelectValueAtIndex
        self.didSelectSegmentAtIndex = didSelectSegmentAtIndex
        self.valueStickLabelBuilder = valueStickLabel
        self.showGlowingIndicator = showGlowingIndicator
        self.customLatestValueIndicator = customLatestValueIndicator
    }
    
    public var body: some View {
        GeometryReader { proxy in
            self.makeGraphBody(proxy: proxy)
        }
    }
    
    func linePlot() -> some View {
        return RHLinePlot(
            values: values,
            occupyingRelativeWidth: occupyingRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: lineSegmentStartingIndices,
            activeSegment: currentlySelectedSegmentIndex,
            customLatestValueIndicator: customLatestValueIndicator
        )
    }
    
    var stickAndLabelOpacity: Double {
        isDragging ? 1 : 0
    }
    
    func makeGraphBody(proxy: GeometryProxy) -> some View {
        let GRAPH_WIDTH = proxy.size.width
        let HALF_WIDTH = GRAPH_WIDTH/2
        let maxGraphWidth = occupyingRelativeWidth * GRAPH_WIDTH
        
        // Currently selected index on screen
        // NOTE: Use 0 if nil for convenience
        let effectiveIndex = self.currentlySelectedIndex ?? 0
        let currentValue = values[effectiveIndex]
        
        // Get value stick (vertical line that appears on user drag)
        // Compute its offset & text translation
        let valueStickLabel = valueStickLabelBuilder(currentValue)
        let valueStickOffset = getValueStickOffset(referencedWidth: maxGraphWidth)
        let valueStickTranslation = valueStickOffset - HALF_WIDTH
        
        // Clamp to not go out of plot bounds
        // We need proxy here to calculate the label size dynamically
        func constrainedStickTranslation(proxy: GeometryProxy) -> CGAffineTransform {
            let stickLabelWidth = proxy.size.width
            let translationX = valueStickTranslation.clamp(
                low: -HALF_WIDTH + stickLabelWidth/2,
                high: HALF_WIDTH - stickLabelWidth/2)
            return CGAffineTransform(translationX: translationX, y: 0)
        }
        
        return VStack(spacing: gapBetweenPlotAndStickLabel) {
            
            // Value Stick Label
            // HACK: We get a dynamic size of value stick label through `overlay`.
            // We hide the bottom one and just use it for sizing.
            valueStickLabel.opacity(0)
                .overlay(
                    GeometryReader { textProxy in
                        valueStickLabel
                            .transformEffect(constrainedStickTranslation(proxy: textProxy))
                    }.opacity(stickAndLabelOpacity))
            
            // Line Plot
            linePlot()
                .padding(.vertical, 16)
                .overlay(
                    // Value Stick
                    LinePlotValueStick(lineWidth: valueStickLineWidth)
                        .opacity(stickAndLabelOpacity)
                        .offset(x: valueStickOffset-(valueStickLineWidth/2)),
                    alignment: .leading
            )
                .contentShape(Rectangle())
                .gesture(touchAndDrag(maxWidth: maxGraphWidth))
        }
    }
}

// Default indicator
public extension RHInteractiveLinePlot where Indicator == GlowingIndicator {
    init(
        values: [Value],
        occupyingRelativeWidth: CGFloat = 1.0,
        showGlowingIndicator: Bool = false,
        lineSegmentStartingIndices: [Int]? = nil,
        didSelectValueAtIndex: ((Int?) -> Void)? = nil,
        didSelectSegmentAtIndex: ((Int?) -> Void)? = nil,
        @ViewBuilder
        valueStickLabel: @escaping (Value) -> StickLabel
    ) {
        self.init(
            values: values,
            occupyingRelativeWidth: occupyingRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: lineSegmentStartingIndices,
            didSelectValueAtIndex: didSelectValueAtIndex,
            didSelectSegmentAtIndex: didSelectSegmentAtIndex,
            customLatestValueIndicator: {
                GlowingIndicator()
        },
            valueStickLabel: valueStickLabel)
    }
}

private extension RHInteractiveLinePlot {
    
    // Get index of nearest data point.
    func getEffectiveIndex(referencedWidth: CGFloat) -> Int {
        let relativeX = self.draggableIndicatorOffset / max(referencedWidth, 1)
        return Int(round(relativeX * CGFloat(self.values.count - 1))).clamp(low: 0, high: self.values.count-1)
    }
    
    // Get final offset for line that snaps to the nearest data point.
    func getValueStickOffset(referencedWidth: CGFloat) -> CGFloat {
        let targetIndex = CGFloat(getEffectiveIndex(referencedWidth: referencedWidth))
        let segmentLength = referencedWidth / CGFloat(values.count - 1)
        let target = targetIndex * segmentLength
        return target.clamp(low: 0, high: referencedWidth)
    }
    
    func touchAndDrag(maxWidth: CGFloat) -> some Gesture {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isDragging) { (value, state, _) in
                state = true
        }.onChanged { (value) in
            self.draggableIndicatorOffset = min(value.location.x, maxWidth)
            
            self.currentlySelectedIndex = self.getEffectiveIndex(referencedWidth: maxWidth)
            self.didSelectValueAtIndex?(self.currentlySelectedIndex)
            
            let activeSegment: Int?
            if let segments = self.lineSegmentStartingIndices,
                let currentIndex = self.currentlySelectedIndex {
                activeSegment = binarySearchOrIndexToTheLeft(array: segments, value: currentIndex)
            } else {
                activeSegment = nil
            }
            self.currentlySelectedSegmentIndex = activeSegment
            self.didSelectSegmentAtIndex?(activeSegment)
        }
        .onEnded { (_) in
            self.draggableIndicatorOffset = maxWidth
            
            self.currentlySelectedIndex = nil
            self.didSelectValueAtIndex?(nil)
            
            self.currentlySelectedSegmentIndex = nil
            self.didSelectSegmentAtIndex?(nil)
        }
        return drag
    }
}
