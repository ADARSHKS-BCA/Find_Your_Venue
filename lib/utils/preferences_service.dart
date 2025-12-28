import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<String?> lastNavigatedVenueNotifier = ValueNotifier(null);

  static const String _themeKey = 'theme_mode';
  static const String _lastVenueKey = 'last_navigated_venue_id';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final themeIndex = prefs.getInt(_themeKey) ?? 0; // 0: system, 1: light, 2: dark
    themeNotifier.value = ThemeMode.values[themeIndex];

    // Load Last Venue
    lastNavigatedVenueNotifier.value = prefs.getString(_lastVenueKey);
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final currentmode = themeNotifier.value;
    ThemeMode newMode;

    if (currentmode == ThemeMode.system) {
      newMode = ThemeMode.light;
    } else if (currentmode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.system;
    }

    themeNotifier.value = newMode;
    await prefs.setInt(_themeKey, newMode.index);
  }
  
  // Explicitly set light or dark, skipping system for toggle button simplicity if needed
  static Future<void> switchTheme() async {
     final prefs = await SharedPreferences.getInstance();
     // Simple toggle: System -> Light -> Dark -> System... or just Light <-> Dark?
     // Req: "Icon toggles between light and dark mode", "Respect system preference on first launch"
     
     // Implementation: If System, check platform. If platform is Dark, go Light. Else Dark.
     // But simpler: just cycle Light -> Dark -> System (or strict Light <-> Dark after first override)
     
     ThemeMode newMode;
     if (themeNotifier.value == ThemeMode.light) {
       newMode = ThemeMode.dark;
     } else {
       newMode = ThemeMode.light;
     }
     
     themeNotifier.value = newMode;
     await prefs.setInt(_themeKey, newMode.index);
  }

  static Future<void> setLastNavigatedVenue(String venueId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVenueKey, venueId);
    lastNavigatedVenueNotifier.value = venueId;
  }

  static Future<void> clearLastNavigatedVenue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastVenueKey);
    lastNavigatedVenueNotifier.value = null;
  }
}
