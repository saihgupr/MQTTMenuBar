# MQTTMenuBar <img src="https://i.imgur.com/9n8F8wE.png" alt="Logo" width="25" height="25">

This is a lightweight macOS menu bar application designed to display MQTT messages in your menu bar. Providing real-time status updates from your smart home devices or any MQTT-enabled system.

![MQTT Menu Bar App Demo](https://i.imgur.com/iTlUW4z.gif)

## Features

- **MQTT Connection**: Connects to a specified MQTT broker.
- **Menu Bar Status**: Displays incoming MQTT messages directly in the macOS menu bar.
- **Configurable Settings**: Easily set up broker IP/hostname, port, username, password, and topic via a dedicated setup window.
- **Launch at Login**: Option to automatically launch the application when your Mac starts.
- **Color Indicators**: Supports displaying 'red', 'yellow', or 'green' messages as colored dots in the menu bar for quick status checks.

## Configure MQTT

The first time you run it a window asks for your broker info and topic. Enter those to connect and see messages.

<img src="https://i.imgur.com/CdJwSnH.png" alt="Logo" width="500" height="500">

## Usage

- The app will display the last message received on the configured MQTT topic.
- Send messages like `red`, `yellow`, or `green` to the subscribed topic to see colored dots. Sending `no_color` will create an empty space.
- Any other message will be displayed as text.
- Click the menu bar icon to access options like 'Reset Settings' or 'Quit'.

## Setup and Running

> You can download the app from the [Releases page](https://github.com/saihgupr/MQTTMenuBar/releases)  
> Or if you prefer you can build it yourself by following these steps

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/saihgupr/MQTTMenuBar.git
    ```
2.  **Open in Xcode**: Navigate to the cloned directory and open the `.xcodeproj` file:
    ```bash
    cd MQTTMenuBar/MQTTMenuBar
    open MQTTMenuBar.xcodeproj
    ```
3.  **Install Dependencies**: Xcode should automatically resolve Swift Package Manager dependencies (CocoaMQTT, MqttCocoaAsyncSocket, Starscream). If not, go to `File > Swift Packages > Resolve Package Versions`.
4.  **Build and Run**: Select your target (e.g., `MQTTMenuBar`) and click the 'Run' button (▶️) in Xcode. The app will appear in your menu bar.
5.  **Configure MQTT**: The first time you run the app, or if settings are incomplete, a setup window will appear. Enter your MQTT broker details and topic. The app will then connect and display messages.


