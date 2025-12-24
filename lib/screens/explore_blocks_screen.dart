import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animated_title.dart';

class ExploreBlocksScreen extends StatefulWidget {
  const ExploreBlocksScreen({super.key});

  @override
  State<ExploreBlocksScreen> createState() => _ExploreBlocksScreenState();
}

class _ExploreBlocksScreenState extends State<ExploreBlocksScreen> with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> blocks = const [
    {
      'title': 'Central Block',
      'image': 'assets/images/Campus.png', 
      'route': '/search?query=Central Block',
    },
    {
      'title': 'Block 1',
      'image': 'assets/images/BlockOne.png',
      'route': '/search?query=Block 1',
    },
    {
      'title': 'Block 2',
      'image': 'assets/images/BlockTwo.png',
      'route': '/search?query=Block 2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Slightly longer for the list stagger
    );
    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF264796)),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: AnimatedTitle(text: 'EXPLORE BLOCKS'),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 32, right: 32, top: 20, bottom: 48), // Generous padding with bottom safe space
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final animation = CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(
                          (index * 0.15).clamp(0.0, 1.0), // More spacing in staggering
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: animation.value,
                            child: Transform.translate(
                              offset: Offset(0, 40 * (1 - animation.value)), // More travel distance
                              child: child,
                            ),
                          );
                        },
                        child:Padding(
                          padding: const EdgeInsets.only(bottom: 24.0), // Spacing between cards
                          child: _BlockCard(
                            title: blocks[index]['title']!,
                            imageUrl: blocks[index]['image']!,
                            onTap: () {
                              context.push(Uri(
                                path: '/block_detail',
                                queryParameters: {
                                  'name': blocks[index]['title']!,
                                  'imageUrl': blocks[index]['image']!,
                                },
                              ).toString());
                            },
                          ),
                        )
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
}

class _BlockCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _BlockCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_BlockCard> createState() => _BlockCardState();
}

class _BlockCardState extends State<_BlockCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Tap Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
       CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }
  
  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          // Match VenueCard style
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              AspectRatio( // Aspect ratio similar to venue card or fixed height
                aspectRatio: 16 / 9,
                child: widget.imageUrl.startsWith('http')
                  ? Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                    )
                  : Image.asset(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image)),
                    ),
              ),
              
              // Text Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} // End of _BlockCard



