
import Foundation
import CocoaMQTT

protocol MqttManagerDelegate: AnyObject {
    func mqttDidReceiveMessage(message: String)
    func mqttDidConnect()
    func mqttDidDisconnect()
}

class MqttManager {
    weak var delegate: MqttManagerDelegate?
    var mqttClient: CocoaMQTT!
    private var mqttTopic: String!
    private let reconnectDelay: TimeInterval = 5.0 // 5 seconds

    // Keys for UserDefaults
    static let mqttBrokerKey = "mqttBroker"
    static let mqttPortKey = "mqttPort"
    static let mqttUsernameKey = "mqttUsername"
    static let mqttPasswordKey = "mqttPassword"
    static let mqttTopicKey = "mqttTopic"

    static func areMqttSettingsComplete() -> Bool {
        let defaults = UserDefaults.standard
        let port = defaults.integer(forKey: mqttPortKey)
        return defaults.string(forKey: mqttBrokerKey) != nil &&
               defaults.string(forKey: mqttTopicKey) != nil &&
               port > 0
    }

    init(delegate: MqttManagerDelegate) {
        self.delegate = delegate

        let defaults = UserDefaults.standard

        guard let broker = defaults.string(forKey: MqttManager.mqttBrokerKey),
              let port = defaults.object(forKey: MqttManager.mqttPortKey) as? Int,
              let topic = defaults.string(forKey: MqttManager.mqttTopicKey) else {
            print("Failed to load MQTT configuration from UserDefaults. Cannot initialize MqttManager.")
            if let delegate = self.delegate { // Fixed: Explicitly unwrap delegate
                delegate.mqttDidDisconnect()
            }
            return
        }

        let username = defaults.string(forKey: MqttManager.mqttUsernameKey)
        let password = defaults.string(forKey: MqttManager.mqttPasswordKey)

        print("MQTT Settings Loaded:")
        print("  Broker: \(broker)")
        print("  Port: \(port)")
        print("  Topic: \(topic)")
        print("  Username: \(username ?? "N/A")")
        print("  Password: \(password != nil ? "Set" : "N/A")")

        self.mqttTopic = topic
        self.mqttClient = CocoaMQTT(clientID: "MqttMenuBarApp", host: broker, port: UInt16(port))
        self.mqttClient.username = username
        self.mqttClient.password = password
        self.mqttClient.cleanSession = true // Ensure a clean session to avoid retained messages
        self.mqttClient.keepAlive = 45 // Set keep alive interval to 45 seconds
        self.mqttClient.delegate = self
        let _ = self.mqttClient.connect()
    }
}

extension MqttManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            print("MQTT Connected successfully!")
            if let delegate = self.delegate {
                delegate.mqttDidConnect()
            }
            mqtt.subscribe(mqttTopic)
        } else {
            print("MQTT Connection failed with ack: \(ack.rawValue)")
            if let delegate = self.delegate {
                delegate.mqttDidDisconnect()
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {}

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let msgString = message.string {
            print("MQTT Received Message: \(msgString)") // Added logging
            if let delegate = self.delegate { // Fixed: Explicitly unwrap delegate
                delegate.mqttDidReceiveMessage(message: msgString)
            }
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {}

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {}

    func mqttDidPing(_ mqtt: CocoaMQTT) {}

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {}

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT Disconnected. Error: \(err?.localizedDescription ?? "None")")
        if let delegate = self.delegate {
            delegate.mqttDidDisconnect()
        }
        
        // Attempt to reconnect after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            guard let self = self else { return }
            print("Attempting to reconnect MQTT...")
            let _ = self.mqttClient.connect()
        }
    }
}

extension MqttManager {
    func reconnect() {
        if let mqttClient = self.mqttClient {
            print("Reconnecting MQTT client...")
            let _ = mqttClient.connect()
        } else {
            print("MQTT client not initialized, cannot reconnect.")
        }
    }
}
