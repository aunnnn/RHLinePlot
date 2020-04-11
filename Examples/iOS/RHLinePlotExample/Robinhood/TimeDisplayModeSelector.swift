//
//  TimeDisplayModeSelector.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

struct TimeDisplayModeSelector: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var currentTimeDisplayOption: TimeDisplayOption
    let eligibleModes: [TimeDisplayOption]
    
    private func buttonForegroundColor(_ mode: TimeDisplayOption) -> Color {
        if colorScheme == .light {
            return self.currentTimeDisplayOption == mode ? Color.white : Color.accentColor
        } else {
            return self.currentTimeDisplayOption == mode ? Color.black : Color.accentColor
        }
    }
    
    private func buttonBackgroundColor(_ mode: TimeDisplayOption) -> Color {
        self.currentTimeDisplayOption == mode ? Color.accentColor : Color.clear
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(self.eligibleModes, id: \.self) { mode in
                Button(action: {
                    DispatchQueue.main.async {
                        // Same mode, no op
                        if self.currentTimeDisplayOption == mode { return }
                        self.currentTimeDisplayOption = mode
                        Haptic.onChangeTimeMode()
                    }
                }) {
                    Text(mode.buttonTitle)
                        .rhFont(style: .footnote, weight: .semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 2)
                        .foregroundColor(self.buttonForegroundColor(mode))
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(self.buttonBackgroundColor(mode)))
                    
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}


struct TimeDisplayModeSelector_Previews: PreviewProvider {
    @State static var option: TimeDisplayOption = .daily
    
    static var previews: some View {
        Group {
            TimeDisplayModeSelector(
                currentTimeDisplayOption: $option,
                eligibleModes: TimeDisplayOption.allCases)
            TimeDisplayModeSelector(
                currentTimeDisplayOption: $option,
                eligibleModes: TimeDisplayOption.allCases)
                .environment(\.colorScheme, .dark)
        }.accentColor(rhThemeColor)
    }
}
