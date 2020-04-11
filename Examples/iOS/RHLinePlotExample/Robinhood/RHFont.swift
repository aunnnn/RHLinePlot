//
//  RHFont.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

struct RHFont: ViewModifier {
    let fontName = "HelveticaNeue"
    
    @Environment(\.sizeCategory) var sizeCategory
    var textStyle: Font.TextStyle

    init(_ textStyle: Font.TextStyle = .body) {
        self.textStyle = textStyle
    }

    func body(content: Content) -> some View {
        content.font(getFont())
    }
    
    func getFont() -> Font {
        let font = UIFont(name: fontName, size: UIFont.labelFontSize)!
        let size = UIFontMetrics(forTextStyle: fontToUIFontTextStyle()).scaledFont(for: font).lineHeight
//        let size = UIFont.preferredFont(forTextStyle: fontToUIFontTextStyle()).lineHeight
        return Font.custom(fontName, size: size)
    }
    
    func fontToUIFontTextStyle() -> UIFont.TextStyle {
        switch textStyle {
        case .body: return .body
        case .callout: return .callout
        case .caption: return .caption1
        case .footnote: return .footnote
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .title: return .title1
        case .largeTitle: return .largeTitle
        @unknown default: return .body
        }
    }
}
