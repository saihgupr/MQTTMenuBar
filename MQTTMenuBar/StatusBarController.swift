import AppKit
import CocoaMQTT

class StatusBarController {
    private var statusItem: NSStatusItem
    private var mqttManager: MqttManager!
    private var resetAction: () -> Void

    init(resetAction: @escaping () -> Void) {
        self.resetAction = resetAction
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = " " // Start invisible
            button.attributedTitle = NSAttributedString(string: "") // Ensure attributed title is also cleared
        }
        setupMqtt()
        setStatusText(" ") // Ensure status is invisible on launch
        createMenu()
    }

    private func createMenu() {
        let menu = NSMenu()
        let resetMenuItem = NSMenuItem(title: "Reset Settings", action: #selector(resetSettingsClicked), keyEquivalent: "")
        resetMenuItem.target = self
        menu.addItem(resetMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc private func resetSettingsClicked() {
        resetAction()
    }

    private func setupMqtt() {
        mqttManager = MqttManager(delegate: self)
    }

    func updateStatus(with message: String) {
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                // Always clear previous state
                button.attributedTitle = NSAttributedString(string: "")
                button.title = " "

                let dot = "●"
                let dotFont = NSFont.systemFont(ofSize: 14.5)
                var attributes: [NSAttributedString.Key: Any]

                switch message.lowercased() {
                case "red":
                    attributes = [.foregroundColor: NSColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1.0), .font: dotFont, .baselineOffset: -1.5]
                    button.attributedTitle = NSAttributedString(string: dot, attributes: attributes)
                case "yellow":
                    attributes = [.foregroundColor: NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0), .font: dotFont, .baselineOffset: -1.5]
                    button.attributedTitle = NSAttributedString(string: dot, attributes: attributes)
                case "green":
                    attributes = [.foregroundColor: NSColor(red: 0.196, green: 0.843, blue: 0.294, alpha: 1.0), .font: dotFont, .baselineOffset: -1.5]
                    button.attributedTitle = NSAttributedString(string: dot, attributes: attributes)
                case "no_color":
                    button.title = " "
                    button.attributedTitle = NSAttributedString(string: "")
                default:
                    // For any other message, display it as text, slightly lowered
                    let textFont = NSFont.systemFont(ofSize: 13.5, weight: .medium)
                    attributes = [.font: textFont, .baselineOffset: -1.0, .foregroundColor: NSColor.labelColor]
                    button.attributedTitle = NSAttributedString(string: message, attributes: attributes)
                }
            }
        }
    }
    
    private func setStatusText(_ text: String) {
        DispatchQueue.main.async {
            if let button = self.statusItem.button {
                button.title = text
                button.attributedTitle = NSAttributedString(string: "") // Ensure attributed title is cleared
            }
        }
    }
}

extension StatusBarController: MqttManagerDelegate {
    func mqttDidConnect() {
        setStatusText(" ") // Set to a space to make it invisible
    }
    
    func mqttDidDisconnect() {
        setStatusText(" ") // Set to a space to make it invisible
    }
    
    func mqttDidReceiveMessage(message: String) {
        updateStatus(with: message)
    }
}