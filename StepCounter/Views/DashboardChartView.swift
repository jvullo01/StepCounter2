import SwiftUI

/// Chart view at the bottom on the dashboard
struct DashboardChartView: View {
    
    @EnvironmentObject var manager: DataManager
    private let chartHeight: Double = UIScreen.main.bounds.height/4.0
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 30) {
                HStack {
                    CaloriesCountView
                    Spacer()
                    WalkingRunningView
                }
                .foregroundColor(.white)
                .font(.system(size: 15, weight: .medium))
                
                /// Chart view
                VStack {
                    HourlyChartView
                    ChartTimelineBottomView
                }
            }.padding(.horizontal)
        }
    }
    
    /// Calories count view
    private var CaloriesCountView: some View {
        VStack(alignment: .leading) {
            Text("CALORIES").opacity(0.7)
            Text(manager.caloriesCount).font(.system(size: 20, weight: .bold))
        }
    }
    
    /// Walking distance
    private var WalkingRunningView: some View {
        VStack(alignment: .trailing) {
            Text("DISTANCE").opacity(0.7)
            Text("\(manager.walkRunDistance) mi").font(.system(size: 20, weight: .bold))
        }
    }
    
    /// Hourly chart view
    private var HourlyChartView: some View {
        let hours = manager.hourlyStepsData.keys.sorted(by: <)
        return ZStack {
            if hours.count > 0 {
                ChartGridBackgroundView
            }
            HStack(spacing: 1) {
                ForEach(0..<24, id: \.self) { index in
                    ChartProgressBar(forHour: hours.count > index ? hours[index] : nil)
                }
            }
            if hours.count == 0 {
                EmptyChartView
            }
        }.frame(height: chartHeight)
    }
    
    /// Chart grid background
    private var ChartGridBackgroundView: some View {
        let max = manager.hourlyStepsData.map({ $0.value }).max() ?? 0.0
        return VStack {
            VStack(alignment: .leading, spacing: 0) {
                Color.white.frame(height: 1)
                if max > 0.0 {
                    HStack {
                        Text(max.formatted).foregroundColor(.white)
                        Spacer()
                        Text("MAX")
                    }
                    .offset(y: -15)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                }
            }
            Spacer()
            Color.white.frame(height: 1)
            Spacer()
            Color.white.frame(height: 1)
        }.opacity(0.2)
    }
    
    /// Chart timeline bottom view
    private var ChartTimelineBottomView: some View {
        HStack {
            Text("12 AM")
            Spacer()
            Text("6 AM")
            Spacer()
            Text("12 PM")
            Spacer()
            Text("6 PM")
            Spacer()
            Text("12 AM")
        }
        .foregroundColor(.white)
        .font(.system(size: 12, weight: .medium))
    }
    
    /// Chart progress for a given hour
    private func ChartProgressBar(forHour hour: Date?) -> some View {
        let barWidth: Double = UIScreen.main.bounds.width/24-6.0
        return GeometryReader { reader in
            VStack {
                Spacer(minLength: 0)
                RoundedCorner(radius: 2, corners: [.topLeft, .topRight])
                    .frame(width: barWidth).foregroundColor(.accentLightColor)
                    .frame(height: completionHeight(reader: reader, hour: hour))
            }
        }
    }
    
    /// Completion progress height for chart bar
    private func completionHeight(reader: GeometryProxy, hour: Date?) -> CGFloat {
        guard let chartBarHour = hour else { return 0 }
        guard let progress = manager.hourlyStepsData[chartBarHour] else { return 0 }
        guard let max = manager.hourlyStepsData.map({ $0.value }).max() else { return 0 }
        let completed = reader.size.height
        let current = (CGFloat(progress) * completed) / CGFloat(max)
        return progress == max ? completed : current
    }
    
    /// Empty chart view
    private var EmptyChartView: some View {
        VStack {
            Text("No Steps").font(.system(size: 22, weight: .semibold))
            Text("You have no steps yet").opacity(0.7)
        }.foregroundColor(.white).offset(y: -20)
    }
}

// MARK: - Preview UI
struct DashboardChartView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        for index in 0...24 {
            let steps = Double.random(in: 10...300)
            manager.hourlyStepsData[Calendar.current.date(byAdding: .hour, value: -index, to: Date())!] = steps
        }
        return DashboardChartView().environmentObject(manager)
    }
}
