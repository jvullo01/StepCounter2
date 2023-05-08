import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    static let adMobAdId: String = "ca-app-pub-3940256099942544/4411468910"
    
    // MARK: - Settings flow items
    static let emailSupport = "jvullo01@gmail.com"
    static let privacyURL: URL = URL(string: "https://www.google.com/")!
    static let termsAndConditionsURL: URL = URL(string: "https://www.google.com/")!
    static let yourAppURL: URL = URL(string: "https://apps.apple.com/app/idXXXXXXXXX")!
    
    // MARK: - Generic Configurations
    static let appLaunchDelay: TimeInterval = 1.5
    static let confettiDuration: TimeInterval = 2.5
    static let confettiSpeed: CGFloat = 450
    static let confettiColors: [Color] = [Color(#colorLiteral(red: 0.1884031892, green: 0.6164012551, blue: 0.7388934493, alpha: 1)), Color(#colorLiteral(red: 0.1884031892, green: 0.7812900772, blue: 0.7388934493, alpha: 1)), Color(#colorLiteral(red: 0.8304590583, green: 0.2868802845, blue: 0.5694329143, alpha: 1)), Color(#colorLiteral(red: 0.9708533654, green: 0.2868802845, blue: 0.5694329143, alpha: 1)), Color(#colorLiteral(red: 0.5536777973, green: 0.4510317445, blue: 0.9476286769, alpha: 1)), Color(#colorLiteral(red: 0.5536777973, green: 0.6288913198, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.973535955, green: 0.2599409819, blue: 0.299492985, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.493189179, blue: 0.299492985, alpha: 1))]
    
    // MARK: - In App Purchases
    static let premiumVersion: String = "LiveStep.Premium"
}

// MARK: - Full Screen flow
enum FullScreenMode: Int, Identifiable {
    case premium, statistics, settings
    var id: Int { hashValue }
}

// MARK: - Daily Achievement
enum DailyAchievementType: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case wellDone = "Well Done"
    case greatJob = "Great Job"
    case awesome = "Awesome!"
    case unstoppable = "Unstoppable"
    case legend = "Legend"
    var id: Int { hashValue }
}

// MARK: - Color configurations
extension Color {
    static let darkGrayColor: Color = Color("DarkGrayColor")
    static let extraDarkGrayColor: Color = Color("ExtraDarkGrayColor")
    static let accentLightColor: Color = Color("AccentLightColor")
    static let backgroundColor: Color = Color("BackgroundColor")
    static let lightColor: Color = Color("LightColor")
}

