# Overview
Fintak is a Flutter application for tracking personal finances entirely on-device. It lets you log income and expenses, set budgets per category, and visualize spending trends over time — all wrapped in a polished, theme-aware UI.
The app is built with MVVM architecture and Riverpod for state management, uses Firebase Auth for account creation/sign-in, and persists financial data locally via SharedPreferences, making it lightweight and easy to run without a backend database.

 # Features
•	🔐 Authentication — Email/password sign-up and login via Firebase Auth
•	🏠 Home dashboard — At-a-glance overview of balance, recent activity, and quick actions
•	💸 Transactions — Add, view, and browse full transaction history
•	📊 Budgeting — Set and track budgets by category
•	📈 Stats & charts — Visual breakdown of spending and income using fl_chart
•	⚙️ Settings — App preferences and account management
•	🌗 Light & dark themes — Fully themed UI across every screen
•	📴 Local-first storage — No cloud database required; data lives on-device via SharedPreferences

 # Screenshots

## 🌞 Light Mode

<p align="center"> <img src="assets/logo/screenshots/lightmode1.png" width="45%" alt="Fintak light mode screenshot 1"/> &nbsp;&nbsp; <img src="assets/logo/screenshots/lightmode2.png" width="45%" alt="Fintak light mode screenshot 2"/> </p> 

## 🌚 Dark Mode

<p align="center"> <img src="assets/logo/screenshots/darkmode1.png" width="45%" alt="Finttak dark mode screenshot 1"/> &nbsp;&nbsp; <img src="assets/logo/screenshots/darkmode2.png" width="45%" alt="Fintak dark mode screenshot 2"/> </p> 

# Tech Stack
Layer	Technology
Framework	Flutter (Dart SDK ^3.12.1)
State Management	flutter_riverpod ^3.3.1

# Architecture	MVVM
Auth	firebase_auth ^6.5.2 + firebase_core ^4.10.0
Local Storage	shared_preferences ^2.5.5
Navigation	go_router ^17.3.0
Charts	fl_chart ^1.2.0
Utilities	uuid, intl

# Project Structure


lib/
├── core/
│   ├── constants/       # App-wide constants (colors, etc.)
│   ├── providers/       # Riverpod app-level providers
│   ├── router/          # go_router configuration
│   └── theme/           # Light/dark theme definitions
├── data/
│   └── datasources/     # Local data source (SharedPreferences-backed)
├── features/
│   ├── auth/            # Login & sign-up screens + viewmodels
│   ├── home/             # Home dashboard & all-transactions screens
│   ├── budget/           # Budgeting screen & viewmodel
│   ├── stats/            # Charts & spending statistics
│   └── settings/         # App settings screen & viewmodel
├── shared/
│   └── widgets/          # Shared widgets (e.g. bottom nav shell)
├── firebase_options.dart
└── main.dart

 
  Each feature module follows the same convention: screens/, viewmodels/, and widgets/, keeping UI, state, and presentation logic cleanly separated per MVVM.
 
Getting Started
Prerequisites
•	Flutter SDK (Dart ^3.12.1)
•	A configured Firebase project with Email/Password auth enabled
•	Android Studio / Xcode for mobile builds, or a supported desktop/web target
Installation
bash
# Clone the repo
git clone https://github.com/Kiyanjr/fintak.git
cd fintak

# Install dependencies
flutter pub get

# Run the app
flutter run
Firebase Setup
This project expects a firebase_options.dart generated via the FlutterFire CLI:
bash
dart pub global activate flutterfire_cli
flutterfire configure
Note: Data persistence uses SharedPreferences rather than Firestore, so no Firestore setup is required — only Firebase Auth needs to be enabled in your Firebase console.
Author
Built by Kiyanjr
