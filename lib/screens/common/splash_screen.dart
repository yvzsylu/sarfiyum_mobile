import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // 🔥 Kütüphane
import 'package:sarfiyum_mobile/main.dart'; // AuthWrapper'a erişmek için

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    // 1. İki saniye bekle (Bu sırada kullanıcı hala Native Logoyu görüyor)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Perdeyi Kaldır!
    // Native ekran gidiyor. Altta ne var? Bu sayfanın build metodu (Beyaz).
    // Ama hemen aşağıda sayfa değiştiği için kullanıcı beyazlığı fark etmez.
    FlutterNativeSplash.remove();

    // 3. Yönlendir (Login veya Dashboard'a)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Resim koymuyoruz! Native ekranın aynısını çizmeye çalışmak
    // boyut farkı hatasına sebep olur. Boş bırakmak en iyisidir.
    return const Scaffold(backgroundColor: Colors.white, body: SizedBox());
  }
}
