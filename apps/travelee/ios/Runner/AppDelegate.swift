import Flutter
import UIKit
import GoogleMobileAds
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // 권한 상태 처리
                switch status {
                case .authorized:
                    print("Tracking authorized")
                case .denied:
                    print("Tracking denied")
                case .notDetermined:
                    print("Tracking not determined")
                case .restricted:
                    print("Tracking restricted")
                @unknown default:
                    print("Unknown tracking status")
                }
            }
        }
    }
}
