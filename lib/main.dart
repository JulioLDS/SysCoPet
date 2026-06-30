import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import 'package:syscopet/screens/splash_screen/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'core/themes/app_theme.dart';
import 'screens/auth/auth_screen.dart';

void main() {
  runApp(

    MultiProvider(
      providers:[
    ChangeNotifierProvider(
      create: (_) {
        final provider = AuthProvider();
        provider.loadSession();
        return provider;
      },
    ),

    ChangeNotifierProvider(
      create:(_) => PetProvider(),
       ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyscoPet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
