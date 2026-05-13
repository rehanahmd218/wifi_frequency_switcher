import 'package:flutter/material.dart';
import '../models/wifi_network.dart';
import 'signal_strength_indicator.dart';
import 'connect_button.dart';

class WiFiNetworkCard extends StatelessWidget {
  final WiFiNetwork network;
  final VoidCallback onTap;

  const WiFiNetworkCard({
    super.key,
    required this.network,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  network.macAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                'Signal: ${network.signalStrengthText}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              SignalStrengthIndicator(strength: network.signalBars),
              const SizedBox(height: 8),
              if (network.securityType != 'OPEN')
                Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey[400],
                )
               
            ],
          ),
          const SizedBox(width: 16),
          ConnectButton(onPressed: onTap),
        ],
      ),
    );
  }
}