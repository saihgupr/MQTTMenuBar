
import SwiftUI

struct SetupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var broker: String = ""
    @State private var port: String = "1883"
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var topic: String = ""
    @State private var showAlert = false
    @State private var launchAtLogin: Bool = LoginItemManager.launchAtLoginEnabled()

    var completion: () -> Void // New completion closure

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("MQTT Configuration")
                .font(.title)
                .padding(.bottom, 10)

            TextField("Broker IP/Hostname", text: $broker)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Port (e.g., 1883)", text: $port)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Username (optional)", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password (optional)", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Topic (e.g., my/sensor/data)", text: $topic)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Toggle(isOn: $launchAtLogin) {
                Text("Launch at Login")
            }
            .padding(.horizontal)
            .onChange(of: launchAtLogin) { newValue in
                LoginItemManager.setLaunchAtLogin(enabled: newValue)
            }

            Button("Save Settings") {
                saveSettings()
            }
            .padding()
            .buttonStyle(DefaultButtonStyle())

        }
        .padding()
        .frame(minWidth: 400, minHeight: 450)
        .onAppear(perform: loadSettings)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text("Please provide Broker IP/Hostname, Port, and Topic."), dismissButton: .default(Text("OK")))
        }
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard
        broker = defaults.string(forKey: MqttManager.mqttBrokerKey) ?? ""
        let savedPort = defaults.integer(forKey: MqttManager.mqttPortKey)
        port = (savedPort == 0) ? "1883" : String(savedPort)
        username = defaults.string(forKey: MqttManager.mqttUsernameKey) ?? ""
        password = defaults.string(forKey: MqttManager.mqttPasswordKey) ?? ""
        topic = defaults.string(forKey: MqttManager.mqttTopicKey) ?? ""
    }

    private func saveSettings() {
        guard !broker.isEmpty, let portInt = Int(port), !topic.isEmpty else {
            showAlert = true
            return
        }

        let defaults = UserDefaults.standard
        defaults.set(broker, forKey: MqttManager.mqttBrokerKey)
        defaults.set(portInt, forKey: MqttManager.mqttPortKey)
        defaults.set(username, forKey: MqttManager.mqttUsernameKey)
        defaults.set(password, forKey: MqttManager.mqttPasswordKey)
        defaults.set(topic, forKey: MqttManager.mqttTopicKey)
        
        // Call the completion handler to dismiss the window
        completion()
    }
}
