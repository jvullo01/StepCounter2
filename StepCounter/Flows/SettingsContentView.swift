import SwiftUI
import StoreKit
import MessageUI

/// Main settings flow for the app
struct SettingsContentView: View {
    
    @EnvironmentObject var manager: DataManager
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                CustomHeaderView
                ScrollView(.vertical, showsIndicators: false, content: {
                    Spacer(minLength: 10)
                    VStack {
                        CustomHeader(title: "IN-APP PURCHASES")
                        InAppPurchasesPromoBannerView
                        InAppPurchasesView
                        CustomHeader(title: "YOUR GOALS")
                        YourGoalsView
                        CustomHeader(title: "SPREAD THE WORD")
                        RatingShareView
                        CustomHeader(title: "SUPPORT & PRIVACY")
                        PrivacySupportView
                    }.padding([.leading, .trailing], 20)
                    Spacer(minLength: 20)
                }).padding(.top, 5)
            }
            if manager.showGoalSetupView {
                GoalInputOverlay().environmentObject(manager)
            }
        }
    }
    
    /// Custom header view
    private var CustomHeaderView: some View {
        ZStack {
            Text("Settings").bold()
                .foregroundColor(.white).font(.system(size: 24))
            HStack {
                Spacer()
                Button { manager.fullScreen = nil } label: {
                    Image(systemName: "xmark")
                }
            }.foregroundColor(.white).font(.system(size: 20, weight: .medium))
        }.padding(.horizontal).padding(.bottom)
    }
    
    /// Create custom header view
    private func CustomHeader(title: String, subtitle: String? = nil) -> some View {
        HStack {
            Text(title).font(.system(size: 18, weight: .medium))
            Spacer()
        }.foregroundColor(.white)
    }
    
    /// Custom settings item
    private func SettingsItem(title: String, icon: String, goal: String = "", action: @escaping() -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            action()
        }, label: {
            HStack {
                Image(systemName: icon).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22, alignment: .center)
                Text(title).font(.system(size: 18))
                Spacer()
                if !goal.isEmpty {
                    Text(Double(goal)?.formatted ?? goal).padding(.horizontal, 15).padding(.vertical, 5)
                        .background(Color.white.opacity(0.1).cornerRadius(8))
                } else {
                    Image(systemName: "chevron.right")
                }
            }.foregroundColor(.white).padding()
        })
    }
    
    // MARK: - Daily Steps Goal
    private var InAppPurchasesView: some View {
        VStack {
            SettingsItem(title: "Upgrade Premium", icon: "crown") {
                manager.fullScreen = .premium
            }
            Color.extraDarkGrayColor.frame(height: 1).opacity(0.8).padding(.horizontal)
            SettingsItem(title: "Restore Purchases", icon: "arrow.clockwise") {
                manager.fullScreen = .premium
            }
        }.padding([.top, .bottom], 5).background(
            Color.darkGrayColor.cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Goals Section
    private var YourGoalsView: some View {
        VStack {
            SettingsItem(title: "Daily Goal", icon: "figure.walk.circle", goal: manager.dailyGoal.isEmpty ? "0" : manager.dailyGoal) {
                manager.showGoalSetupView = true
            }
            Color.extraDarkGrayColor.frame(height: 1).opacity(0.8).padding(.horizontal)
            SettingsItem(title: "Monthly Goal", icon: "calendar", goal: manager.monthlyGoal) {
                manager.showGoalSetupView = true
            }
        }.padding([.top, .bottom], 5).background(
            Color.darkGrayColor.cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        ).padding(.bottom, 40)
    }
    
    private var InAppPurchasesPromoBannerView: some View {
        ZStack {
            if manager.isPremiumUser == false {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottom)
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Premium Version").bold().font(.system(size: 20))
                            Text("- Unlock Statistics").font(.system(size: 15)).opacity(0.7)
                            Text("- Remove Ads").font(.system(size: 15)).opacity(0.7)
                        }
                        Spacer()
                        Image(systemName: "crown.fill").font(.system(size: 45))
                    }.foregroundColor(.white).padding([.leading, .trailing], 20)
                }.frame(height: 110).cornerRadius(15).padding(.bottom, 5)
            }
        }
    }
    
    // MARK: - Rating and Share
    private var RatingShareView: some View {
        VStack {
            SettingsItem(title: "Rate App", icon: "star") {
                if let scene = UIApplication.shared.windows.first?.windowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
            Color.extraDarkGrayColor.frame(height: 1).opacity(0.8).padding(.horizontal)
            SettingsItem(title: "Share App", icon: "square.and.arrow.up") {
                let shareController = UIActivityViewController(activityItems: [AppConfig.yourAppURL], applicationActivities: nil)
                rootController?.present(shareController, animated: true, completion: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color.darkGrayColor.cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        ).padding(.bottom, 40)
    }
    
    // MARK: - Support & Privacy
    private var PrivacySupportView: some View {
        VStack {
            SettingsItem(title: "E-Mail us", icon: "envelope.badge") {
                EmailPresenter.shared.present()
            }
            Color.extraDarkGrayColor.frame(height: 1).opacity(0.8).padding(.horizontal)
            SettingsItem(title: "Privacy Policy", icon: "hand.raised") {
                UIApplication.shared.open(AppConfig.privacyURL, options: [:], completionHandler: nil)
            }
            Color.extraDarkGrayColor.frame(height: 1).opacity(0.8).padding(.horizontal)
            SettingsItem(title: "Terms of Use", icon: "doc.text") {
                UIApplication.shared.open(AppConfig.termsAndConditionsURL, options: [:], completionHandler: nil)
            }
        }.padding([.top, .bottom], 5).background(
            Color.darkGrayColor.cornerRadius(15)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        )
    }
}

// MARK: - Preview UI
struct SettingsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = DataManager()
        return SettingsContentView().environmentObject(manager)
    }
}

// MARK: - Mail presenter for SwiftUI
class EmailPresenter: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailPresenter()
    private override init() { }
    
    func present() {
        if !MFMailComposeViewController.canSendMail() {
            presentAlert(title: "Email Client", message: "Your device must have the native iOS email app installed for this feature.")
            return
        }
        let picker = MFMailComposeViewController()
        picker.setToRecipients([AppConfig.emailSupport])
        picker.mailComposeDelegate = self
        rootController?.present(picker, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        rootController?.dismiss(animated: true, completion: nil)
    }
}

