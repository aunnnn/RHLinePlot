//
//  HomeView.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/9/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    var basicUsagePage: some View {
        BasicUsagePage(isLaserModeOn: isLaserModeOn)
    }
    
    var customizationPage: some View {
        CustomizationPage(isLaserModeOn: isLaserModeOn)
    }
    
    var robinhoodPage: some View {
        RobinhoodPage()
    }
    
    @State var isDarkMode: Bool = false
    @State var isLaserModeOn: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: basicUsagePage) {
                        Text("Basic Usage")
                    }
                    NavigationLink(destination: customizationPage) {
                        Text("Customization")
                    }
                    NavigationLink(destination: robinhoodPage) {
                        Text("Robinhood")
                    }
                }
                
                Section {
                    Button(action: {
                        self.isDarkMode.toggle()
                    }) {
                        if isDarkMode {
                            Text("Use Light Mode")
                        } else {
                            Text("Use Dark Mode")
                        }
                    }
                    
                    Toggle(isOn: $isLaserModeOn) {
                        Text("Laser Mode (Best in dark)")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("RHLinePlot")
        }
        .transformEnvironment(\.colorScheme) { (c) in
            c = self.isDarkMode ? .dark : .light
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
//            ZStack {
//                Rectangle().stroke(Color.red, lineWidth: 20).blur(radius: 10)
//                    .frame(width: 100, height: 100)
//                Rectangle().stroke()
//                    .frame(width: 100, height: 100)
//                    .border(Color.black).opacity(0.3)
//                Rectangle().stroke()
//                    .frame(width: 120, height: 120)
//                    .border(Color.green).opacity(0.3)
//                Rectangle().stroke()
//                    .frame(width: 160, height: 160)
//                    .border(Color.green).opacity(0.3)
//            }
        }
    }
}
