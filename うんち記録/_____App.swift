//___FILEHEADER___

import SwiftUI
import FirebaseCore

@main
struct UnchiKirokuApp: App {
    @UIApplicationDelegateAdaptor(BloomAppDelegate.self) private var appDelegate

    init() {
        FirebaseBootstrap.configureIfNeeded()
        #if DEBUG
        let hasPlist = Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil
        print("[Firebase] GoogleService-Info.plist in bundle: \(hasPlist)")
        #endif
        if FirebaseBootstrap.didConfigure {
            AppAnalytics.log(.app_launch)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
