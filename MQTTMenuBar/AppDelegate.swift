
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var setupWindow: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check if MQTT settings are complete
        if !MqttManager.areMqttSettingsComplete() {
            showSetupWindow()
        } else {
            // Settings are complete, proceed with normal app launch
            setupStatusBarApp()
        }
    }

    func setupStatusBarApp() {
        // Ensure this is called only once after settings are available
        if statusBarController == nil {
            statusBarController = StatusBarController(resetAction: { [weak self] in
                self?.resetMqttSettings()
            })
        }
    }

    func showSetupWindow() {
        setupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 450), // Increased height for better fit
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        setupWindow?.center()
        setupWindow?.setFrameAutosaveName("MQTTSetupWindow")
        setupWindow?.isReleasedWhenClosed = false // Keep window in memory

        let setupView = SetupView { [weak self] in
            // This closure is called when settings are saved in SetupView
            self?.setupWindow?.close()
            self?.setupStatusBarApp()
        }
        setupWindow?.contentView = NSHostingView(rootView: setupView)
        setupWindow?.makeKeyAndOrderFront(nil)
        
        // Bring app to front and activate it
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func resetMqttSettings() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: MqttManager.mqttBrokerKey)
        UserDefaults.standard.removeObject(forKey: MqttManager.mqttPortKey)
        UserDefaults.standard.removeObject(forKey: MqttManager.mqttUsernameKey)
        UserDefaults.standard.removeObject(forKey: MqttManager.mqttPasswordKey)
        UserDefaults.standard.removeObject(forKey: MqttManager.mqttTopicKey)
        
        // Invalidate current status bar controller and MQTT connection
        statusBarController = nil
        
        // Show setup window again
        showSetupWindow()
    }
}
