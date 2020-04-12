//
//  RobinhoodPage.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine
import SwiftUI
import RHLinePlot

struct RobinhoodPage: View {
    typealias PlotData = RobinhoodPageViewModel.PlotData
    static let symbol = "IBM"
    
    @State var timeDisplayMode: TimeDisplayOption = .hourly
    @State var isLaserModeOn = false
    @State var currentIndex: Int? = nil
    @ObservedObject var viewModel = RobinhoodPageViewModel(symbol: symbol)
    
    var currentPlotData: PlotData? {
        switch timeDisplayMode {
        case .hourly:
            return viewModel.intradayPlotData
        case .daily:
            return viewModel.dailyPlotData
        case .weekly:
            return viewModel.weeklyPlotData
        case .monthly:
            return viewModel.monthlyPlotData
        }
    }
    
    var plotDataSegments: [Int]? {
        guard let currentPlotData = currentPlotData else { return nil }
        switch timeDisplayMode {
        case .hourly:
            return RobinhoodPageViewModel.segmentByHours(values: currentPlotData)
        case .daily:
            return RobinhoodPageViewModel.segmentByMonths(values: currentPlotData)
        case .weekly, .monthly:
            return RobinhoodPageViewModel.segmentByYears(values: currentPlotData)
        }
    }
    
    var plotRelativeWidth: CGFloat {
        switch timeDisplayMode {
        case .hourly:
            return 0.7 // simulate today's data
        default:
            return 1.0
        }
    }
    
    var showGlowingIndicator: Bool {
        switch timeDisplayMode {
        case .hourly:
            return true // simulate today's data
        default:
            return false
        }
    }
    
    // MARK: Body
    func readyPageContent(plotData: PlotData) -> some View {
        VStack {
            stockHeaderAndPrice(plotData: plotData)
            plotBody(plotData: plotData)
            TimeDisplayModeSelector(
                currentTimeDisplayOption: $timeDisplayMode,
                eligibleModes: TimeDisplayOption.allCases)
            Spacer()
        }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading || currentPlotData == nil {
                Text("Loading...")
            } else {
                readyPageContent(plotData: currentPlotData!)
            }
        }
        .accentColor(rhThemeColor)
        .environment(\.rhLinePlotConfig, RHLinePlotConfig.default.custom(f: { (c) in
            c.useLaserLightLinePlotStyle = isLaserModeOn
        })).onAppear {
            self.viewModel.fetchOnAppear()
        }.onDisappear {
            self.viewModel.cancelAllFetchesOnDisappear()
        }
    }
}

// MARK:- Components
extension RobinhoodPage {
    func plotBody(plotData: PlotData) -> some View {
        let values = plotData.map { $0.price }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        let dateString = timeDisplayMode.dateFormatter()
            .string(from: plotData[currentIndex].time)
        
        return RHInteractiveLinePlot(
            values: values,
            occupyingRelativeWidth: 0.7,
            showGlowingIndicator: true,
            lineSegmentStartingIndices: plotDataSegments,
            segmentSearchStrategy: .binarySearch,
            didSelectValueAtIndex: { ind in
                self.currentIndex = ind
        },
            didSelectSegmentAtIndex: { segmentIndex in
                if segmentIndex != nil {
                    Haptic.onChangeLineSegment()
                }
        },
            valueStickLabel: { value in
                Text("\(dateString)")
                    .foregroundColor(.gray)
        })
            .frame(height: 280)
            .foregroundColor(rhThemeColor)
    }
    
    func stockHeaderAndPrice(plotData: PlotData) -> some View {
        let currentIndex = self.currentIndex ?? (plotData.count - 1)
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Self.symbol)")
                    .rhFont(style: .title1, weight: .bold)
                Text("$\(plotData[currentIndex].price.round2Str())")
                    .rhFont(style: .title1, weight: .bold)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

struct RobinhoodPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RobinhoodPage()
                .environment(\.colorScheme, .dark)
        }.previewLayout(.fixed(width: 320, height: 480))
    }
}
