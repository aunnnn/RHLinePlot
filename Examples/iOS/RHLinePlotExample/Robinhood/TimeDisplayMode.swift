//
//  TimeDisplayMode.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Foundation

enum TimeDisplayOption: String, CaseIterable {
    case hourly           = "H"
    case daily            = "D"
    case weekly           = "W"
    case monthly          = "M"
    
    var buttonTitle: String {
        rawValue
    }
    
    func dateFormatter() -> DateFormatter {
        switch self {
        case .hourly: return SharedDateFormatter.timeAndDay
        default: return SharedDateFormatter.dayAndYear
        }
    }
}

struct SharedDateFormatter {
    static let dayAndYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()
    
    static let timeAndDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a zzz, MMM d"
        return dateFormatter
    }()
    
    static let onlyTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a zzz"
        return dateFormatter
    }()
}
