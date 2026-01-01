import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';
import '../widgets/venue_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  String _selectedFilter = 'All';
  bool _initialized = false;
  
  final List<String> _filters = [
    'All', 
    'Academic', 
    'Administrative', 
    'Events', 
    'Hostels', 
    'Sports', 
    'Services'
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Initialize filter from URL if needed
    if (!_initialized) {
      final state = GoRouterState.of(context); // Safe to call in build
      final paramFilter = state.uri.queryParameters['filter'];
      if (paramFilter != null && _filters.contains(paramFilter)) {
        _selectedFilter = paramFilter;
      }
      _initialized = true;
    }

    // 2. Filter Logic
    List<Venue> filteredVenues = venueList.where((venue) {
      final q = _query.toLowerCase();
      final category = _getCategory(venue);
      
      final matchesQuery = venue.name.toLowerCase().contains(q) ||
          venue.blockName.toLowerCase().contains(q) ||
          category.toLowerCase().contains(q);
      
      bool matchesFilter = _selectedFilter == 'All';
      if (!matchesFilter) {
        matchesFilter = category == _selectedFilter;
      }
      
      return matchesQuery && matchesFilter;
    }).toList();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
          children: [
            // Custom Header & Search Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: theme.scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       IconButton(
                         icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
                         onPressed: () => context.go('/'),
                         padding: EdgeInsets.zero,
                         constraints: const BoxConstraints(),
                         splashRadius: 24,
                       ),
                       const SizedBox(width: 16),
                       Text(
                         'Find a Venue',
                         style: theme.textTheme.headlineSmall?.copyWith(
                           fontWeight: FontWeight.bold,
                           color: theme.colorScheme.primary,
                           letterSpacing: -0.5,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   // Search Field
                   TextField(
                      autofocus: _selectedFilter == 'All' && !_initialized, // Auto focus if coming from Search tab but not if filter preset
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search by venue name, block...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        filled: true,
                        fillColor: isDark ? theme.cardTheme.color : const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                   ),
                   const SizedBox(height: 20),
                   // Filter Chips
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: _filters.map((filter) {
                         final isSelected = _selectedFilter == filter;
                         return Padding(
                           padding: const EdgeInsets.only(right: 8.0),
                           child: FilterChip(
                             label: Text(filter),
                             selected: isSelected,
                             onSelected: (bool selected) {
                               setState(() {
                                 _selectedFilter = filter;
                               });
                             },
                             selectedColor: theme.colorScheme.primary,
                             checkmarkColor: theme.colorScheme.onPrimary,
                             labelStyle: TextStyle(
                               color: isSelected ? theme.colorScheme.onPrimary : (isDark ? Colors.grey[300] : Colors.grey[700]),
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                               fontSize: 13,
                              ),
                             backgroundColor: isDark ? theme.cardTheme.color : Colors.white,
                             side: isSelected ? BorderSide.none : BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey.withOpacity(0.3)),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                             showCheckmark: false,
                           ),
                         );
                       }).toList(),
                     ),
                   ),
                ],
              ),
            ),
            
            // List Content
            Expanded(
              child: filteredVenues.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No venues found',
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                      itemCount: filteredVenues.length,
                      itemBuilder: (context, index) {
                        final venue = filteredVenues[index];
                        return VenueCard(
                          venue: venue,
                          category: _getCategory(venue), // Pass consistent category
                        );
                      },
                    ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  // Helper to categorize venues (Must match VenueCard logic or be the source of truth)
  String _getCategory(Venue venue) {
    final n = venue.name.toLowerCase();
    final b = venue.blockName.toLowerCase();
    
    if (n.contains('sports') || n.contains('gym') || n.contains('ground') || b.contains('sport')) return 'Sports';
    if (n.contains('hostel') || (n.contains('hall') && b.contains('hall') && !n.contains('seminar'))) return 'Hostels';
    if (n.contains('office') || n.contains('admin') || n.contains('dean')) return 'Administrative';
    if (n.contains('audi') || n.contains('seminar') || n.contains('event')) return 'Events';
    if (n.contains('lab') || n.contains('class') || n.contains('center') || b.contains('main') || b.contains('block')) return 'Academic';
    
    return 'Services';
  }
}
