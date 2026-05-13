import 'package:flutter/material.dart';
import 'package:testing_project/controllers/native/wifi_controller.dart';
import 'package:testing_project/data/networks.dart';
import 'package:testing_project/models/wifi_network.dart';
import 'package:testing_project/widgets/custom_app_bar.dart';
import 'package:testing_project/widgets/frequency_selector.dart';
import 'package:testing_project/widgets/wifi_list.dart';

class WiFiSwitcherScreen extends StatefulWidget {
  const WiFiSwitcherScreen({super.key});

  @override
  State<WiFiSwitcherScreen> createState() => _WiFiSwitcherScreenState();
}

class _WiFiSwitcherScreenState extends State<WiFiSwitcherScreen> {
  bool is5GHzSelected = true;
  bool isLoading = false; // This will control the WiFi list loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black.withValues(alpha: .3),
        onPressed: () => _showInfoDialog(),
        child: Icon(Icons.info_outline, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 15, 23, 42), // Slate-900
              Color.fromARGB(255, 30, 41, 59), // Slate-800
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                CustomAppBar(
                  onScan: () {
                    setState(() {
                      isLoading =
                          true; // Show loading in WiFi list when scan starts
                    });
                  },
                  onScanComplete: () {
                    setState(() {
                      isLoading = false; // Hide loading when scan completes
                    });
                  },
                ),
                const SizedBox(height: 40),
                FrequencySelector(
                  is5GHzSelected: is5GHzSelected,
                  onFrequencyChanged: (bool selected) {
                    setState(() {
                      is5GHzSelected = selected;
                    });
                  },
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Scanning for networks...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : WiFiList(
                          networks: is5GHzSelected
                              ? fiveGhzNetworks
                              : twoPointFourGhzNetworks,
                          onNetworkTap: (WiFiNetwork network) {
                            _connectToNetwork(network);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectToNetwork(WiFiNetwork network) async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Connecting to ${network.name}...'),
    //     backgroundColor: const Color(0xFF38B2AC),
    //   ),
    // );
    String password = '';
    if (network.securityType != 'OPEN') {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Password for ${network.name}'),
            content: TextField(
              onChanged: (value) {
                password = value;
              },
              obscureText: false,
              decoration: InputDecoration(hintText: 'Password'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (password.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Connecting to ${network.name} with password $password...',
                        ),
                        backgroundColor: const Color(0xFF38B2AC),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password is required to connect to ${network.name}.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Connect'),
              ),
            ],
          );
        },
      );
    }

    // WifiNative.getCurrentWifiInfo();

    if (password.isNotEmpty || network.securityType.trim() == 'OPEN') {
      await WifiNative.connectToWifi(network, password);
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Connection Info'),
            ],
          ),
          content: Text(
            'If WiFi doesn\'t connect automatically after some time, go to WiFi settings and manually connect to the network, then forget it.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
