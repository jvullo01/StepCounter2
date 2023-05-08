import SwiftUI

// MARK: - Stats Highlights type
enum HighlightType: String, CaseIterable, Identifiable {
    case dailyAverage = "Daily Average"
    case thisMonth = "This Month"
    var id: Int { hashValue }
    
    var color: Color {
        switch self {
        case .dailyAverage:
            return [Color(#colorLiteral(red: 0.1098039216, green: 0.6784313725, blue: 0.9607843137, alpha: 1))][0]
        case .thisMonth:
            return [Color(#colorLiteral(red: 0.9607843137, green: 0.6745098039, blue: 0.1098039216, alpha: 1))][0]
        }
    }
    
    var info: String {
        switch self {
        case .dailyAverage:
            return "Your daily steps average count based on previous 7 days"
        case .thisMonth:
            return "Total steps count for this current month so far"
        }
    }
    
    var icon: String {
        switch self {
        case .dailyAverage:
            return "figure.walk.circle"
        case .thisMonth:
            return "calendar.circle"
        }
    }
}

/// Shows fun statistics data
struct FunStatsContentView: View {
    
    @EnvironmentObject var manager: DataManager
    @State var selectedChartItem: String?

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                CustomHeaderView
                ScrollView(.vertical, showsIndicators: false, content: {
                    Spacer(minLength: 10)
                    VStack(spacing: 30) {
                        HighlightsSection
                        DailyAchievementsGrid
                        WeeklyChartView
                    }.padding([.leading, .trailing], 20)
                    Spacer(minLength: 20)
                }).padding(.top, 5)
            }
        }.onAppear {
            manager.fetchFunStatsData()
        }
    }
    
    /// Section title with right side data as optional text
    private func SectionHeader(title: String, showData: Bool = false) -> some View {
        HStack {
            Text(title).font(.system(size: 18, weight: .semibold))
            Spacer()
            if showData, let item = selectedChartItem, let value = manager.performance[item]?.formatted {
                Text(value)
            }
        }
    }
    
    /// Custom header view
    private var CustomHeaderView: some View {
        ZStack {
            Text("Your Stats").bold()
                .foregroundColor(.white).font(.system(size: 24))
            HStack {
                Spacer()
                Button { manager.fullScreen = nil } label: {
                    Image(systemName: "xmark")
                }
            }.foregroundColor(.white).font(.system(size: 20, weight: .medium))
        }.padding(.horizontal).padding(.bottom)
    }
    
    /// Highlights section
    private var HighlightsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 2)) {
            ForEach(HighlightType.allCases) { type in
                ZStack {
                    type.color
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: type.icon).resizable()
                                .aspectRatio(contentMode: .fit).frame(width: 25, height: 25)
                            VStack(alignment: .leading) {
                                Text(type == .thisMonth ? manager.thisMonthTotal : manager.dailyAverage)
                                    .font(.system(size: 20, weight: .semibold))
                                Text(type.rawValue).font(.system(size: 15))
                            }
                        }
                        Spacer()
                    }.padding()
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                presentAlert(title: "", message: type.info)
                            } label: {
                                Image(systemName: "info.circle.fill")
                            }
                            .font(.system(size: 12))
                            .frame(width: 20, height: 20, alignment: .center)
                        }
                        Spacer()
                    }.padding(10)
                }.cornerRadius(20).foregroundColor(.white)
            }
        }
    }
    
    /// Daily Achievement
    private var DailyAchievementsGrid: some View {
        VStack {
            SectionHeader(title: "Daily Achievements")
            LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 3), spacing: 30) {
                ForEach(0..<DailyAchievementType.allCases.count, id: \.self) { index in
                    VStack {
                        Image("badge-\(index)").resizable().aspectRatio(contentMode: .fit)
                        Text(DailyAchievementType.allCases[index].rawValue)
                            .foregroundColor(.white).font(.system(size: 12, weight: .semibold))
                    }
                    .saturation(manager.didEarnBadge(type: DailyAchievementType.allCases[index]) ? 1 : 0)
                    .opacity(manager.didEarnBadge(type: DailyAchievementType.allCases[index]) ? 1 : 0.25)
                }
            }
        }
    }
    
    /// Weekly chart performance
    private var WeeklyChartView: some View {
        VStack(spacing: 10) {
            SectionHeader(title: "Weekly Performance", showData: true)
            ChartView.foregroundColor(.white)
        }
    }
}

// MARK: - Preview UI
struct FunStatsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return FunStatsContentView().environmentObject(manager)
    }
}

