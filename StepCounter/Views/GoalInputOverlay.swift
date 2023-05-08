import SwiftUI

/// Input view for the goals
struct GoalInputOverlay: View {
    
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
                        ZStack {
                            Text("Your ") + Text("Goals").bold()
                        }.font(.system(size: 24))
                        Text("Enter your daily & monthly steps target").opacity(0.5)
                    }.foregroundColor(.extraDarkGrayColor)
                    GoalsInputViewsSection
                    Button { exitFlow() } label: {
                        ZStack {
                            Color.accentLightColor.cornerRadius(10)
                            Text("Update Goals").font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color.lightColor)
                        }
                    }.frame(height: 50)
                }
                .padding().background(Color.lightColor.cornerRadius(20))
                .padding(.horizontal, 10)
                .offset(y: startEnterAnimation ? (startExitAnimation ? UIScreen.main.bounds.height : 0) : UIScreen.main.bounds.height)
                Spacer()
            }
        }
        /// Initial configurations when the view appears
        .onAppear {
            if startEnterAnimation == false {
                withAnimation {
                    startEnterAnimation = true
                }
            }
        }
    }
    
    /// Exit flow action
    private func exitFlow() {
        hideKeyboard()
        withAnimation { startExitAnimation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.manager.showGoalSetupView = false
        }
    }
    
    /// Goals input views
    private var GoalsInputViewsSection: some View {
        VStack {
            TextField("Daily Goal: 10,000 steps", text: $manager.dailyGoal)
                .padding(12).padding(.horizontal, 5).background(
                    Color.darkGrayColor.opacity(0.05).cornerRadius(8)
                ).keyboardType(.numberPad).foregroundColor(.black)
            TextField("Monthly Goal: 100,000 steps", text: $manager.monthlyGoal)
                .padding(12).padding(.horizontal, 5).background(
                    Color.darkGrayColor.opacity(0.05).cornerRadius(8)
                ).keyboardType(.numberPad).foregroundColor(.black)
        }
    }
}

// MARK: - Preview UI
struct GoalInputOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return GoalInputOverlay().environmentObject(manager)
    }
}

