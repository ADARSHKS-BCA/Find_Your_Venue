import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/venue.dart';

class NavigationScreen extends StatefulWidget {
  final Venue venue;
  const NavigationScreen({super.key, required this.venue});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  void _nextStep() {
    if (_currentStep < widget.venue.instructions.length) { // Allow going to length (which is arrival state)
      setState(() {
        _currentStep++;
      });
      // If we haven't arrived yet, scroll. If arrived, the view changes anyway.
      if (_currentStep < widget.venue.instructions.length) {
         _scrollToCurrent();
      }
    }
  }

  void _scrollToCurrent() {
    // Simple auto-scroll if needed, but centering via logic is better
    if (_scrollController.hasClients && _currentStep < widget.venue.instructions.length) {
       _scrollController.animateTo(
         _currentStep * 100.0, // rough estimate of height
         duration: const Duration(milliseconds: 300), 
         curve: Curves.easeInOut
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if arrived
    final bool isArrived = _currentStep >= widget.venue.instructions.length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Heading to',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              widget.venue.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(), // Use Navigator pop since we pushed it
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: isArrived ? _buildArrivalView() : _buildNavigationList(),
          ),
        ),
      ),
      bottomNavigationBar: isArrived ? null : _buildBottomControls(),
    );
  }

  Widget _buildNavigationList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemCount: widget.venue.instructions.length + 1, // +1 for spacing
      itemBuilder: (context, index) {
        if (index == widget.venue.instructions.length) return const SizedBox(height: 100);
        
        final isActive = index == _currentStep;
        final isPast = index < _currentStep;
        final isFuture = index > _currentStep;

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isActive ? 1.0 : (isFuture ? 0.3 : 0.6),
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? theme.colorScheme.primary : (isPast ? Colors.green : (isDark ? Colors.grey[700] : Colors.grey[200])),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isPast 
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (index < widget.venue.instructions.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venue.instructions[index],
                        style: TextStyle(
                          fontSize: isActive ? 18 : 16,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive 
                            ? (isActive ? theme.colorScheme.onBackground : theme.colorScheme.onBackground) // Fix logic: Active text color
                            : (isActive ? Colors.black : Colors.grey[800]), // Wait, logic below matches original intent but with theme
                      ),
                    ),
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Keep walking...', // Microcopy
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? theme.cardTheme.color : Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(isDark ? 0.3 : 0.05)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep == widget.venue.instructions.length - 1 
                      ? 'Arrive at Destination' 
                      : 'Next Step',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrivalView() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, size: 64, color: Colors.green),
              ),
              const SizedBox(height: 32),
              Text(
                'You have arrived!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You are at ${widget.venue.name}.',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]), // Valid generic grey
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Nearby / Inside Guidance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardTheme.color : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Inside Guidance', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 8),
                    Text(
                      'Check floor signage. Washrooms are usually near the staircase.',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    foregroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.home),
                  label: const Text('Return to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
