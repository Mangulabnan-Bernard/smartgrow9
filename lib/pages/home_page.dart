import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../services/theme_service.dart';
import '../pages/dashboard_page.dart';
import '../pages/monitoring_page.dart';
import '../pages/history_page.dart';
import '../pages/profile_page.dart';
import '../pages/analytics_page.dart';
import '../pages/camera_with_tabs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // Static variable to control tab switching after navigation
  static int? pendingTabIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CupertinoTabController _tabController = CupertinoTabController();

  @override
  void initState() {
    super.initState();
    _applySystemUIOverlay();
    
    // Check if we need to switch to a specific tab
    if (HomePage.pendingTabIndex != null) {
      _tabController.index = HomePage.pendingTabIndex!;
      HomePage.pendingTabIndex = null; // Reset after use
    }
  }

  void _applySystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0x00000000),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: CupertinoColors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return DashboardPage(
          onScanNow: () => _navigateToScan(),
          onViewHistory: () => _tabController.index = 3,
          onOpenAnalytics: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const AnalyticsPage()),
            );
          },
        );
      case 1:
        return MonitoringPage(onStartScan: () => _navigateToScan());
      case 2:
        // Camera Tab - Always redirect to home
        Future.delayed(Duration.zero, () {
          if (_tabController.index == 2) {
            _tabController.index = 0; // Go to home tab
          }
        });
        return const SizedBox.shrink(); // Empty content
      case 3:
        return HistoryPage();
      case 4:
        return ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  // UPDATED: Larger icons and text for better visibility
  Widget _buildTabItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 3),
        Icon(icon, size: 28), // Increased from 22
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, // Increased from 10
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the bottom padding (for the home indicator "pill")
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: ThemeService(),
      builder: (context, _) {
        return Container(
          color: CupertinoColors.white,
          child: CupertinoTabScaffold(
            controller: _tabController,
            backgroundColor: CupertinoColors.white,
            tabBar: CupertinoTabBar(
              backgroundColor: CupertinoColors.white.withOpacity(0.96),
              activeColor: ThemeService().currentColor,
              inactiveColor: CupertinoColors.systemGrey,
              // Responsive height: adjusts if there is a bottom notch or not
              height: bottomInset > 0 ? 65 : 75,
              onTap: (index) {
                if (index == 2) {
                  HapticFeedback.mediumImpact(); // Adds a professional vibration
                  _navigateToScan(); // Navigate to camera analysis
                }
                // Other tabs work normally
              },
              items: [
                BottomNavigationBarItem(
                  icon: _buildTabItem(CupertinoIcons.house_fill, 'Home'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildTabItem(CupertinoIcons.leaf_arrow_circlepath, 'Track'),
                  label: '',
                ),

                // Integrated Camera Button
                BottomNavigationBarItem(
                  icon: Container(
                    margin: const EdgeInsets.only(top: 1),
                    padding: const EdgeInsets.all(8), // Increased from 8 by 2px
                    decoration: BoxDecoration(
                      color: ThemeService().currentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ThemeService().currentColorWithAlpha(0.3),
                          blurRadius: 11,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      color: CupertinoColors.white,
                      size: 28,
                    ),
                  ),
                  label: '',
                ),

                BottomNavigationBarItem(
                  icon: _buildTabItem(CupertinoIcons.clock_fill, 'History'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildTabItem(CupertinoIcons.person_fill, 'Profile'),
                  label: '',
                ),
              ],
            ),
            tabBuilder: (BuildContext context, int index) {
              return _buildTabContent(index);
            },
          ),
        );
      },
    );
  }

  void _navigateToScan() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const CameraWithTabsPage(),
      ),
    );
  }
}