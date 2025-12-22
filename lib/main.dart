import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/details_screen.dart';
import 'screens/explore_blocks_screen.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/venue/:id',
      builder: (context, state) {
         final id = state.pathParameters['id']!;
         return DetailsScreen(id: id);
      },
    ),
    GoRoute(
      path: '/explore_blocks',
      builder: (context, state) => const ExploreBlocksScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Venue Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF264796), 
          primary: const Color(0xFF264796), // Brand Blue
          background: Colors.white
        ),
        useMaterial3: true,
        // textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      routerConfig: _router,
    );
  }
}
