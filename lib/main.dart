import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart' deferred as search;
import 'screens/details_screen.dart' deferred as details;
import 'screens/explore_blocks_screen.dart' deferred as explore;
import 'screens/block_detail_screen.dart' deferred as block_detail;

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
      builder: (context, state) => FutureBuilder(
        future: search.loadLibrary(),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.done) {
             return search.SearchScreen();
           }
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    ),
    GoRoute(
      path: '/venue/:id',
      builder: (context, state) {
         final id = state.pathParameters['id']!;
         return FutureBuilder(
            future: details.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return details.DetailsScreen(id: id);
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
         );
      },
    ),
    GoRoute(
      path: '/explore_blocks',
      builder: (context, state) => FutureBuilder(
        future: explore.loadLibrary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return explore.ExploreBlocksScreen();
          }
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    ),
    GoRoute(
      path: '/block_detail',
      builder: (context, state) {
        final name = state.uri.queryParameters['name']!;
        final imageUrl = state.uri.queryParameters['imageUrl']!;
        return FutureBuilder(
            future: block_detail.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return block_detail.BlockDetailScreen(blockName: name, imageUrl: imageUrl);
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
        );
      },
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
