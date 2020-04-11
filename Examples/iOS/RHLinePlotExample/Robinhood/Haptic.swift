//
//  Haptic.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import UIKit

private func hapticFeedbackDefaultSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.success)
}

private func hapticFeedbackImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

enum Haptic {
    static func onChangeAppColorScheme() {
        hapticFeedbackDefaultSuccess()
    }
    
    static func onShowGraphIndicator() {
        hapticFeedbackImpact(style: .heavy)
    }
    
    static func onChangeTimeMode() {
        hapticFeedbackImpact(style: .light)
    }
    
    static func onChangeLineSegment() {
        hapticFeedbackImpact(style: .light)
    }
}
