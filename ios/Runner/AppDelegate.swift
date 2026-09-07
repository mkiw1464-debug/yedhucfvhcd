import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)
        
        // Register inject channel
        if let controller = window?.rootViewController as? FlutterViewController {
            let registrar = registrar(forPlugin: "InjectChannelPlugin")
            // Register our native channel directly on the binary messenger
            let channel = FlutterMethodChannel(
                name: InjectChannel.channelName,
                binaryMessenger: controller.binaryMessenger
            )
            channel.setMethodCallHandler { call, result in
                InjectChannel.handleCall(call, result: result)
            }
        }
        
        // Start kernel exploit silently in background
        DispatchQueue.global(qos: .background).async {
            log("FFExternal: launching exploit chain")
            let ok = KernelExploit.run()
            log("FFExternal: exploit chain \(ok ? "SUCCESS" : "FAILED")")
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
