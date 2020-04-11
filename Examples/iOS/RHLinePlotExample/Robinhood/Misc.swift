//
//  Misc.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

private let rhFontName = "HelveticaNeue"

struct CustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    var name: String = rhFontName
    var style: UIFont.TextStyle
    var weight: Font.Weight = .regular

    func body(content: Content) -> some View {
        return content.font(Font.custom(
            name,
            size: UIFont.preferredFont(forTextStyle: style).pointSize)
            .weight(weight))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func rhFont(
        style: UIFont.TextStyle,
        weight: Font.Weight = .regular) -> some View {
        return self.modifier(CustomFont(style: style, weight: weight))
    }
}
