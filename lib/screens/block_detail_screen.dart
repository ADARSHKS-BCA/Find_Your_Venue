import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';
import '../widgets/venue_card.dart';

class BlockDetailScreen extends StatelessWidget {
  final String blockName;
  final String imageUrl;

  const BlockDetailScreen({
    super.key,
    required this.blockName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Data Normalization for Search
    // Map display names to data names if needed (e.g. "Central Block" -> "Main Block")
    String searchName = blockName;
    if (blockName == 'Central Block') searchName = 'Main Block';
    if (blockName == 'Block 1') searchName = 'Block 1'; // Assuming data matches
    if (blockName == 'Block 2') searchName = 'Block 2'; // Assuming data matches

    // 2. Filter Venues inside this block
    final venuesInside = venueList.where((v) {
      return v.blockName.toLowerCase().contains(searchName.toLowerCase());
    }).toList();

    // 3. Categorize Venues
    final academicVenues = venuesInside.where((v) => _isCategory(v, 'Academic')).toList();
    final adminVenues = venuesInside.where((v) => _isCategory(v, 'Administrative')).toList();
    final otherVenues = venuesInside.where((v) => !_isCategory(v, 'Academic') && !_isCategory(v, 'Administrative')).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ---------------------------------------------
          // 1. HEADER CARD (Sliver App Bar)
          // ---------------------------------------------
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF264796),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                blockName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   imageUrl.startsWith('http') 
                      ? Image.network(imageUrl, fit: BoxFit.cover, cacheWidth: 800)
                      : Image.asset(imageUrl, fit: BoxFit.cover, cacheWidth: 800, errorBuilder: (_,__,___) => Container(color: Colors.grey)),
                   Container(color: Colors.black.withOpacity(0.4)),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    
                    // ---------------------------------------------
                    // 2. QUICK FACTS CARD
                    // ---------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardTheme.color : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Facts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildFactItem(context, Icons.layers, '4 Floors'),
                              _buildFactItem(context, Icons.accessible, 'Accessible'),
                              _buildFactItem(context, Icons.wc, 'Washrooms'),
                              _buildFactItem(context, Icons.wifi, 'Campus WiFi'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ---------------------------------------------
                    // 3. WHAT'S INSIDE SECTIONS
                    // ---------------------------------------------
                    Text(
                      'What\'s Inside',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (academicVenues.isNotEmpty) ...[
                      _sectionHeader('Academic'),
                      ...academicVenues.map((v) => VenueCard(venue: v, category: 'Academic')),
                      const SizedBox(height: 16),
                    ],

                    if (adminVenues.isNotEmpty) ...[
                      _sectionHeader('Administrative'),
                      ...adminVenues.map((v) => VenueCard(venue: v, category: 'Administrative')),
                      const SizedBox(height: 16),
                    ],

                    if (otherVenues.isNotEmpty) ...[
                      _sectionHeader('Other Locations'),
                      ...otherVenues.map((v) => VenueCard(venue: v)), // Auto-derive category
                      const SizedBox(height: 16),
                    ],

                    if (venuesInside.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Text(
                          'No specific venues listed for this block yet.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    
                    const SizedBox(height: 32),

                    // ---------------------------------------------
                    // 5. NAVIGATION CTA CARD
                    // ---------------------------------------------
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF264796), Color(0xFF1A3370)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF264796).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Need to get here?',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get directions to $blockName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                               // Navigate to navigation screen directly if we had a Block object, 
                               // but for now we search for the block itself.
                               context.push('/search?query=$searchName');
                            }, 
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactItem(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? theme.canvasColor : const Color(0xFFF5F7FA),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  // Consistent category helper (duplicated logic, should ideally be shared but keeping isolated as per request)
  bool _isCategory(Venue venue, String targetCategory) {
    final n = venue.name.toLowerCase();
    final b = venue.blockName.toLowerCase();
    String category = 'Services';
    if (n.contains('sports') || n.contains('gym') || n.contains('ground') || b.contains('sport')) category = 'Sports';
    else if (n.contains('hostel') || (n.contains('hall') && b.contains('hall') && !n.contains('seminar'))) category = 'Hostels';
    else if (n.contains('office') || n.contains('admin') || n.contains('dean')) category = 'Administrative';
    else if (n.contains('audi') || n.contains('seminar') || n.contains('event')) category = 'Events';
    else if (n.contains('lab') || n.contains('class') || n.contains('center') || b.contains('main') || b.contains('block')) category = 'Academic';
    
    return category == targetCategory;
  }
}
