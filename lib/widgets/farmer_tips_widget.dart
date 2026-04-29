import 'package:flutter/cupertino.dart';

class FarmerTipsWidget extends StatefulWidget {
  const FarmerTipsWidget({super.key});

  @override
  State<FarmerTipsWidget> createState() => _FarmerTipsWidgetState();
}

class _FarmerTipsWidgetState extends State<FarmerTipsWidget> {
  int _tipIndex = 0;

  final List<String> _farmerTips = [
    "Water your plants early in the morning to reduce evaporation and prevent fungal diseases.",
    "Check soil moisture before watering - stick your finger 2 inches deep into the soil.",
    "Rotate your crops each season to prevent soil-borne diseases and nutrient depletion.",
    "Use mulch around plants to retain moisture and suppress weeds naturally.",
    "Remove dead or yellowing leaves immediately to prevent disease spread.",
    "Ensure good air circulation around plants to prevent fungal infections.",
    "Test your soil pH annually to ensure optimal nutrient availability.",
    "Companion planting can naturally repel pests and improve plant health.",
    "Avoid overwatering - most plants prefer slightly dry conditions to waterlogged soil.",
    "Harvest regularly to encourage continued production and plant health.",
  ];

  @override
  void initState() {
    super.initState();
    _startTipRotation();
  }

  void _startTipRotation() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _tipIndex = (_tipIndex + 1) % _farmerTips.length;
        });
        _startTipRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.systemGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.lightbulb,
                color: CupertinoColors.systemGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Farmer\'s Tip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _farmerTips[_tipIndex],
              key: ValueKey(_tipIndex),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < _farmerTips.length; i++)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: i == _tipIndex
                        ? CupertinoColors.systemGreen
                        : CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
