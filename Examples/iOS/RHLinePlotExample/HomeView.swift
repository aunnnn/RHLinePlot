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
        BasicUsagePage()
    }
    
    var customizationPage: some View {
        CustomizationPage()
    }
    
    @State var isDarkMode: Bool = false
    
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
        HomeView()
    }
}
