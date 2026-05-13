import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import 'wifi_network_card.dart';

class WiFiList extends StatelessWidget {
  final List<WiFiNetwork> networks;
  final Function(WiFiNetwork) onNetworkTap;

  const WiFiList({
    super.key,
    required this.networks,
    required this.onNetworkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (networks.isEmpty) {
      return const Center(
        child: Text(
          "No Networks Found",
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      );
    }
    return ListView.separated(
      itemCount: networks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return WiFiNetworkCard(
          network: networks[index],
          onTap: () => onNetworkTap(networks[index]),
        );
      },
    );
  }
}