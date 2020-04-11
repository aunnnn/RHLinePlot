//
//  StocksAPI.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Foundation
import Combine

struct StocksAPI {
    private static let baseURL = URL(string: "https://www.alphavantage.co/query?")!
    static let networkActivity = PassthroughSubject<Bool, Never>()
        
    let symbol: String
    let timeSeriesType: TimeSeriesType
    var apiKey = "demo"
    
    var fullURL: URL {
        URL(string: "\(Self.baseURL)\(query)")!
    }
    
    private var query: String {
        switch timeSeriesType {
        case .intraday:
            return "function=\(timeSeriesType.function)&symbol=\(symbol)&interval=5min&apikey=\(apiKey)"
        default:
            return "function=\(timeSeriesType.function)&symbol=\(symbol)&apikey=\(apiKey)"
        }
    }
    
    private var jsonDecoder: JSONDecoder {
        let d = JSONDecoder()
        d.userInfo[CodingUserInfoKey(rawValue: "dateFormat")!] = timeSeriesType.dateFormat
        return d
    }
    
    var publisher: AnyPublisher<StockAPIResponse?, Never> {
        let url = self.fullURL
        print("URL: \(url)")
        let publiser = URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(receiveSubscription: { (_) in
                Self.networkActivity.send(true)
            }, receiveCompletion: { (completion) in
                Self.networkActivity.send(false)
            }, receiveCancel: {
                Self.networkActivity.send(false)
            })
            .map(\.data)
            .decode(type: StockAPIResponse?.self, decoder: jsonDecoder)
            .catch { (err) -> Just<StockAPIResponse?> in
                print("Catched Error \(err.localizedDescription)")
                return Just<StockAPIResponse?>(nil)
        }
        .eraseToAnyPublisher()
        return publiser
    }
}

extension StocksAPI {
    enum TimeSeriesType {
        case intraday
        case daily
        case weekly
        case monthly
        
        var dateFormat: String {
            switch self {
            case .intraday:
                return "yyyy-MM-dd HH:mm:ss"
            case .daily:
                return "yyyy-MM-dd"
            case .weekly:
                return "yyyy-MM-dd"
            case .monthly:
                return "yyyy-MM-dd"
            }
        }
        
        var function: String {
            switch self {
            case .intraday:
                return "TIME_SERIES_INTRADAY"
            case .daily:
                return "TIME_SERIES_DAILY"
            case .weekly:
                return "TIME_SERIES_WEEKLY"
            case .monthly:
                return "TIME_SERIES_MONTHLY"
            }
        }
    }
}
