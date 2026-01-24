import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.point_of_sale,
              size: 100,
              color: Colors.white,
            ).animate().fade(duration: 500.ms).scale(delay: 500.ms),
            const SizedBox(height: 24),
            Text(
              'Flutter POS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.5, end: 0),
            const SizedBox(height: 48),
            // Loading indicator is optional but good for UX
            const CircularProgressIndicator(
              color: Colors.white,
            ).animate().fadeIn(delay: 1500.ms),
          ],
        ),
      ),
    );
  }
}
