import 'package:fintak/core/providers/app_providers.dart';
import 'package:fintak/features/budget/screens/budget_screen.dart';
import 'package:fintak/features/home/screens/home_screen.dart';
import 'package:fintak/features/auth/screens/login_scren.dart';
import 'package:fintak/features/settings/screens/settings_screen.dart';
import 'package:fintak/features/auth/screens/sign_up_screen.dart';
import 'package:fintak/features/stats/screens/state_screen.dart';
import 'package:fintak/shared/widgets/bottom_nav_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RouterNotifire extends ChangeNotifier {
final Ref _ref;
RouterNotifire(this._ref){
  _ref.listen(appStateProvider, (_,__){notifyListeners();});
}
}

final appRouterProvider=Provider<GoRouter>((ref){
 return GoRouter(
   // Starting point
    initialLocation: '/login',
    
    // connecting that to our Class
    refreshListenable: RouterNotifire(ref),
  redirect: (context,state){
   // Get the current app state using ref.read (or ref.watch inside provider)
    final appState=ref.watch(appStateProvider);
    final currentUserId=appState.currentUserId;
    //   Get the screen that user is tryin to open
    final  matchedLocation=state.matchedLocation;

      //  LOG SING SENARIOS

                // NOT LOGGED
      if(currentUserId==null&& matchedLocation!='/login'&&matchedLocation!='/signup'){
        return '/login';
      }
      if(currentUserId!=null&&(matchedLocation=='/login'&&matchedLocation=='/singup')){
         return'/home';
      }
      return null;
  },
  //      APP ROUTES
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
      ),
       GoRoute(
      path: '/singup',
      builder: (context, state) => const SignUpScreen(),
      ),
      // ShellRoute wraps the main tabs inside the BottomNavShell
      ShellRoute(
         builder: (context, state, child) {
           return BottomNavShell(child: child);
         },
         routes: [
          GoRoute(
           path: '/home',
           builder: (context, state) => const HomeScreen(),
          ),
           GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
           GoRoute(
            path: '/stats',
            builder: (context, state) => const StateScreen(),
          ),
           GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
    
         ]
      ),
  ],
 );
  
});


