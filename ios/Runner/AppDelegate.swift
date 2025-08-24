import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)

    // Initialize the Flutter method channel for file protection management
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let fileProtectionChannel = FlutterMethodChannel(name: "com.jogoempatia.empatiatrack.fileProtection",
                                                      binaryMessenger: controller.binaryMessenger)
    fileProtectionChannel.setMethodCallHandler({ (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "unlockFirestoreData" {
            do {
                try self.unlockFirestoreData()
                result("Firestore data directory unlocked.")
            } catch {
                result(FlutterError(code: "UNLOCK_ERROR", message: "Failed to unlock Firestore data", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Function to unlock Firestore data directory by removing file protection
  func unlockFirestoreData() throws {
    let attributes = [FileAttributeKey.protectionKey: FileProtectionType.none]

    let dirs = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
    let firestoreDir = dirs[0].appending("/firestore")

    if !FileManager.default.fileExists(atPath: firestoreDir, isDirectory: nil) {
      try FileManager.default.createDirectory(atPath: firestoreDir, withIntermediateDirectories: true, attributes: attributes)
      return
    }

    let files = FileManager.default.enumerator(atPath: firestoreDir)
    while let file = files?.nextObject() as? String {
      let fullPath = (firestoreDir as NSString).appendingPathComponent(file)
      try FileManager.default.setAttributes(attributes, ofItemAtPath: fullPath)
    }
  }
}
