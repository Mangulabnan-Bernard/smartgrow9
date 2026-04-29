import 'package:flutter/cupertino.dart';

class ThemeSelector extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  late String _selectedTheme;

  final List<Map<String, dynamic>> _themes = [
    {'id': 'green', 'color': CupertinoColors.systemGreen, 'label': 'Botanical Green'},
    {'id': 'blue', 'color': CupertinoColors.systemBlue, 'label': 'Ocean Blue'},
    {'id': 'purple', 'color': CupertinoColors.systemPurple, 'label': 'Royal Purple'},
    {'id': 'rose', 'color': CupertinoColors.systemPink, 'label': 'Velvet Rose'},
    {'id': 'orange', 'color': CupertinoColors.systemOrange, 'label': 'Sunset Orange'},
    {'id': 'teal', 'color': CupertinoColors.systemTeal, 'label': 'Midnight Teal'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Choose Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(_selectedTheme),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 1),
          
          // Theme Options
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                final isSelected = _selectedTheme == theme['id'];
                
                return CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _selectedTheme = theme['id'] as String;
                    });
                  },
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? CupertinoColors.systemGrey5
                          : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Color Circle
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Theme Label
                        Expanded(
                          child: Text(
                            theme['label'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.label,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        // Selection Indicator
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark_circle_fill,
                            color: CupertinoColors.systemBlue,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
