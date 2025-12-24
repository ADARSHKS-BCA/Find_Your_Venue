# Venue Finder PWA

A modern, offline-first Flutter Progressive Web App (PWA) designed to help students and visitors navigate the university campus efficiently.

## 📱 Features

### **Offline-First & PWA**
-   **Installable**: Can be installed as a native app on Android, iOS, and Desktop.
-   **Offline Access**: Works fully without internet after the first load. (Simulated offline capability via asset definition).

### **Smart Navigation & Search**
-   **Search**: Typo-tolerant search for venues, blacks, and rooms.
-   **Categories**: Filter by Academic, Administrative, Events, Hostels, and more.
-   **Quick Access**: Dedicated shortcuts for popular categories.

### **Detailed Venue Info**
-   **Visuals**: High-quality images for every venue and block.
-   **Directions**: Step-by-step walking instructions with a "Navigation Mode".
-   **Accessibility**: Indicators for elevators and ground-floor access.
-   **Auto-Arrival**: Smart navigation flow that confirms arrival automatically.

### **Explore Blocks**
-   **Block Details**: Dedicated card-based view for major campus blocks ("Central Block", "Block 1", etc.).
-   **What's Inside**: Automatically lists all venues contained within a specific block.
-   **Quick Facts**: At-a-glance info on floors, washrooms, and WiFi.

### **Personalized**
-   **Recent Venues**: Automatically remembers your last 4 visited locations (stored locally on your device).
-   **Zero Login**: No account required—download and go.

---

## 🛠 Tech Stack

-   **Framework**: [Flutter](https://flutter.dev) (Web)
-   **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
-   **Local Storage**: [SharedPreferences](https://pub.dev/packages/shared_preferences) for "Recent" history.
-   **Hosting**: Firebase Hosting

---

## 🚀 Installation & Development

### Prerequisites
-   [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.9.0 or higher)
-   Chrome Browser (for debugging)

### Run Locally
Clone the project and run in your terminal:

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on Chrome
flutter run -d chrome

# 3. Specify port (optional)
flutter run -d chrome --web-port 6859
```

---

## ☁️ Deployment (Firebase)

This project is configured for Firebase Hosting.

### 1. Build for Web
Create the optimized production build:
```bash
flutter build web --release --web-renderer html
```
> *Using `html` renderer is recommended for faster load times on mobile web.*

### 2. Deploy
Push the `build/web` folder to your Firebase project:
```bash
firebase deploy
```

---

## 📂 Project Structure

```
lib/
├── data/            # Static data (Venues, Blocks)
├── models/          # Data models (Venue class)
├── screens/         # UI Screens
│   ├── home_screen.dart        # Dashboard & Search Entry
│   ├── search_screen.dart      # Filterable List
│   ├── details_screen.dart     # Venue Information
│   ├── navigation_screen.dart  # Walking Mode
│   ├── explore_blocks_screen.dart # Block List
│   └── block_detail_screen.dart   # Specific Block Info
├── widgets/         # Reusable UI Components
└── main.dart        # Entry point & Routing
```

---

## 🎨 Credits
-   **Icons**: Material Design Icons
-   **Fonts**: Google Fonts (Inter/Roboto default)
-   **Developed by**: Adarsh K S
