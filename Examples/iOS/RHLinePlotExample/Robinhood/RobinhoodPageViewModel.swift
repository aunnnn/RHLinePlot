//
//  RobinhoodPageViewModel.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/11/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine
import SwiftUI

class RobinhoodPageViewModel: ObservableObject {
    typealias PlotData = [(time: Date, price: CGFloat)]
    
    private let logic: RobinhoodPageBusinessLogic
    
    @Published var isLoading = false
    @Published var intradayPlotData: PlotData?
    @Published var dailyPlotData: PlotData?
    @Published var weeklyPlotData: PlotData?
    @Published var monthlyPlotData: PlotData?
    
    var segmentsDataCache: [TimeDisplayOption: [Int]] = [:]
    
    let symbol: String
    
    private var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
        self.logic = RobinhoodPageBusinessLogic(symbol: symbol)
        
        StocksAPI.networkActivity
            .receive(on: RunLoop.main)
            .assign(to: \.isLoading, on: self)
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
        
        let timeDisplayOptions: [TimeDisplayOption] = [.hourly, .daily, .weekly, .monthly]

        zip(publishers, assignees).enumerated()
            .forEach { (i, tup) in
                let (publisher, assignee) = tup
                
                let displayOption = timeDisplayOptions[i]
                
                publisher
                    .compactMap(mapToPlotData)
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: { (plotData) in
                        self[keyPath: assignee] = plotData
                        
                        // Cache segments
                        let segments: [Int]
                        switch displayOption {
                        case .hourly:
                            segments = Self.segmentByHours(values: plotData)
                        case .daily:
                            segments = Self.segmentByMonths(values: plotData)
                        case .weekly, .monthly:
                            segments = Self.segmentByYears(values: plotData)
                        }
                        self.segmentsDataCache[displayOption] = segments
                    })
                    .store(in: &storage)
        }
    }
    
    static func segmentByHours(values: PlotData) -> [Int] {
        let calendar = Calendar.current
        var segments = [Int]()
        
        let lastStopper = calendar.endOfDay(for: values.last!.time)
        
        // Work backward from last day
        let breakpoints = (0..<values.count).map {
            calendar.date(byAdding: .hour, value: -$0, to: lastStopper)!
        }.reversed() // Reverse to be ascending
        
        segments.append(0)
        var currentRecords = ArraySlice(values)
        for upper in breakpoints {
            // Jump to first index of next segment
            if let ind = currentRecords.firstIndex(where: { $0.time > upper }), ind != segments.last {
                segments.append(ind)
                // Cut off, and continue
                currentRecords = currentRecords[ind...]
            }
        }
        return segments
    }
    
    static func segmentByMonths(values: PlotData) -> [Int] {
        let calendar = Calendar.current
        var segments = [Int]()
        
        let lastStopper = calendar.startOfMonth(for: values.last!.time)
        
        // Work backward from last day
        let breakpoints = (0..<values.count).map {
            calendar.date(byAdding: .month, value: -$0, to: lastStopper)!
        }.reversed() // Reverse to be ascending
        
        segments.append(0)
        var currentRecords = ArraySlice(values)
        for upper in breakpoints {
            // Jump to first index of next segment
            if let ind = currentRecords.firstIndex(where: { $0.time > upper }), ind != segments.last {
                segments.append(ind)
                // Cut off, and continue
                currentRecords = currentRecords[ind...]
            }
        }
        return segments
    }
    
    static func segmentByYears(values: PlotData) -> [Int] {
        let calendar = Calendar.current
        var segments = [Int]()
        
        let lastStopper = calendar.startOfYear(for: values.last!.time)
        
        // Work backward from last day
        let breakpoints = (0..<values.count).map {
            calendar.date(byAdding: .year, value: -$0, to: lastStopper)!
        }.reversed() // Reverse to be ascending
        
        segments.append(0)
        var currentRecords = ArraySlice(values)
        for upper in breakpoints {
            // Jump to first index of next segment
            if let ind = currentRecords.firstIndex(where: { $0.time > upper }), ind != segments.last {
                segments.append(ind)
                // Cut off, and continue
                currentRecords = currentRecords[ind...]
            }
        }
        return segments
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
