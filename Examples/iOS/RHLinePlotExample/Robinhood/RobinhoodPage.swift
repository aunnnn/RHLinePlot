//
//  RobinhoodPage.swift
//  RHLinePlotExample
//
//  Created by Wirawit Rueopas on 4/10/20.
//  Copyright © 2020 Wirawit Rueopas. All rights reserved.
//

import Combine
import SwiftUI
import RHLinePlot

struct RobinhoodPage: View {
    typealias PlotData = RobinhoodPageViewModel.PlotData
    static let symbol = "IBM"
    
    @State var timeDisplayMode: TimeDisplayOption = .hourly
    @State var isLaserModeOn = false
    @State var currentIndex: Int? = nil
    @ObservedObject var viewModel = RobinhoodPageViewModel(symbol: symbol)
    
    var currentPlotData: PlotData? {
        switch timeDisplayMode {
        case .hourly:
            return viewModel.intradayPlotData
        case .daily:
            return viewModel.dailyPlotData
        case .weekly:
            return viewModel.weeklyPlotData
        case .monthly:
            return viewModel.monthlyPlotData
        }
    }
    
    var plotDataSegments: [Int]? {
        guard let currentPlotData = currentPlotData else { return nil }
        switch timeDisplayMode {
        case .hourly:
            return RobinhoodPageViewModel.segmentByHours(values: currentPlotData)
        case .daily:
            return RobinhoodPageViewModel.segmentByMonths(values: currentPlotData)
        case .weekly, .monthly:
            return RobinhoodPageViewModel.segmentByYears(values: currentPlotData)
        }
    }
    
    var plotRelativeWidth: CGFloat {
        switch timeDisplayMode {
        case .hourly:
            return 0.7 // simulate today's data
        default:
            return 1.0
        }
    }
    
    var showGlowingIndicator: Bool {
        switch timeDisplayMode {
        case .hourly:
            return true // simulate today's data
        default:
            return false
        }
    }
    
    // MARK: Body
    func readyPageContent(plotData: PlotData) -> some View {
        ScrollView {
            stockHeaderAndPrice(plotData: plotData)
            plotBody(plotData: plotData)
            TimeDisplayModeSelector(
                currentTimeDisplayOption: $timeDisplayMode,
                eligibleModes: TimeDisplayOption.allCases)
            
            Divider()
            HStack {
                Text("All Segments")
                    .bold()
                    .rhFont(style: .title2)
                Spacer()
            }.padding([.leading, .top], 22)
            rowsOfSegment(plotData)
            Spacer()
        }
    }
    
    func rowsOfSegment(_ plotData: PlotData) -> some View {
        guard let segments = viewModel.segmentsDataCache[timeDisplayMode] else {
            return AnyView(EmptyView())
        }
        let allSplitPoints = segments + [plotData.count]
        let fromAndTos = Array(zip(allSplitPoints, allSplitPoints[1...]))
        let allTimes = plotData.map { $0.time }
        let allValues = plotData.map { $0.price }
        let dateFormatter = timeDisplayMode == .hourly ?
            SharedDateFormatter.onlyTime : SharedDateFormatter.dayAndYear
        return AnyView(ForEach((0..<fromAndTos.count).reversed(), id: \.self) { (i) -> AnyView in
            let (from, to) = fromAndTos[i]
            let endingPrice = allValues[to-1]
            let firstPrice = allValues[from]
            let endingTime = allTimes[to-1]
            let color = endingPrice >= firstPrice ? rhThemeColor : rhRedThemeColor
            return AnyView(self.segmentRow(
                titleText: "\(dateFormatter.string(from: endingTime))",
                values: Array(allValues[from..<to]),
                priceText: "$\(endingPrice.round2Str())").accentColor(color)
            )
            }.drawingGroup())
    }
    func segmentRow(titleText: String, values: [CGFloat], priceText: String) -> some View {
        HStack {
            Text(titleText)
                .rhFont(style: .headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 22)
            RHLinePlot(values: values)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(Color.accentColor)
            
            Text(priceText)
                .rhFont(style: .headline)
                .foregroundColor(.white)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 22)
        }.frame(height: 60)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading || currentPlotData == nil {
                Text("Loading...")
            } else {
                readyPageContent(plotData: currentPlotData!)
            }
        }
        .accentColor(rhThemeColor)
        .environment(\.rhLinePlotConfig, RHLinePlotConfig.default.custom(f: { (c) in
            c.useLaserLightLinePlotStyle = isLaserModeOn
        })).onAppear {
            self.viewModel.fetchOnAppear()
        }.onDisappear {
            self.viewModel.cancelAllFetchesOnDisappear()
        }
    }
}

// MARK:- Components
extension RobinhoodPage {
    func plotBody(plotData: PlotData) -> some View {
        let values = plotData.map { $0.price }
        let currentIndex = self.currentIndex ?? (values.count - 1)
        // For value stick
        let dateString = timeDisplayMode.dateFormatter()
            .string(from: plotData[currentIndex].time)
        
        let themeColor = values.last! >= values.first! ? rhThemeColor : rhRedThemeColor
        
        return RHInteractiveLinePlot(
            values: values,
            occupyingRelativeWidth: plotRelativeWidth,
            showGlowingIndicator: showGlowingIndicator,
            lineSegmentStartingIndices: plotDataSegments,
            segmentSearchStrategy: .binarySearch,
            didSelectValueAtIndex: { ind in
                self.currentIndex = ind
        },
            didSelectSegmentAtIndex: { segmentIndex in
                if segmentIndex != nil {
                    Haptic.onChangeLineSegment()
                }
        },
            valueStickLabel: { value in
                Text("\(dateString)")
                    .foregroundColor(.gray)
        })
            .frame(height: 280)
            .foregroundColor(themeColor)
    }
    
    func stockHeaderAndPrice(plotData: PlotData) -> some View {
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Self.symbol)")
                    .rhFont(style: .title1, weight: .heavy)
                buildMovingPriceLabel(plotData: plotData)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    func buildMovingPriceLabel(plotData: PlotData) -> some View {
        let currentIndex = self.currentIndex ?? (plotData.count - 1)
        return HStack(spacing: 2) {
            Text("$")
            MovingNumbersView(
                number: Double(plotData[currentIndex].price),
                numberOfDecimalPlaces: 2,
                verticalDigitSpacing: 0,
                animationDuration: 0.3,
                fixedWidth: 100) { (digit) in
                    Text(digit)
            }
            .mask(LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: .clear, location: 0),
                    Gradient.Stop(color: .black, location: 0.2),
                    Gradient.Stop(color: .black, location: 0.8),
                    Gradient.Stop(color: .clear, location: 1.0)]),
                startPoint: .top,
                endPoint: .bottom))
        }
        .rhFont(style: .title1, weight: .heavy)
    }
}

struct RobinhoodPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RobinhoodPage()
                .environment(\.colorScheme, .dark)
        }.previewLayout(.fixed(width: 320, height: 480))
    }
}
