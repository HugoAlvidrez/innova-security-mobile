import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'main_screen.dart';
import 'screens/emergency/emergency_screen.dart';
import 'screens/evidence/evidence_viewer_screen.dart';
import 'screens/wearable/wearable_screen.dart';

class InnovaSecurityApp extends StatelessWidget {
  const InnovaSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          title: 'SecurityIA Fem',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: authProvider.isAuthenticated ? '/main' : '/login',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/main': (_) => const MainNavigationScreen(),
            '/emergency': (_) => const EmergencyScreen(),
            '/wearable': (_) => const WearableScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/evidence-viewer') {
              final evidenceId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => EvidenceViewerScreen(evidenceId: evidenceId),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
