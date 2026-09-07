import Flutter
import Foundation

/// Flutter ↔ Native bridge for cheat inject / restore operations.
/// File cheat sources are fetched from:
///   https://github.com/mkiw1464-debug/kntollshahhaha/
///
/// Inject path: Documents/contentcache/Compulsory/ios/gameassetbundles/
///   FF  → com.dts.freefireth
///   FFM → com.dts.freefiremax

final class InjectChannel {
    static let channelName = "com.ffexternal.inject"
    
    // GitHub raw base — we pull cheat files on demand
    // Folder structure: /FreeFire/{Feature}/ or /FreeFireMax/{Feature}/
    private static let githubBase =
        "https://raw.githubusercontent.com/mkiw1464-debug/kntollshahhaha/main"
    
    // Sub-path inside game container
    private static let assetSubpath =
        "Documents/contentcache/Compulsory/ios/gameassetbundles"
    
    // Backup dir inside our app's Documents
    private static var backupRoot: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("FFExternal_Backups")
    }
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: channelName,
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler { call, result in
            handleCall(call, result: result)
        }
    }
    
    // MARK: - Dispatch
    
    static func handleCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: String] ?? [:]
        let game = args["game"] ?? ""
        let feature = args["feature"] ?? ""
        
        switch call.method {
        case "checkFeatureAvailable":
            checkAvailability(game: game, feature: feature, result: result)
        case "inject":
            injectFeature(game: game, feature: feature, result: result)
        case "restore":
            restoreFeature(game: game, feature: feature, result: result)
        case "isInjected":
            result(isInjected(game: game, feature: feature))
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Check availability
    
    static func checkAvailability(game: String, feature: String, result: @escaping FlutterResult) {
        Task {
            let available = await remoteFileExists(game: game, feature: feature)
            DispatchQueue.main.async { result(available) }
        }
    }
    
    static func remoteFileExists(game: String, feature: String) async -> Bool {
        guard let info = cheatInfo(game: game, feature: feature) else { return false }
        guard let url = URL(string: "\(githubBase)/\(info.remotePath)") else { return false }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        req.httpMethod = "HEAD"
        do {
            let (_, resp) = try await URLSession.shared.data(for: req)
            return (resp as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Inject
    
    static func injectFeature(game: String, feature: String, result: @escaping FlutterResult) {
        Task {
            do {
                // 1. Resolve container
                guard let containerPath = resolveContainerPath(bundleId: game) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_CONTAINER",
                                            message: "Cannot access \(game) container",
                                            details: nil))
                    }
                    return
                }
                
                // 2. Find target asset file
                let assetDir = URL(fileURLWithPath: containerPath)
                    .appendingPathComponent(assetSubpath)
                
                guard let info = cheatInfo(game: game, feature: feature) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_INFO",
                                            message: "Unknown feature",
                                            details: nil))
                    }
                    return
                }
                
                let targetURL = assetDir.appendingPathComponent(info.targetFile)
                guard FileManager.default.fileExists(atPath: targetURL.path) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_TARGET",
                                            message: "Target asset not found: \(info.targetFile)",
                                            details: nil))
                    }
                    return
                }
                
                // 3. Backup original
                let backupURL = backupPath(game: game, feature: feature, file: info.targetFile)
                try FileManager.default.createDirectory(
                    at: backupURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if !FileManager.default.fileExists(atPath: backupURL.path) {
                    try FileManager.default.copyItem(at: targetURL, to: backupURL)
                }
                
                // 4. Download cheat file
                guard let remoteURL = URL(string: "\(githubBase)/\(info.remotePath)") else {
                    throw NSError(domain: "FFExternal", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid remote URL"])
                }
                let (data, resp) = try await URLSession.shared.data(from: remoteURL)
                guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
                    throw NSError(domain: "FFExternal", code: -2, userInfo: [NSLocalizedDescriptionKey: "Cheat file not found on server"])
                }
                
                // 5. Write to temp, then atomically replace
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                try data.write(to: tempURL)
                defer { try? FileManager.default.removeItem(at: tempURL) }
                
                _ = try FileReplacementService.replace(
                    target: targetURL,
                    with: tempURL
                )
                
                DispatchQueue.main.async { result(true) }
                
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "INJECT_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
            }
        }
    }
    
    // MARK: - Restore
    
    static func restoreFeature(game: String, feature: String, result: @escaping FlutterResult) {
        Task {
            do {
                guard let containerPath = resolveContainerPath(bundleId: game) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_CONTAINER",
                                            message: "Cannot access \(game) container",
                                            details: nil))
                    }
                    return
                }
                
                guard let info = cheatInfo(game: game, feature: feature) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_INFO", message: "Unknown feature", details: nil))
                    }
                    return
                }
                
                let assetDir = URL(fileURLWithPath: containerPath)
                    .appendingPathComponent(assetSubpath)
                let targetURL = assetDir.appendingPathComponent(info.targetFile)
                let backupURL = backupPath(game: game, feature: feature, file: info.targetFile)
                
                guard FileManager.default.fileExists(atPath: backupURL.path) else {
                    DispatchQueue.main.async {
                        result(FlutterError(code: "NO_BACKUP",
                                            message: "No backup found for \(feature)",
                                            details: nil))
                    }
                    return
                }
                
                _ = try FileReplacementService.replace(
                    target: targetURL,
                    with: backupURL
                )
                
                // Remove backup after restore
                try? FileManager.default.removeItem(at: backupURL)
                
                DispatchQueue.main.async { result(true) }
            } catch {
                DispatchQueue.main.async {
                    result(FlutterError(code: "RESTORE_FAILED",
                                        message: error.localizedDescription,
                                        details: nil))
                }
            }
        }
    }
    
    // MARK: - Is Injected
    
    static func isInjected(game: String, feature: String) -> Bool {
        guard let info = cheatInfo(game: game, feature: feature) else { return false }
        let backupURL = backupPath(game: game, feature: feature, file: info.targetFile)
        return FileManager.default.fileExists(atPath: backupURL.path)
    }
    
    // MARK: - Helpers
    
    private static func resolveContainerPath(bundleId: String) -> String? {
        var err: NSString?
        if let path = MCMActivateContainerPath(2, bundleId, false, &err) {
            return path
        }
        return ContainerStore.resolveAppContainerPathByMetadataScan(bundleID: bundleId)
    }
    
    private static func backupPath(game: String, feature: String, file: String) -> URL {
        let safe = game.replacingOccurrences(of: ".", with: "_")
        return backupRoot
            .appendingPathComponent(safe)
            .appendingPathComponent(feature)
            .appendingPathComponent(file)
    }
    
    // MARK: - Cheat file registry
    // Maps (bundleId, feature folder) → (remote repo path, target file in gameassetbundles)
    
    struct CheatInfo {
        let remotePath: String  // path inside github repo
        let targetFile: String  // filename inside gameassetbundles/
    }
    
    private static func cheatInfo(game: String, feature: String) -> CheatInfo? {
        let gameFolder: String
        switch game {
        case "com.dts.freefireth": gameFolder = "FreeFire"
        case "com.dts.freefiremax": gameFolder = "FreeFireMax"
        default: return nil
        }
        
        // Feature → target asset filename mapping
        // These are the actual bundle files FF uses for the related render/net code
        let targetMap: [String: String] = [
            "Aimbody":      "character.bundle",
            "Aimneck":      "character_neck.bundle",
            "Aimdrag":      "aim_drag.bundle",
            "Magic Bullet": "projectile.bundle",
            "Antena":       "antenna.bundle",
            "Hologram":     "hologram.bundle",
        ]
        
        guard let target = targetMap[feature] else { return nil }
        
        return CheatInfo(
            remotePath: "\(gameFolder)/\(feature)/\(target)",
            targetFile: target
        )
    }
}
