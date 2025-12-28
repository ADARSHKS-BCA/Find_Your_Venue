import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/venue.dart';
import '../utils/distance_helper.dart';
import '../utils/preferences_service.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final String? category; // Optional override
  final String? walkTime; // Optional override

  const VenueCard({
    super.key,
    required this.venue,
    this.category,
    this.walkTime,
  });

  @override
  Widget build(BuildContext context) {
    // Basic heuristics for display if not passed
    final displayCategory = category ?? _deriveCategory(venue.name, venue.blockName);
    final displayWalkTime = walkTime ?? DistanceHelper.getDistanceLabel(venue);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            PreferencesService.setLastNavigatedVenue(venue.id);
            context.push('/venue/${venue.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thumbnail
                Hero(
                  tag: 'venue_thumb_${venue.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      venue.imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 150, // Memory optimization
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.domain, 
                        color: Colors.grey[400], 
                        size: 32
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 2. Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Type & Block Row
                      Row(
                        children: [
                          _buildTag(displayCategory, Colors.blue[50]!, Colors.blue[700]!),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              venue.blockName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Walk Time & Access Row
                      Row(
                        children: [
                          Icon(Icons.directions_walk, size: 14, color: Colors.orange[400]),
                          const SizedBox(width: 4),
                          Text(
                            displayWalkTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                               fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Accessibility Icon (Conditional or mock)
                          // "Accessibility icon if applicable" -> heuristics: "Ground floor" or random
                          if (venue.instructions.any((i) => i.toLowerCase().contains('ground') || i.toLowerCase().contains('elevator')))
                             Icon(Icons.accessible, size: 14, color: Colors.green[600]),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Chevron/Action
                // Padding(
                //   padding: const EdgeInsets.only(top: 12),
                //   child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[300]),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  String _deriveCategory(String name, String block) {
    final n = name.toLowerCase();
    final b = block.toLowerCase();
    if (n.contains('lab') || n.contains('class') || n.contains('hall') && b.contains('main')) return 'Academic';
    if (n.contains('office') || n.contains('admin')) return 'Administrative';
    if (n.contains('hostel') || n.contains('hall') && b.contains('hall')) return 'Hostels';
    if (n.contains('sports') || n.contains('gym') || n.contains('ground')) return 'Sports';
    if (n.contains('audi') || n.contains('seminar')) return 'Events';
    return 'Services';
  }
}
