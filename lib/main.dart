import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'providers/esp_provider.dart';
import 'providers/camera_provider.dart';
import 'providers/risk_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDlM9bJUF4Yqk9hb_Cvcyp7OAZk8kV24LM',
      appId: '1:432837023148:android:56c139cebff1155e751609',
      messagingSenderId: '432837023148',
      projectId: 'ocupulse',
      databaseURL: 'https://ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app',
      storageBucket: 'ocupulse.firebasestorage.app',
    ),
  );
  
  print('✅ Firebase connected to: https://ocupulse-default-rtdb.asia-southeast1.firebasedatabase.app');

  runApp(const SonoSightApp());
}

class SonoSightApp extends StatelessWidget {
  const SonoSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ESPProvider()),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => RiskProvider()),
      ],
      child: MaterialApp(
        title: 'SonoSight',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
