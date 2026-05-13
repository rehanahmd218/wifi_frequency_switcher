class WiFiNetwork {
  final String name;
  final String macAddress;
  final int signalStrength;
  final bool isConnected;
  final String securityType;

  WiFiNetwork({
    required this.name,
    required this.macAddress,
    required this.signalStrength,
    required this.securityType,
    this.isConnected = false,
  });

  String get signalStrengthText => '$signalStrength dBm';
  
  int get signalBars {
    if (signalStrength >= -50) return 4;
    if (signalStrength >= -60) return 3;
    if (signalStrength >= -70) return 2;
    return 1;
  }
}