import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Load Google Maps API Key from keys.plist or use default
    var apiKey = "AIzaSyDiqD-Nz7pM1gfOYvqKn0VNjVN1D1PODdk" // Default key

    if let path = Bundle.main.path(forResource: "keys", ofType: "plist"),
       let keys = NSDictionary(contentsOfFile: path),
       let key = keys["GOOGLE_MAPS_API_KEY"] as? String {
      apiKey = key
    }

    // ALWAYS provide the API key before any other initialization
    GMSServices.provideAPIKey(apiKey)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
