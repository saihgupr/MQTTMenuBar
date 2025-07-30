
import Foundation
import ServiceManagement

class LoginItemManager {
    static func setLaunchAtLogin(enabled: Bool) {
        if enabled {
            do {
                try SMAppService.mainApp.register()
            } catch {
                print("Failed to register login item: \(error)")
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                print("Failed to unregister login item: \(error)")
            }
        }
    }

    static func launchAtLoginEnabled() -> Bool {
        return SMAppService.mainApp.status == .enabled
    }
}
