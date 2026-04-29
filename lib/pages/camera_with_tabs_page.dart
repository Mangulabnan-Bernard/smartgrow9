import 'package:flutter/cupertino.dart';
import 'crop_detection_page.dart';

class CameraWithTabsPage extends StatelessWidget {
  const CameraWithTabsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Smart Grow AI'),
        backgroundColor: CupertinoColors.white,
        border: null,
      ),
      child: const SafeArea(
        top: false, // Don't add padding since we have navigation bar
        child: CropDetectionPage(),
      ),
    );
  }
}
