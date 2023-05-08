import SwiftUI

/// Main dashboard for the app
struct DashboardContentView: View {
    
    @EnvironmentObject var manager: DataManager
    @State private var didShowAds: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 15) {
                CustomHeaderView
                CircularLoaderView
                Spacer()
                DashboardChartView().environmentObject(manager)
            }
            /// Show daily goal completion
            if manager.didCompleteGoal {
                ConfettiOverlayView().environmentObject(manager)
            }
        }
        /// Show full screen flow
        .fullScreenCover(item: $manager.fullScreen) { type in
            switch type {
            case .premium: PremiumView
            case .settings: SettingsContentView().environmentObject(manager)
            case .statistics: FunStatsContentView().environmentObject(manager)
            }
        }
        /// Fetch steps data
        .onAppear {
            Interstitial.shared.loadInterstitial()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                manager.fetchTodaySteps()
                if !didShowAds {
                    didShowAds = true
                    Interstitial.shared.showInterstitialAds()
                }
            }
        }
    }
    
    /// Custom header view
    private var CustomHeaderView: some View {
        ZStack {
            ZStack {
                Text("Live") + Text("Step").bold()
            }.foregroundColor(.white).font(.system(size: 24))
            HStack {
                Button { manager.fullScreen = .statistics } label: {
                    Image(systemName: "chart.bar.xaxis")
                }
                Spacer()
                Button { manager.fullScreen = .settings } label: {
                    Image(systemName: "gearshape.fill")
                }
            }.foregroundColor(.white).font(.system(size: 20))
        }.padding(.horizontal).padding(.bottom)
    }
    
    /// Circular loader container
    private var CircularLoaderView: some View {
        ZStack {
            ZStack {
                Circle().foregroundColor(.darkGrayColor)
                    .shadow(color: Color.extraDarkGrayColor, radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.1), radius: 10, x: -8, y: -8)
                Circle().stroke(Color.darkGrayColor, lineWidth: 15)
                    .shadow(color: Color.extraDarkGrayColor, radius: 10, x: 10, y: 10)
                Circle().stroke(Color.darkGrayColor, lineWidth: 15)
                    .shadow(color: Color.white.opacity(0.1), radius: 10, x: -8, y: -8)
                Circle().trim(from: 0, to: manager.completionRate).rotation(.degrees(-90))
                    .stroke(style: .init(lineWidth: 13, lineCap: .round))
                    .foregroundColor(.accentLightColor)
            }.padding(.horizontal, 40)
            
            /// Steps count text
            VStack {
                Text("TODAY'S STEPS").opacity(0.3)
                Text(manager.todaySteps).font(.system(size: 60, weight: .bold))
                Text("GOAL\(manager.dailyGoal.isEmpty ? "" : " - \(manager.dailyGoal.double?.formatted ?? manager.dailyGoal)")").opacity(0.3)
            }.foregroundColor(.white).font(.system(size: 14, weight: .medium))
        }
    }
    
    /// Premium in-app purchases view
    private var PremiumView: some View {
        PremiumContentView(title: "Premium Version", subtitle: "Unlock All Features", features: ["Unlock Statistics", "Confetti Animation", "Remove Ads"], productIds: [AppConfig.premiumVersion]) {
            manager.fullScreen = nil
        } completion: { _, status, _ in
            DispatchQueue.main.async {
                if status == .success || status == .restored {
                    manager.isPremiumUser = true
                }
            }
        }
    }
}

// MARK: - Preview UI
struct DashboardContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.todaySteps = "10,000"
        return DashboardContentView().environmentObject(manager)
    }
}
