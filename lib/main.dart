import 'package:flutter/material.dart';
import 'services/steps_service.dart';
import 'package:provider/provider.dart';
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'state/water_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const WaterTrackerApp());

  await StepsService.instance.start();
}

class WaterTrackerApp extends StatelessWidget {
  const WaterTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterState()..load(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Water Tracker',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'MinecraftRus',
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        home: const SplashScreen(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/main': (_) => const MainNavigation(),
        },
      ),
    );
  }
}