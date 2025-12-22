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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              // Always go back to search or home
              onPressed: () => context.canPop() ? context.pop() : context.go('/search'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                venue.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: Image.network(
                venue.destinationUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300], child: const Icon(Icons.image_not_supported));
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.blockName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Directions Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Directions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF264796),
                                ),
                          ),
                          const SizedBox(height: 16),
                          ...venue.instructions.map((step) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.circle, size: 8, color: Color(0xFF264796)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: const TextStyle(fontSize: 16, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
