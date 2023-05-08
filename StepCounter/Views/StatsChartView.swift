import SwiftUI

/// Stats chart view
extension FunStatsContentView {
    
    /// Chart view with stats data
    var ChartView: some View {
        let max = manager.performance.map({ $0.value }).max() ?? 0
        let percentage = Array([0, max*0.25, max*0.5, max*0.75, max].reversed())
        let weekDays = Array(manager.calendarDays.dropLast().reversed().prefix(7).reversed())
        return ZStack {
            /// Chart percentage horizontal lines
            VStack(alignment: .leading, spacing: 20) {
                ForEach(0..<percentage.count, id: \.self) { index in
                    HStack(spacing: 10) {
                        Text(percentage[index].short).frame(width: 30, alignment: .leading)
                        Line().stroke(style: StrokeStyle(lineWidth: 1, dash: [6])).frame(height: 1).opacity(0.5)
                    }
                }
            }.padding(.bottom, 30)
            
            /// Chart days
            VStack {
                Spacer()
                HStack {
                    ForEach(0..<weekDays.count, id: \.self) { index in
                        Text(weekDays[index].string(format: "MMM\nd"))
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity)
                }
            }.padding(.leading, 30)
            
            /// Chart progress bars
            HStack {
                ForEach(0..<weekDays.count, id: \.self) { index in
                    ChartProgressBar(forDate: weekDays[index].longFormat)
                }
            }.padding(.leading, 30).padding(.bottom, 40)
        }
    }
    
    /// Chart progress for day
    private func ChartProgressBar(forDate date: String) -> some View {
        GeometryReader { reader in
            VStack {
                Spacer(minLength: 0)
                Rectangle().frame(height: completionHeight(reader: reader, date: date))
                    .foregroundColor(.clear).overlay(
                        RoundedCorner(radius: 5, corners: [.topLeft, .topRight]).frame(width: 20)
                    )
                    .onTapGesture {
                        if selectedChartItem == date { selectedChartItem = nil } else {
                            selectedChartItem = date
                        }
                    }
                    .opacity(selectedChartItem != nil ? (selectedChartItem == date ? 1 : 0.2) : 1)
                    .foregroundColor(.accentLightColor)
            }
        }
    }
    
    /// Completion progress height for chart bar
    private func completionHeight(reader: GeometryProxy, date: String) -> CGFloat {
        guard let progress = manager.performance[date] else { return 0 }
        guard let max = manager.performance.map({ $0.value }).max() else { return 0 }
        let completed = reader.size.height
        let current = max > 0.0 ? (CGFloat(progress) * completed) / CGFloat(max) : 0.0
        return progress == max && max > 0.0 ? completed : current
    }
}

/// Dash line
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
