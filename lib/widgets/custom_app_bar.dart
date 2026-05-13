import 'package:flutter/material.dart';
import 'package:testing_project/controllers/native/wifi_controller.dart';


class CustomAppBar extends StatefulWidget {
  const CustomAppBar({
    super.key,
    required this.onScan,
    required this.onScanComplete,
  });

  final Function? onScan;
  final Function? onScanComplete;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool isLoading = false;

  void getCleanResults() async {
    // if (isLoading) return; // Prevent multiple simultaneous scans

    setState(() {
      isLoading = true;
    });
    widget.onScan?.call();

    await WifiNative.getCleanResults();

    setState(() {
      isLoading = false;
    });

    // Notify parent that scan completed
    widget.onScanComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'WiFi Band Switch',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: isLoading ? null : getCleanResults, // Disable tap when loading
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isLoading
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(Icons.search, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  isLoading ? 'Scanning...' : 'Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
