import 'package:flutter/cupertino.dart';

class PlantCompatibilityPage extends StatefulWidget {
  const PlantCompatibilityPage({super.key});

  @override
  State<PlantCompatibilityPage> createState() => _PlantCompatibilityPageState();
}

class _PlantCompatibilityPageState extends State<PlantCompatibilityPage> {
  final List<Map<String, dynamic>> _plants = [
    {
      'name': 'Tomato',
      'icon': CupertinoIcons.tree,
      'color': CupertinoColors.systemRed,
      'description': 'Versatile fruiting plant, needs full sun and support',
      'companions': ['Basil', 'Marigold', 'Lettuce', 'Onion'],
      'avoid': ['Fennel', 'Corn', 'Walnut'],
      'tips': [
        'Plant after last frost in rich, well-draining soil',
        'Provide sturdy cages or stakes for support',
        'Water consistently, avoid wetting leaves',
        'Fertilize every 2-3 weeks during growing season'
      ]
    },
    {
      'name': 'Garlic',
      'icon': CupertinoIcons.tree,
      'color': CupertinoColors.systemGrey,
      'description': 'Hardy bulb plant, natural pest repellent',
      'companions': ['Tomato', 'Fruit Trees', 'Roses', 'Cabbage'],
      'avoid': ['Beans', 'Peas', 'Asparagus'],
      'tips': [
        'Plant in fall for early summer harvest',
        'Choose largest cloves for best results',
        'Mulch heavily in cold climates',
        'Stop watering when tops begin to fall'
      ]
    },
    {
      'name': 'Red Onion',
      'icon': CupertinoIcons.tree,
      'color': CupertinoColors.systemPurple,
      'description': 'Cool-season crop, stores well long-term',
      'companions': ['Carrots', 'Lettuce', 'Tomato', 'Cabbage'],
      'avoid': ['Beans', 'Peas', 'Asparagus', 'Sage'],
      'tips': [
        'Plant sets or transplants in early spring',
        'Keep well-weeded, onions compete poorly',
        'Thin to 4-6 inches apart for proper development',
        'Harvest when tops fall over naturally'
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Plants Grid
              _buildPlantsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plant Compatibility Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn which plants grow well together and which to keep apart',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantsGrid() {
    return Column(
      children: _plants.map((plant) => _buildPlantCard(plant)).toList(),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey4,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        onPressed: () => _showPlantDetails(plant),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: plant['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      plant['icon'],
                      color: plant['color'],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.label,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plant['description'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: CupertinoColors.tertiaryLabel,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Quick Info
              Row(
                children: [
                  Expanded(
                    child: _buildQuickInfo(
                      'Good Neighbors',
                      plant['companions'].take(3).join(', '),
                      CupertinoColors.systemGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickInfo(
                      'Avoid',
                      plant['avoid'].take(2).join(', '),
                      CupertinoColors.systemRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.label,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showPlantDetails(Map<String, dynamic> plant) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _buildPlantDetailSheet(plant),
    );
  }

  Widget _buildPlantDetailSheet(Map<String, dynamic> plant) {
    return Container(
      height: 600,
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
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: plant['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        plant['icon'],
                        color: plant['color'],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      plant['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.xmark,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 1),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    plant['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.label,
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Companions
                  _buildCompatibilitySection(
                    'Good Companions',
                    plant['companions'],
                    CupertinoColors.systemGreen,
                    CupertinoIcons.checkmark_circle_fill,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Avoid
                  _buildCompatibilitySection(
                    'Plants to Avoid',
                    plant['avoid'],
                    CupertinoColors.systemRed,
                    CupertinoIcons.xmark_circle_fill,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Growing Tips
                  _buildTipsSection(plant['tips']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection(String title, List<dynamic> plants, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: plants.map<Widget>((plant) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              plant,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildTipsSection(List<String> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              CupertinoIcons.lightbulb,
              color: CupertinoColors.systemOrange,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Growing Tips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.asMap().entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.label,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
