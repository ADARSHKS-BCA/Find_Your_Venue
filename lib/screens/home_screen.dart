import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';
import '../widgets/venue_card.dart'; // Reuse VenueCard for recents if suitable, or create a smaller one

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _recentIds = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentIds = prefs.getStringList('recent_venues_v2') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Resolve recent venues
    // Resolve recent venues
    final List<Venue> recentVenues = _recentIds
        .toSet() // Deduplicate IDs immediately
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
        .take(4) // Ensure display limit as well
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // 1. Branding (Left Aligned)
                   Padding(
                     padding: const EdgeInsets.only(top: 10, bottom: 0),
                     child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start, // Left aligned
                      children: [
                         Image.asset(
                          'assets/images/college_header.png',
                          height: 56,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.school, size: 48, color: Color(0xFF264796));
                          },
                         ),
                         const SizedBox(width: 16),
                         const Text(
                           'Venue Finder',
                           style: TextStyle(
                             fontSize: 22,
                             fontWeight: FontWeight.bold,
                             color: Color(0xFF264796),
                             letterSpacing: -0.5,
                           ),
                         ),
                      ],
                     ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
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
              if (recentVenues.isNotEmpty) ...[
                const Text(
                  'Recent',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                            boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.05),
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
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
              
              // 5. Explore the Campus
              const Text(
                'Explore the Campus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
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
                        'assets/images/Campus.png',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
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
    return Material(
      color: const Color(0xFFF5F7FA),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
