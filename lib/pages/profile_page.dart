import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_stats.dart';
import '../models/scan_result.dart';
import '../services/storage_service.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import 'archive_page.dart';

// Brand Colors
const Color kSoftBackground = Color(0xFFF8FAFC);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserStats? _userStats;
  bool _isLoading = true;
  int _totalScans = 0;
  List<ScanResult> _archivedScans = [];
  List<MonitoringSession> _archivedSessions = [];
  String currentTheme = 'green';

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    _loadThemePreference();

    // Attach listeners for real-time updates across the app
    StorageService.monitoringUpdated.addListener(_onStorageUpdate);
    StorageService.scansUpdated.addListener(_onStorageUpdate);
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('app_theme') ?? 'green';
    if (mounted) {
      setState(() {
        currentTheme = savedTheme;
      });
    }
  }

  @override
  void dispose() {
    // Prevent memory leaks by removing listeners when page is destroyed
    StorageService.monitoringUpdated.removeListener(_onStorageUpdate);
    StorageService.scansUpdated.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    print('Profile Debug: Storage update triggered - checking if mounted...');
    print('Profile Debug: mounted = $mounted');
    if (mounted) {
      print('Profile Debug: Calling _loadUserStats()...');
      _loadUserStats();
    } else {
      print('Profile Debug: Widget not mounted, skipping refresh');
    }
  }

  Future<void> _loadUserStats() async {
    print('Profile Debug: Starting _loadUserStats()...');
    try {
      final stats = await StorageService.getUserStats();
      final scans = await StorageService.getScans();
      final sessions = await StorageService.getMonitoring();

      // Calculate active (non-archived) counts to match dashboard logic
      final activeScans = scans.where((s) => !s.archived).toList();
      final activeSessions = sessions.where((s) => s.status != SessionStatus.archived).toList();
      
      // Debug logging
      final totalScans = scans.length;
      final archivedScans = scans.where((s) => s.archived).length;
      final totalSessions = sessions.length;
      final activeSessionsCount = activeSessions.length;

      print('Profile Debug:');
      print('- Total scans: $totalScans (archived: $archivedScans)');
      print('- Total sessions: $totalSessions');
      print('- Active sessions: $activeSessionsCount');
      print('- Calculated _totalScans: ${activeScans.length + activeSessionsCount}');

      if (mounted) {
        print('Profile Debug: Calling setState...');
        setState(() {
          _userStats = stats;
          _totalScans = activeScans.length + activeSessions.length; // Only count active items
          _archivedScans = scans.where((s) => s.archived).toList();
          _archivedSessions = sessions.where((s) => s.status == SessionStatus.archived).toList();
          _isLoading = false;
          currentTheme = stats.themeColor ?? 'green';
        });
        print('Profile Debug: setState completed successfully');
        print('Profile Debug: _totalScans is now: $_totalScans');
      }
    } catch (e) {
      print('Profile Debug: Load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLanguageSelector() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Language / Pumili ng Wika'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              LanguageService.setLanguage('en');
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              LanguageService.setLanguage('tl');
              Navigator.pop(context);
            },
            child: const Text('Tagalog'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showArchiveDetails() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const ArchivePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: kSoftBackground,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: 100.0, // Add bottom padding to avoid tab bar overlap
              ),
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 32),
                  _buildThemeSection(),
                  const SizedBox(height: 16),
                  _buildLanguageSection(),
                  const SizedBox(height: 16),
                  _buildArchiveSection(),
                  const SizedBox(height: 16),
                  _buildGuideSection(),
                  const SizedBox(height: 24),
                  _buildAboutSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    if (_userStats == null) return const SizedBox.shrink();
    double xpProgress = (_userStats!.xp / (_userStats!.level * 1000));

    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userStats!.username.isNotEmpty ? _userStats!.username : 'Smart Grower',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Level ${_userStats!.level}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: ThemeService().currentColorWithAlpha(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('LEVEL ${_userStats!.level}',
                                  style: TextStyle(color: ThemeService().currentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildAvatar(),
                ],
              ),
              const SizedBox(height: 24),
              _buildProgressBar(xpProgress),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildMiniStat('Checks Done', '$_totalScans'),
                  const SizedBox(width: 12),
                  _buildMiniStat('Plants Cured', '${_userStats!.sessionsCount}'),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(double progress) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Growth', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel)),
                Text('${_userStats!.xp} XP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(10)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: ThemeService().currentColor, borderRadius: BorderRadius.circular(10))),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ThemeService().currentColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: ThemeService().currentColorWithAlpha(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: const Icon(CupertinoIcons.person_fill, color: CupertinoColors.white, size: 40),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: CupertinoColors.systemGrey6.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: CupertinoColors.secondaryLabel)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, lang, _) {
        return AnimatedBuilder(
          animation: ThemeService(),
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: ThemeService().currentColorWithAlpha(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Icon(CupertinoIcons.paintbrush_fill, color: ThemeService().currentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CupertinoColors.black)),
                            Text('Choose your app theme color', style: const TextStyle(fontSize: 11, color: CupertinoColors.secondaryLabel)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Theme color circles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeColorCircle('green', ThemeService().getThemeColor('green')!),
                      _buildThemeColorCircle('blue', ThemeService().getThemeColor('blue')!),
                      _buildThemeColorCircle('red', ThemeService().getThemeColor('red')!),
                      _buildThemeColorCircle('orange', ThemeService().getThemeColor('orange')!),
                      _buildThemeColorCircle('purple', ThemeService().getThemeColor('purple')!),
                      _buildThemeColorCircle('pink', ThemeService().getThemeColor('pink')!),
                      _buildThemeColorCircle('teal', ThemeService().getThemeColor('teal')!),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeColorCircle(String themeName, Color color) {
    bool isSelected = ThemeService().currentTheme == themeName;
    return GestureDetector(
      onTap: () => _changeTheme(themeName),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? CupertinoColors.black : CupertinoColors.systemGrey4,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(
                CupertinoIcons.checkmark,
                color: CupertinoColors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  void _changeTheme(String themeName) async {
    await ThemeService().changeTheme(themeName);
    
    // Update user stats with theme
    if (_userStats != null) {
      final updatedStats = UserStats(
        xp: _userStats!.xp,
        level: _userStats!.level,
        scansCount: _userStats!.scansCount,
        sessionsCount: _userStats!.sessionsCount,
        username: _userStats!.username,
        profileIcon: _userStats!.profileIcon,
        themeColor: themeName,
      );
      await StorageService.saveUserStats(updatedStats);
      _userStats = updatedStats;
    }
  }

  Widget _buildLanguageSection() {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, lang, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(20)),
          child: _buildActionRow(
            icon: CupertinoIcons.globe,
            title: lang == 'tl' ? 'Wika' : 'Language',
            subtitle: lang == 'tl' ? 'Pumili ng wika' : 'Choose language',
            actionText: lang == 'en' ? 'English' : 'Tagalog',
            onTap: _showLanguageSelector,
          ),
        );
      },
    );
  }

  Widget _buildArchiveSection() {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.currentLanguage,
      builder: (context, lang, _) {
        int count = _archivedScans.length + _archivedSessions.length;
        return AnimatedBuilder(
          animation: ThemeService(),
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: count > 0 ? _showArchiveDetails : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: ThemeService().currentColorWithAlpha(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(CupertinoIcons.archivebox, color: ThemeService().currentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Archive', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CupertinoColors.black)),
                          Text(lang == 'tl' ? '$count mga item' : '$count items', style: const TextStyle(fontSize: 11, color: CupertinoColors.black)),
                        ],
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_right, color: count > 0 ? CupertinoColors.systemGrey4 : CupertinoColors.systemGrey3, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionRow({required IconData icon, required String title, required String subtitle, required String actionText, VoidCallback? onTap}) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ThemeService().currentColorWithAlpha(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: ThemeService().currentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: CupertinoColors.secondaryLabel)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: onTap != null ? ThemeService().currentColor : CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(12),
                onPressed: onTap,
                child: Text(actionText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CupertinoColors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildGuideTile(),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _showAboutDialog,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Icon(
                    CupertinoIcons.info_circle_fill,
                    color: ThemeService().currentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About SmartGrow AI',
                        style: TextStyle(
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'App Version 1.0.11',
                        style: const TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: ThemeService().currentColor,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: ThemeService(),
                    builder: (context, _) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeService().currentColorWithAlpha(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        CupertinoIcons.leaf_arrow_circlepath,
                        color: ThemeService().currentColor,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SmartGrow AI',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.black,
                          ),
                        ),
                        Text(
                          'Version 1.0.11',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(CupertinoIcons.xmark, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAboutSectionItem(
                      '🌱 What is SmartGrow AI?',
                      'SmartGrow AI is an intelligent plant health monitoring app that uses advanced artificial intelligence to analyze plant diseases and provide treatment recommendations. Our AI models can identify various plant conditions and help you keep your plants healthy.',
                    ),
                    const SizedBox(height: 20),
                    _buildAboutSectionItem(
                      '🔬 How It Works',
                      'Simply take a photo of your plant, and our AI will analyze it for signs of disease, nutrient deficiencies, or stress. The app provides instant diagnosis and personalized treatment recommendations to help your plants recover.',
                    ),
                    const SizedBox(height: 20),
                    _buildAboutSectionItem(
                      '🌿 Supported Plants',
                      'Currently supports: Tomato, Garlic, Red Onion, and more with Gemini AI integration. We continuously expand our plant database and improve our detection capabilities.',
                    ),
                    const SizedBox(height: 20),
                    _buildAboutSectionItem(
                      '📊 Features',
                      '• Real-time plant disease detection\n• 7-day recovery monitoring\n• Personalized treatment recommendations\n• Progress tracking and analytics\n• Multi-language support (English/Tagalog)',
                    ),
                    const SizedBox(height: 20),
                    _buildAboutSectionItem(
                      '🎯 Our Mission',
                      'To make plant healthcare accessible to everyone through AI technology, helping farmers and gardeners grow healthier plants and increase their harvest yields.',
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Developer Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '© 2024 SmartGrow AI\nPowered by TensorFlow Lite and Gemini AI\nMade with ❤️ for farmers and gardeners',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSectionItem(String title, String content) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeService().currentColorWithAlpha(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeService().currentColorWithAlpha(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeService().currentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideTile() {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: CupertinoColors.systemGrey6, width: 0.5)),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(16),
            onPressed: () => _showGuide(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: ThemeService().currentColorWithAlpha(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(CupertinoIcons.book_fill, color: ThemeService().currentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guide', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CupertinoColors.black)),
                      Text('How to earn XP and level up', style: const TextStyle(fontSize: 11, color: CupertinoColors.black)),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey4, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showGuide() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey4)),
              ),
              child: Row(
                children: [
                  const Text(
                    'XP Guide',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Earn XP',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CupertinoColors.black),
                    ),
                    const SizedBox(height: 12),
                    _buildGuideItem(
                      '📸 Scan Plants',
                      'Earn 25 XP for each plant you scan and analyze.',
                    ),
                    _buildGuideItem(
                      '🔄 Start Monitoring',
                      'Earn 75 XP for each 7-day monitoring session you begin.',
                    ),
                    _buildGuideItem(
                      '✅ Complete 7 Days',
                      'Earn 200 XP bonus for completing a full monitoring session.',
                    ),
                    _buildGuideItem(
                      '🌱 Healthy Plants',
                      'Earn 10 XP extra for each healthy plant identified.',
                    ),
                    _buildGuideItem(
                      '🪴 Plant Variety',
                      'Earn 5 XP per unique plant type you scan.',
                    ),
                    _buildGuideItem(
                      '📅 Daily Activity',
                      'Earn 15 XP per day based on your monitoring activity.',
                    ),
                    _buildGuideItem(
                      '🎯 Consistency',
                      'Earn 50 XP bonus for maintaining 3+ active monitoring sessions.',
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Level Progression',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CupertinoColors.black),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildLevelInfo('Level 1', '0 - 999 XP', '🌱 Beginner'),
                          _buildLevelInfo('Level 2', '1000 - 1999 XP', '🌿 Enthusiast'),
                          _buildLevelInfo('Level 3', '2000 - 2999 XP', '🌳 Expert'),
                          _buildLevelInfo('Level 4', '3000 - 3999 XP', '🌺 Master'),
                          _buildLevelInfo('Level 5+', '4000+ XP', '👑 Legend'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '💡 Regular scanning and monitoring will help you level up faster!',
                      style: TextStyle(fontSize: 12, color: CupertinoColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(String title, String description) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ThemeService().currentColorWithAlpha(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeService().currentColorWithAlpha(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ThemeService().currentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelInfo(String level, String xpRange, String title) {
    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: ThemeService().currentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(xpRange, style: const TextStyle(color: CupertinoColors.secondaryLabel)),
              ),
              Text(title, style: TextStyle(fontSize: 12, color: ThemeService().currentColor)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: CupertinoColors.systemGrey6, width: 0.5)),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () {},
        child: Row(
          children: [
            Icon(icon, color: CupertinoColors.systemGrey2, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: CupertinoColors.secondaryLabel, fontSize: 11)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemGrey4, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _showSignOutConfirmation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(20)),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.power, color: CupertinoColors.destructiveRed, size: 20),
            SizedBox(width: 8),
            Text('Sign Out', style: TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Sign Out'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await AuthService.signOut(); // Sign out user
              // Navigation will be handled by AuthWrapper in main.dart
            },
          ),
        ],
      ),
    );
  }
}