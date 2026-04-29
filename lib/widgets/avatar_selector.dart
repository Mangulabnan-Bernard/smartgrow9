import 'package:flutter/cupertino.dart';

class AvatarSelector extends StatefulWidget {
  final String currentAvatar;
  final Function(String) onAvatarChanged;

  const AvatarSelector({
    super.key,
    required this.currentAvatar,
    required this.onAvatarChanged,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatar;
  }

  final List<Map<String, dynamic>> _avatars = [
    {'id': 'Persona1', 'icon': CupertinoIcons.person, 'label': 'The Botanist'},
    {'id': 'Persona2', 'icon': CupertinoIcons.person_2, 'label': 'The Plant Doc'},
    {'id': 'Persona3', 'icon': CupertinoIcons.person, 'label': 'Happy Harvester'},
    {'id': 'Persona4', 'icon': CupertinoIcons.person_crop_circle, 'label': 'Seed Sower'},
    {'id': 'Persona5', 'icon': CupertinoIcons.person_badge_plus, 'label': 'Garden Guide'},
    {'id': 'Persona6', 'icon': CupertinoIcons.person_crop_rectangle, 'label': 'Flora Fanatic'},
    {'id': 'Persona7', 'icon': CupertinoIcons.person_crop_square_fill, 'label': 'Soil Scientist'},
    {'id': 'Persona8', 'icon': CupertinoIcons.person_2_square_stack, 'label': 'Nature Ninja'},
    {'id': 'Persona9', 'icon': CupertinoIcons.person_3, 'label': 'Bloom Buddy'},
    {'id': 'Persona10', 'icon': CupertinoIcons.person_crop_circle_badge_checkmark, 'label': 'Leaf Legend'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
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
                  'Choose Avatar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(_selectedAvatar),
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
          
          const SizedBox(height: 16),
          
          // Avatar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = _selectedAvatar == avatar['id'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatar = avatar['id'] as String;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? CupertinoColors.systemBlue.withValues(alpha: 0.1)
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? CupertinoColors.systemBlue
                              : CupertinoColors.systemGrey4,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            avatar['icon'] as IconData,
                            size: 30,
                            color: isSelected 
                                ? CupertinoColors.systemBlue
                                : CupertinoColors.secondaryLabel,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avatar['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected 
                                  ? CupertinoColors.systemBlue
                                  : CupertinoColors.secondaryLabel,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
