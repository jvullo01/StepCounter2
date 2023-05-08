import SwiftUI

/// Shows the goal overlay with confetti
struct ConfettiOverlayView: View {
    
    @EnvironmentObject var manager: DataManager
    @State private var startEnterAnimation: Bool = false
    @State private var startExitAnimation: Bool = false
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                .opacity(startEnterAnimation ? (startExitAnimation ? 0 : 0.8) : 0)
                .onTapGesture { exitFlow() }
            VStack {
                VStack(spacing: 20) {
                    VStack {
                        Image("trophy-icon").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 45, height: 40, alignment: .center)
                        ZStack {
                            Text("Congratulations!").bold()
                        }.font(.system(size: 24))
                        Text("You Achieved Your Goal for Today")
                    }.foregroundColor(.white).padding(.top)
                    Color.white.frame(height: 1).padding(.horizontal, 30).opacity(0.2)
                    GoalDetailsView
                }
                .padding(.bottom, 20).background(
                    RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight])
                        .foregroundColor(.accentLightColor).ignoresSafeArea()
                )
                .offset(y: startEnterAnimation ? (startExitAnimation ? -UIScreen.main.bounds.height : 0) : -UIScreen.main.bounds.height)
                Spacer()
            }
        }
        /// Initial configurations when the view appears
        .onAppear {
            if startEnterAnimation == false {
                withAnimation(Animation.easeIn(duration: 1.0)) {
                    startEnterAnimation = true
                    ConfettiController.showConfettiOverlay()
                }
            }
        }
    }
    
    /// Exit flow action
    private func exitFlow() {
        hideKeyboard()
        manager.didShowTodayConfetti = true
        withAnimation { startExitAnimation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.manager.showGoalSetupView = false
        }
    }
    
    /// Goal details
    private var GoalDetailsView: some View {
        func ItemView(title: String, value: String, alignment: HorizontalAlignment) -> some View {
            VStack(alignment: alignment) {
                Text(title).font(.system(size: 15, weight: .medium))
                Text(value.double?.formatted ?? value).font(.system(size: 30, weight: .bold))
            }
        }
        return HStack {
            ItemView(title: "STEPS", value: manager.todaySteps, alignment: .leading)
            Spacer()
            ItemView(title: "GOAL", value: manager.dailyGoal.isEmpty ? "- - -" : manager.dailyGoal, alignment: .trailing)
        }.padding(.horizontal, 30).padding(.bottom)
    }
}

// MARK: - Preview UI
struct ConfettiOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        manager.todaySteps = "10,345"
        manager.dailyGoal = "10,000"
        return ConfettiOverlayView().environmentObject(manager)
    }
}
