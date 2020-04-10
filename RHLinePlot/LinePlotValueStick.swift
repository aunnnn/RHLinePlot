//
//  LinePlotValueStick.swift
//  RHLinePlot
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

/// Vertical thin line to show currently selected value within a line plot
struct LinePlotValueStick: View {
    
    var lineWidth: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .frame(maxWidth: self.lineWidth, maxHeight: .infinity)
    }
}
