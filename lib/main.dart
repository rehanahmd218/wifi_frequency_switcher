import 'package:flutter/material.dart';
import 'screens/wifi_switcher_screen.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
    
void main() {
  runApp(const WiFiSwitcherApp());
}

class WiFiSwitcherApp extends StatelessWidget {
  const WiFiSwitcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Band Switch',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData.dark(),
      home: const WiFiSwitcherScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}