import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing_project/data/networks.dart';
import 'package:testing_project/main.dart';
import 'package:testing_project/models/wifi_network.dart';

class WifiNative {
  static const platform = MethodChannel(
    'com.example.testing_project/wifi_control',
  );

  static Future<bool> askPermissions() async {
    try {
      final granted = await platform.invokeMethod<bool>('askWifiPermissions');
      return granted ?? false;
    } on PlatformException catch (e) {
      _showSnackbar("Permission error: ${e.message}", Colors.red);
      return false;
    } catch (e) {
      _showSnackbar("Unexpected error: $e", Colors.red);
      return false;
    }
  }

  static Future<List<Map<dynamic, dynamic>>> getWifiScanResults() async {
    try {
      final results = await platform.invokeMethod<List<dynamic>>(
        'getWifiScanResults',
      );
      return results?.cast<Map<dynamic, dynamic>>() ?? [];
    } on PlatformException catch (e) {
      _showSnackbar("Scan failed: ${e.message}", Colors.red);
      return [];
    } catch (e) {
      _showSnackbar("Unexpected error: ${e.toString()}", Colors.red);
      return [];
    }
  }

  static Future<void> getCleanResults() async {
    // Clear existing networks
    fiveGhzNetworks.clear();
    twoPointFourGhzNetworks.clear();

    if (await WifiNative.askPermissions()) {
      final scanResults = await WifiNative.getWifiScanResults();

      if (scanResults.isNotEmpty) {
        // 🔹 Sort by signal strength (descending: strongest first)
        scanResults.sort((a, b) {
          final levelA = a['level'] ?? -100;
          final levelB = b['level'] ?? -100;
          return levelB.compareTo(levelA); // strongest first
        });


        for (var network in scanResults) {
          final newNetwork = WiFiNetwork(
            name: network['ssid'] ?? 'Unknown SSID',
            macAddress: network['bssid'] ?? 'Unknown BSSID',
            signalStrength: network['level'] ?? -100,
            securityType: network['securityType'] ?? 'OPEN',
          );
          if (network['frequency'] >= 4900 && network['frequency'] <= 5900) {
            // 5 GHz band
            fiveGhzNetworks.add(newNetwork);
          } else if (network['frequency'] >= 2400 &&
              network['frequency'] <= 2500) {
            // 2.4 GHz band
            twoPointFourGhzNetworks.add(newNetwork);
          }
        }
      }
    }
  }


  static Future<bool> connectToWifi(
    WiFiNetwork network,
    String password,
  ) async {
    if (!await WifiNative.askPermissions()) {
      return false;
    }

    final ssid = network.name;
    final bssid = network.macAddress;
    final finalPassword = password; // Assuming open network for simplicity
    final securityType = network.securityType;
    try {
      // Example usage
      final success = await platform.invokeMethod('connectToWifi', {
        'ssid': ssid,
        'password': finalPassword,
        'securityType': securityType,
        'bssid': bssid, // Optional BSSID
      });
      if (success == true) {
        _showSnackbar("Network Suggestion Added Successfully ✅", Colors.green);
        return true;
      } else {
        _showSnackbar("Not able to add network Suggestion", Colors.orange);
        return false;
      }
    } on PlatformException catch (e) {
      _showSnackbar("Connection error: ${e.message}", Colors.red);
      return false;
    } catch (e) {
      _showSnackbar("Unexpected error: $e", Colors.red);
      return false;
    }
  }


static Future<Map<String, dynamic>> getCurrentWifiInfo() async {
    try {
      final result = await platform.invokeMethod('getCurrentWifiInfo');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {};
    } catch (e) {
      debugPrint("Error getting current WiFi info: $e");
      return {};
    }
}


  static void _showSnackbar(String message, Color color) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

static Future<void> connectEduroam()async{
  try {
    await platform.invokeMethod('connectToEnterpriseWifi', {
    });
  } catch (e) {
    _showSnackbar(e.toString(), Colors.red);
  }
}


  static void openWifiSettings(String ssid){
    try {
      platform.invokeMethod('openWifiSettingsForNetwork', {
        'ssid': ssid,
      });
    } catch (e) {
      print("Error opening WiFi settings: $e");
    }
  }
}
