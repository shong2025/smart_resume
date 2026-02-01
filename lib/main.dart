import 'package:flutter/material.dart';
import 'package:smart_resume/features/auth/ui/splash_screen.dart'; // استيراد الـ Splash
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://dkdgtfjlbybzyofsvmlo.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrZGd0ZmpsYnlienlvZnN2bWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzODUzODUsImV4cCI6MjA3OTk2MTM4NX0.mwdyvb7lnvAI8E8A71w_sTTe8Xlq6cwxiWephKd4MAw",
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Resume Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(), // ✅ جعل شاشة البداية هي الـ Splash
    );
  }
}
