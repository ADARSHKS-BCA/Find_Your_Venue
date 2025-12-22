import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/hover_card.dart';
import '../widgets/animated_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar removed to allow logo to scroll with content
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 10.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Logo (Scrolls with content)
                      Padding(
                        padding: const EdgeInsets.only(top: 25, bottom: 20),
                        child: Image.asset(
                          'assets/images/college_header.png',
                          height: 150, 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.school,
                              size: 80,
                              color: Color(0xFF264796),
                            );
                          },
                        ),
                      ),
                    // Animated Divider Text
                    const AnimatedTitle(text: 'KNOW OUR CAMPUS'),
                    
                    const SizedBox(height: 32),

                    // 1. New Card Above
                    const HoverCard(
                      imageUrl: 'assets/images/Entrance.png',
                      title: 'FIND YOUR VENUE',
                      route: '/search', 
                    ),
                    const SizedBox(height: 32),

                    // 2. Original Card (Existing)
                    const HoverCard(
                      imageUrl: 'assets/images/Campus.png',
                      title: 'EXPLORE THE BLOCKS ',
                      route: '/explore_blocks', 
                    ),
                    const SizedBox(height: 32),
                    // 3. New Card
                    const HoverCard(
                      imageUrl: 'assets/images/Auditorium.png',
                      title: 'AUDITORIUM',
                      route: '/search', 
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 48), // Bottom safe spacing
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
  }
}
