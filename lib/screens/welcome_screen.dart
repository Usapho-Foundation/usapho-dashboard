import 'dart:async';

import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });

      _timer = Timer(const Duration(seconds: 4), _navigateToDashboard);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToDashboard() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.24),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(22),
                    child: const Icon(
                      Icons.dashboard_customize,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Usapho Dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Loading your dashboard now...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
