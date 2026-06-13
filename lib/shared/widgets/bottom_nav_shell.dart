
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNavShell extends ConsumerWidget {
  const BottomNavShell({super.key, required this.child});
  final Widget child;
  int _selectedIndex(BuildContext context){
    final location=GoRouterState.of(context).matchedLocation;
    if(location.startsWith('/budget')) return 1;
     if(location.startsWith('/stats')) return 2;
      if(location.startsWith('/settings')) return 3;
      return 0;
  }
  void _onTap(BuildContext context,int index){
    switch (index){
      case 0:context.go('/home');
      break;
      case 1:context.go('/budget');
      break;
      case 2:context.go('/stats');
      break;
      case 3:context.go('/settings');
      break;
    }
  }
  @override
  Widget build(BuildContext context,WidgetRef ref) {
   return Scaffold(
    body: child,// This shows the current active tab (Home, Budget, etc.)
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex(context),
      onDestinationSelected:(index)=>_onTap(context, index),
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_rounded), 
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.wallet_rounded), 
            label: 'Budget',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_rounded), 
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded), 
            label: 'Settings',
          ),
      ],
    ),
   ); 
  }
}