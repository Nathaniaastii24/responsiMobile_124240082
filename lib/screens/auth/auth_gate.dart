import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../widgets/habitz_widgets.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _checkSession();
  }

  Future<bool> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userId = prefs.getInt('user_id');

    return isLoggedIn && userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: HabitzBackground(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Results(size: 110),
                    SizedBox(height: 24),
                    CircularProgressIndicator(
                      color: AppColors.purple,
                      strokeWidth: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
