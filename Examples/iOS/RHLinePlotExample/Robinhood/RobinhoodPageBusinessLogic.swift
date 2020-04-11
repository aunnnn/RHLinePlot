//
//  RobinhoodPageBusinessLogic.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/11/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine

class RobinhoodPageBusinessLogic {
    typealias APIResponse = StockAPIResponse
    
    let symbol: String
    @Published var intradayResponse: APIResponse?
    @Published var dailyResponse: APIResponse?
    @Published var weeklyResponse: APIResponse?
    @Published var monthlyResponse: APIResponse?
    
    private static let mapTimeSeriesToResponsePath: [StocksAPI.TimeSeriesType: ReferenceWritableKeyPath<RobinhoodPageBusinessLogic, APIResponse?>] = [
        .intraday: \.intradayResponse,
        .daily: \.dailyResponse,
        .weekly: \.weeklyResponse,
        .monthly: \.monthlyResponse
    ]
    
    var storage = Set<AnyCancellable>()
    
    init(symbol: String) {
        self.symbol = symbol
    }
    
    func fetch(timeSeriesType: StocksAPI.TimeSeriesType) {
        StocksAPI(symbol: symbol, timeSeriesType: timeSeriesType).publisher
            .assign(to: Self.mapTimeSeriesToResponsePath[timeSeriesType]!, on: self)
            .store(in: &storage)
    }
}
