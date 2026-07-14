# WiFi Band Switcher

![Flutter Version](https://img.shields.io/badge/Flutter-^3.8.1-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Android-green.svg)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

WiFi Band Switcher is a robust utility application built with Flutter that allows users to seamlessly scan, filter, and connect to WiFi networks based on their frequency bands (2.4 GHz and 5 GHz). This tool is especially useful for users dealing with dual-band routers who want explicit control over which band their device connects to.

## ✨ Features

- **Band Separation:** Automatically categorizes available networks into 2.4 GHz and 5 GHz bands.
- **Real-Time Scanning:** Fast and reliable WiFi scanning using native Android APIs.
- **Signal Strength Sorting:** Networks are automatically sorted by signal strength (strongest first).
- **Direct Connection:** Connect to Open, WPA, or WEP networks directly from the app.
- **Enterprise Support (Eduroam):** Includes native methods targeting enterprise WiFi connections.
- **Sleek UI:** Modern, dark-themed user interface with smooth gradients and intuitive controls.

## 🎥 Demo Video

<video src="demo/Wifi%20Switching.mp4" width="100%" controls="controls">

  Your browser does not support the video tag.
</video>

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Native Integration:** Android `MethodChannel` for platform-specific WiFi operations (Android `WifiManager`).
- **Icons:** `cupertino_icons`, `flutter_launcher_icons`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.8.1 or higher)
- Android Studio / Android SDK (for native Android compilation)
- A physical Android device (WiFi scanning does not work well on emulators)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rehanahmd218/wifi_frequency_switcher.git
   cd wifi_frequency_switcher
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 🔐 Permissions
The application requires the following Android permissions to function properly:
- `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` (Required for WiFi scanning on Android)
- `CHANGE_WIFI_STATE`
- `ACCESS_WIFI_STATE`

*(These are handled natively via MethodChannels when the app starts.)*

## 📁 Project Structure

- `lib/screens/`: Contains the main UI components, such as `wifi_switcher_screen.dart`.
- `lib/widgets/`: Reusable widgets like the `CustomAppBar`, `FrequencySelector`, and `WiFiList`.
- `lib/controllers/native/`: Contains `wifi_controller.dart`, which manages the `MethodChannel` communication with Android.
- `lib/models/`: Data models like `WiFiNetwork`.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/rehanahmd218/wifi_frequency_switcher/issues).

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
**Developed with ❤️ by Rehan Ahmad**
