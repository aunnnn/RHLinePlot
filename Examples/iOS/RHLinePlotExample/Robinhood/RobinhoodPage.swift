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

extension CGFloat {
    func round2Str() -> String {
        String(format: "%.2f", self)
    }
}

let rhThemeColor = Color(red: 33/255, green: 206/255, blue: 153/255)

class RobinhoodPageViewModel: ObservableObject {
    typealias PlotData = [(time: Date, price: CGFloat)]
    
    private let logic: RobinhoodPageBusinessLogic
    
    @Published var isLoading = false
    @Published var intradayPlotData: PlotData?
    @Published var dailyPlotData: PlotData?
    @Published var weeklyPlotData: PlotData?
    @Published var monthlyPlotData: PlotData?
    
    let symbol: String
    
    private var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
        self.logic = RobinhoodPageBusinessLogic(symbol: symbol)
        
        StocksAPI.networkActivity
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &storage)
        
        logic.$dailyResponse
            .compactMap(mapToPlotData)
            .receive(on: RunLoop.main)
            .assign(to: \.dailyPlotData, on: self)
            .store(in: &storage)
        
        logic.$intradayResponse
            .compactMap(mapToPlotData)
            .receive(on: RunLoop.main)
            .assign(to: \.intradayPlotData, on: self)
            .store(in: &storage)
        
        let publishers = [
            logic.$intradayResponse,
            logic.$dailyResponse,
            logic.$weeklyResponse,
            logic.$monthlyResponse
        ]
        
        let assignees: [ReferenceWritableKeyPath<RobinhoodPageViewModel, PlotData?>] = [
            \.intradayPlotData,
            \.dailyPlotData,
            \.weeklyPlotData,
            \.monthlyPlotData
        ]
        
        zip(publishers, assignees)
            .forEach { (tup) in
                let (publisher, assignee) = tup
                publisher
                    .compactMap(mapToPlotData)
                    .receive(on: RunLoop.main)
                    .assign(to: assignee, on: self)
                    .store(in: &storage)
        }
    }
    
    private func mapToPlotData(_ response: StockAPIResponse?) -> PlotData? {
        response?.timeSeries.map { tup in (tup.time, CGFloat(tup.info.closePrice)) }
    }
    
    func fetchOnAppear() {
        logic.fetch(timeSeriesType: .intraday)
        logic.fetch(timeSeriesType: .daily)
        logic.fetch(timeSeriesType: .weekly)
        logic.fetch(timeSeriesType: .monthly)
    }
    
    func cancelAllFetchesOnDisappear() {
        logic.storage.forEach { (c) in
            c.cancel()
        }
    }
}

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
        let segments = Array(stride(from: 0, to: values.count, by: 16))
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        let dateString = timeDisplayMode.dateFormatter()
            .string(from: plotData[currentIndex].time)
        
        return RHInteractiveLinePlot(
            values: values,
            occupyingRelativeWidth: 0.7,
            showGlowingIndicator: true,
            lineSegmentStartingIndices: segments,
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
