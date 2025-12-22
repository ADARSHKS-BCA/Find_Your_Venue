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
      'title': 'MAIN BLOCK',
      'image': 'assets/images/Auditorium.png', 
      'route': '/search?query=Main Block',
    },
    {
      'title': 'AUDI BLOCK',
      'image': 'assets/images/KnowledgeCenter.png',
      'route': '/search?query=Audi Block',
    },
    {
      'title': 'BLOCK 2',
      'image': 'assets/images/MCALab.png',
      'route': '/search?query=Block 2',
    },
    {
      'title': 'SPORTS COMPLEX',
      'image': 'assets/images/SportsComplex.png',
      'route': '/search?query=Sports Complex',
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
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20), // Generous padding
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
                               // Future logic here
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

class _BlockCardState extends State<_BlockCard> with TickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  final GlobalKey _backgroundImageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Hover Animations
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

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
    _hoverController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) {
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onExit(PointerEvent details) {
    setState(() => _isHovered = false);
    _hoverController.reverse();
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
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
            height: 220, // Fixed height for vertical list cards
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Softer corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // Softer shadow
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Parallax Image Background using Flow
                Flow(
                  delegate: _ParallaxFlowDelegate(
                    scrollable: Scrollable.of(context),
                    listItemContext: context,
                    backgroundImageKey: _backgroundImageKey,
                  ),
                  children: [
                    if (widget.imageUrl.startsWith('http'))
                       Image.network(
                         widget.imageUrl,
                         key: _backgroundImageKey,
                         fit: BoxFit.cover,
                         errorBuilder: (context, error, stackTrace) {
                             return Container(color: Colors.grey[300], child: Icon(Icons.broken_image, color: Colors.grey[600]));
                         },
                       )
                    else
                       Image.asset(
                         widget.imageUrl,
                         key: _backgroundImageKey,
                         fit: BoxFit.cover, 
                         errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[300], child: const Icon(Icons.error))
                       ),
                  ],
                ),
                
                // Hover Overlay (Dark Tint)
                AnimatedOpacity(
                  opacity: _isHovered ? 0.3 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    color: Colors.black,
                  ),
                ),
                
                 // Gradient Overlay (Always visible for text readability in list view, minimal)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),

                // Text Content
                Center( // Kept Centered as per request "similar page like that" (Home has center text)
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation, // Fade in on hover still? Or always show? 
                      // User said: "hover effect of thier name" in Step 0.
                      // "displaying the blocks with hover effect of thier name".
                      // So text is hidden until hover?
                      // In the previous grid version, I had it fade in.
                      // In a list view, hiding text might be bad UX if they don't know what the block is.
                      // But the prompt says "hover effect of thier name". 
                      // "displaying the blocks with hover effect of thier name". 
                      // This could mean: Show blocks (Name?) with hover effect.
                      // OR Show blocks (Image) and Name on hover.
                      // Given Step 0, I'll stick to: Text appears on hover (or emphasizes on hover).
                      // However, typically in list view you want labels. 
                      // But I will stick to the previous satisfied requirement: Fade in text on hover.
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontFamily: 'Roboto',
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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

class _ParallaxFlowDelegate extends FlowDelegate {
  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  _ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      width: constraints.maxWidth,
      height: constraints.maxHeight * 1.4, // Parallax Factor
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    final listItemBox = listItemContext.findRenderObject() as RenderBox?;
    
    if (listItemBox == null || !listItemBox.attached) {
      context.paintChild(0, transform: Matrix4.identity());
      return;
    }

    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction = (listItemOffset.dy / viewportDimension).clamp(0.0, 1.0);

    final verticalAlignment = Alignment(0.0, scrollFraction * 2 - 1);
    
    final backgroundSize = context.getChildSize(0)!;
    final listItemSize = context.size;
    final childRect = verticalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    context.paintChild(
      0,
      transform: Matrix4.translationValues(
        0.0,
        childRect.top,
        0.0,
      ),
    );
  }

  @override
  bool shouldRepaint(_ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}
