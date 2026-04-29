import 'package:flutter/cupertino.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: Color(0xFFF8F9FA),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Icon(
                CupertinoIcons.leaf_arrow_circlepath,
                size: 64,
                color: CupertinoColors.systemGreen,
              ),

              SizedBox(height: 24),

              // App name
              Text(
                'SmartGrow AI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),

              SizedBox(height: 8),

              // Loading text
              Text(
                'Initializing...',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),

              SizedBox(height: 32),

              // Loading indicator
              CupertinoActivityIndicator(
                radius: 16,
                color: CupertinoColors.systemGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
