import 'package:flutter/material.dart';
import 'package:sabilearn/features/auth/auth_index.dart';
import 'package:sabilearn/features/core/core_index.dart';
import 'package:sabilearn/features/onboarding/onboarding_index.dart';

void main() {
  runApp(const SabiLearnApp());
}

class SabiLearnApp extends StatelessWidget {
  const SabiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SabiLearn',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingEntryScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup':(context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeDashboardScreen(),
      },
    );
  }
}
