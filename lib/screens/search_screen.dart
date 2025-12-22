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
  final List<String> _filters = ['All', 'Main Block', 'Audi Block ', 'Block 2 ', 'Hostels'];

  @override
  Widget build(BuildContext context) {
    // 1. Filter Logic
    List<Venue> filteredVenues = venueList.where((venue) {
      final q = _query.toLowerCase();
      final matchesQuery = venue.name.toLowerCase().contains(q) ||
          venue.blockName.toLowerCase().contains(q);
      
      bool matchesFilter = _selectedFilter == 'All';
      if (!matchesFilter) {
        if (_selectedFilter == 'Hostels') {
          // Special case for Hostels: Match "hall" (KE Hall, Jonas Hall) or "hostel" in name/block
          matchesFilter = venue.blockName.toLowerCase().contains('hall') || 
                          venue.name.toLowerCase().contains('hostel');
        } else {
          matchesFilter = venue.blockName.contains(_selectedFilter.trim());
        }
      }
      
      return matchesQuery && matchesFilter;
    }).toList();

    // 2. Empty/Suggestion State
    // 2. Empty/Suggestion State
    final bool isSearching = _query.isNotEmpty;
    // Removed logic to limit to 3 suggestions when 'All' is selected. 
    // Now shows all venues by default.

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header & Search Area
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                     children: [
                       IconButton(
                         icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3E50)),
                         onPressed: () => context.go('/'),
                         padding: EdgeInsets.zero,
                         constraints: const BoxConstraints(),
                         splashRadius: 24,
                       ),
                       const SizedBox(width: 16),
                       const Text(
                         'Find a Venue',
                         style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: Color(0xFF264796),
                           letterSpacing: -0.5,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 24),
                   // Search Field
                   TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Search by venue name, block...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
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
                           child: ActionChip(
                             label: Text(filter),
                             labelStyle: TextStyle(
                               color: isSelected ? Colors.white : Colors.grey[700],
                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                               fontSize: 13,
                             ),
                             backgroundColor: isSelected ? const Color(0xFF264796) : Colors.white,
                             side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.withOpacity(0.3)),
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                             onPressed: () {
                               setState(() => _selectedFilter = filter);
                             },
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
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 48),
                      itemCount: filteredVenues.length,
                      itemBuilder: (context, index) {
                        // Section Header for Suggestions
                        return VenueCard(venue: filteredVenues[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
