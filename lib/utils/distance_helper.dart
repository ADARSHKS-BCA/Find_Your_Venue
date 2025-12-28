import '../models/venue.dart';

class DistanceHelper {
  static String getDistanceLabel(Venue venue) {
    // Requirements: Qualitative labels derived from existing static data.
    // Since we don't have real coordinates, we'll implement a deterministic pseudo-random logic
    // based on the venue ID or Name to consistency assign a "Distance".
    
    // In a real app with coordinates, this would calculate Haversine distance.
    // Here we simulate "Realism".
    
    final int hash = venue.id.hashCode;
    final int mod = hash % 3;
    
    switch (mod) {
      case 0:
        return "Short walk";
      case 1:
        return "Moderate walk";
      case 2:
        return "Long walk";
      default:
        return "Moderate walk";
    }
    
    // Alternative: Map specific blocks if blockName is available
    // if (venue.blockName.contains("Academic")) return "Short walk";
    // if (venue.blockName.contains("Hostel")) return "Long walk";
  }
}
