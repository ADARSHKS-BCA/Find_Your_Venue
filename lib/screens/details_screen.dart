import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/venue_data.dart';
import '../models/venue.dart';

//// This is the file which shows the image and the details of the 
//venue detatils  layout of it 
class DetailsScreen extends StatelessWidget {
  final String id;
  const DetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final venue = venueList.firstWhere(
      (v) => v.id == id,
      orElse: () => venueList[0], // Fallback
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Slightly off-white background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300, // Dominant hero image
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF264796),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF264796)),
                onPressed: () => context.canPop() ? context.pop() : context.go('/search'),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 1.5,
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: Text(
                venue.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Base size, scales up
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Hero(
                    tag: 'venue_${venue.id}',
                    child: Image.network(
                      venue.destinationUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  // Gradient overlay for text readability
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  // Directions Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions, color: Color(0xFF264796), size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Directions',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C3E50),
                                    letterSpacing: -0.5,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ...venue.instructions.asMap().entries.map((entry) {
                           final index = entry.key;
                           final step = entry.value;
                           return Padding(
                             padding: const EdgeInsets.only(bottom: 20.0),
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Container(
                                   width: 24,
                                   height: 24,
                                   alignment: Alignment.center,
                                   decoration: BoxDecoration(
                                     color: const Color(0xFFF0F4FF),
                                     shape: BoxShape.circle,
                                     border: Border.all(color: const Color(0xFF264796).withOpacity(0.2)),
                                   ),
                                   child: Text(
                                     '${index + 1}',
                                     style: const TextStyle(
                                       color: Color(0xFF264796),
                                       fontWeight: FontWeight.bold,
                                       fontSize: 12,
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 Expanded(
                                   child: Text(
                                     step,
                                     style: TextStyle(
                                       fontSize: 16,
                                       height: 1.6,
                                       color: Colors.grey[800],
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                 ),
                               ],
                             ),
                           );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    venue.destinationUrl,
                                    fit: BoxFit.contain,
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () => context.pop(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF264796),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: const Color(0xFF264796).withOpacity(0.1), width: 1),
                      ),
                      icon: const Icon(Icons.fullscreen),
                      label: const Text(
                        'View Destination Image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                  ),
                  const SizedBox(height: 48), // Bottom safe spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
