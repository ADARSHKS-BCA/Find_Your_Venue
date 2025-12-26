import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';
import 'navigation_screen.dart'; // Navigation Mode Widget (Phase 4)

class DetailsScreen extends StatefulWidget {
  final String id;
  const DetailsScreen({super.key, required this.id});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Venue venue;

  @override
  void initState() {
    super.initState();
    venue = venueList.firstWhere(
      (v) => v.id == widget.id,
      orElse: () => venueList[0],
    );
    _addToRecents();
  }

  Future<void> _addToRecents() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recents = prefs.getStringList('recent_venues_v2') ?? [];
    
    // Remove if already exists (remove ALL occurrences to be safe and clean)
    recents.removeWhere((item) => item == widget.id);
    
    // Add to top (start of list)
    recents.insert(0, widget.id);
    
    // Strict limit to 4 recent items
    if (recents.length > 4) {
      recents = recents.sublist(0, 4);
    }
    
    await prefs.setStringList('recent_venues_v2', recents);
  }

  @override
  Widget build(BuildContext context) {
    // derived properties
    // "Estimated walk time" -> Static 5 min for now
    // "Accessibility" -> check instructions
    final isAccessible = venue.instructions.any((i) => i.toLowerCase().contains('elevator') || i.toLowerCase().contains('ground'));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Reduced Header
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.35, // Max 35-40%
                pinned: true,
                backgroundColor: const Color(0xFF264796),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF264796)),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/search'),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'venue_thumb_${venue.id}', // Matching List tag
                        child: Image.network( // Or Image.asset depending on data
                          venue.destinationUrl.startsWith('http') ? venue.destinationUrl : venue.imageUrl, 
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          errorBuilder: (_, __, ___) => Image.asset(
                            venue.imageUrl, 
                            fit: BoxFit.cover, 
                            cacheWidth: 800,
                            errorBuilder: (_,__,___) => Container(color: Colors.grey[300])
                          ),
                        ), // Fallback logic handled in logic or data usually
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Block
                      Text(
                        venue.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 4),
                          Text(
                            venue.blockName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem(Icons.directions_walk, '5-8 min', 'Walk'),
                            _buildInfoDivider(),
                            _buildSummaryItem(Icons.layers, 'Floor 1', 'Level'), // Hardcoded floor for now or need logic
                            _buildInfoDivider(),
                            _buildSummaryItem(
                              isAccessible ? Icons.accessible : Icons.not_accessible, 
                              isAccessible ? 'Yes' : 'Stairs', 
                              'Access'
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Description / Instructions Preview (Brief)
                      Text(
                        'Directions Preview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Detailed step-by-step navigation is available in walking mode.',
                        style: TextStyle(color: Colors.grey[600], height: 1.5),
                      ),
                      const SizedBox(height: 100), // Space for CTA
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Floating CTA
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(builder: (_) => NavigationScreen(venue: venue)),
                   );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF264796),
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.navigation),
                label: const Text(
                  'Start Walking Directions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF264796), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey[300],
    );
  }
}
