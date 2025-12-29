import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';
import '../widgets/venue_card.dart';
import '../utils/preferences_service.dart';
import 'first_time_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<String> _recentIds = []; // Removed in favor of ValueNotifier
  bool _isLoading = true;
  bool _showHelper = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHelper = prefs.getBool('has_seen_helper') ?? false;

    if (!hasSeenHelper) {
      setState(() {
        _showHelper = true;
        _isLoading = false;
      });
    } else {
      _loadRecents(prefs);
    }
  }

  Future<void> _dismissHelper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_helper', true);
    setState(() {
      _showHelper = false;
    });
    _loadRecents(prefs);
  }

  Future<void> _loadRecents([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final recents = p.getStringList('recent_venues_v2') ?? [];
    recentVenuesNotifier.value = recents;
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Helper to refresh recents specifically (used by pull-to-refresh or return from other screens)
  Future<void> _refreshRecents() async {
    // Only fetch if necessary or simple sync
    final prefs = await SharedPreferences.getInstance();
    recentVenuesNotifier.value = prefs.getStringList('recent_venues_v2') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.white);
    }

    if (_showHelper) {
      return FirstTimeHelper(onDismiss: _dismissHelper);
    }

    // Resolve recent venues
    // Recent venues resolution moved to ValueListenableBuilder

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0), // Optical alignment
          child: Text(
            'CampusPath',
             style: theme.textTheme.headlineSmall?.copyWith(
               fontWeight: FontWeight.bold,
               color: theme.colorScheme.primary,
               letterSpacing: -0.5,
             ),
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leadingWidth: 140,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 16.0),
          child: SizedBox(
            height: 56,
            child: Image.asset(
               'assets/images/college_header.webp',
               fit: BoxFit.contain,
               alignment: Alignment.centerLeft,
               errorBuilder: (context, error, stackTrace) {
                 return Icon(Icons.school, size: 32, color: theme.colorScheme.primary);
               },
            ),
          ),
        ),
        actions: [
           ValueListenableBuilder<ThemeMode>(
             valueListenable: PreferencesService.themeNotifier,
             builder: (context, mode, child) {
               final isDarkMode = mode == ThemeMode.dark || (mode == ThemeMode.system && isDark);
               return IconButton(
                 icon: Icon(
                   isDarkMode ? Icons.light_mode : Icons.dark_mode,
                   color: theme.colorScheme.primary,
                 ),
                 onPressed: PreferencesService.toggleTheme,
               );
             },
           ),
           const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 10), // Spacing replacement
              
              // 1.5 Resume Navigation Banner
              ValueListenableBuilder<String?>(
                valueListenable: PreferencesService.lastNavigatedVenueNotifier,
                builder: (context, lastId, child) {
                  if (lastId == null) return const SizedBox.shrink();

                  // Find venue name if possible, or just generic
                  final venue = venueList.firstWhere(
                    (v) => v.id == lastId, 
                    orElse: () => const Venue(id: '0', name: 'your destination', blockName: '', imageUrl: '', destinationUrl: '', instructions: [])
                  );
                  
                  if (venue.id == '0') return const SizedBox.shrink(); // Invalid ID

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Material(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => context.push('/venue/$lastId'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           child: Row(
                             children: [
                               Icon(Icons.navigation, color: theme.colorScheme.onPrimaryContainer),
                               const SizedBox(width: 12),
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'Continue navigation',
                                       style: theme.textTheme.labelSmall?.copyWith(
                                         color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                                       ),
                                     ),
                                     Text(
                                       'To ${venue.name}',
                                       style: theme.textTheme.bodyMedium?.copyWith(
                                         fontWeight: FontWeight.bold,
                                         color: theme.colorScheme.onPrimaryContainer,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                   ],
                                 ),
                               ),
                               IconButton(
                                 icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onPrimaryContainer),
                                 onPressed: PreferencesService.clearLastNavigatedVenue,
                               )
                             ],
                           ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 2. Prominent Search Bar
              GestureDetector(
                onTap: () async {
                  await context.push('/search');
                  _loadRecents(); // Refresh on return
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search by venue, office, or hall',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Quick Access
              Text(
                'Quick Access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // color: Color(0xFF2C3E50), // Use theme color
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _QuickAccessItem(
                    icon: Icons.school,
                    label: 'Academic',
                    onTap: () async {
                      await context.push('/search?filter=Academic');
                      _loadRecents();
                    },
                  ),
                   _QuickAccessItem(
                    icon: Icons.business,
                    label: 'Admin',
                    onTap: () async {
                      await context.push('/search?filter=Administrative');
                      _loadRecents();
                    },
                  ),
                  _QuickAccessItem(
                    icon: Icons.event,
                    label: 'Events',
                    onTap: () async {
                      await context.push('/search?filter=Events');
                      _loadRecents();
                    },
                  ),
                  _QuickAccessItem(
                    icon: Icons.bed,
                    label: 'Hostels',
                    onTap: () async {
                      await context.push('/search?filter=Hostels');
                      _loadRecents();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              // 4. Recent Venues (Conditional)
              // 4. Recent Venues (Conditional)
              ValueListenableBuilder<List<String>>(
                valueListenable: recentVenuesNotifier,
                builder: (context, recentIds, child) {
                  if (venueList.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  
                  // Empty State for Recents
                  if (recentIds.isEmpty) {
                     return Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Recent',
                           style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(height: 12),
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.all(24),
                           decoration: BoxDecoration(
                             color: theme.cardTheme.color?.withOpacity(0.5),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
                           ),
                           child: Column(
                             children: [
                               Icon(Icons.history, color: theme.disabledColor, size: 32),
                               const SizedBox(height: 8),
                               Text(
                                 'Venues you visit will appear here',
                                 style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(height: 32),
                       ],
                     );
                  }

                  final recentVenues = recentIds
                      .toSet()
                      .toList()
                      .map((id) => venueList.firstWhere((v) => v.id == id,
                          orElse: () => Venue(
                                id: '0',
                                name: 'Unknown',
                                blockName: '',
                                imageUrl: '',
                                destinationUrl: '',
                                instructions: [],
                              )))
                      .where((v) => v.id != '0')
                      .take(4)
                      .toList();

                  if (recentVenues.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent',
                        style: theme.textTheme.titleMedium?.copyWith(
                           fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentVenues.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final venue = recentVenues[index];
                            // Minimal Card for Recents
                            return GestureDetector(
                              onTap: () async {
                                 await context.push('/venue/${venue.id}');
                                 _loadRecents();
                              }, 
                              child: Container(
                                width: 180,
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
                                  boxShadow: [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                                       blurRadius: 8,
                                       offset: const Offset(0, 2),
                                     ),
                                  ], 
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.asset(
                                        venue.imageUrl,
                                        height: 80,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        cacheHeight: 160,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 80, 
                                          color: Colors.grey[200],
                                          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        venue.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
              
              // 5. Explore the Campus
              Text(
                'Explore the Campus',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () async {
                    await context.push('/explore_blocks');
                    _loadRecents();
                  },
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/Campus.webp',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        cacheHeight: 400,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                             height: 200,
                             color: Colors.grey[200],
                             child: const Center(child: Text('Campus Image Mockup')),
                           );
                        },
                      ),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 16,
                        left: 16,
                        child: Text(
                          'View All Blocks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    ),
   );
  }
}

class _QuickAccessItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? theme.cardTheme.color : const Color(0xFFF5F7FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF264796), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? theme.colorScheme.onSurface : const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
