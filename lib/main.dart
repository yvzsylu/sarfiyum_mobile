import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarfiyum_mobile/providers/profile_provider.dart';
import 'package:sarfiyum_mobile/providers/viewer_provider.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/gold_hub_provider.dart';
import 'providers/multiplier_settings_provider.dart'; // <-- YENİ EKLENDİ (1)

// Screens
import 'screens/common/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/user_dashboard.dart';
import 'screens/visitor/visitor_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Kimlik Doğrulama Sağlayıcısı
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 2. Canlı Altın Verisi Sağlayıcısı (UserDashboard bunu kullanacak)
        ChangeNotifierProvider(create: (_) => GoldHubProvider()),

        // 3. Çarpan Ayarları Sağlayıcısı (YENİ EKLENDİ - 2)
        // Bu eklenmezse Ayarlar sayfasına girince uygulama çöker.
        ChangeNotifierProvider(create: (_) => MultiplierSettingsProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => ViewerProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sarfiyum Mobile',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
          // Scaffold arka planını genel olarak beyaz yapalım
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const AuthWrapper(), // Yönlendirme merkezi
      ),
    );
  }
}

// Session kontrolünü ve Yönlendirmeyi yapan Widget
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Uygulama açılır açılmaz Token kontrolü yap
      Provider.of<AuthProvider>(context, listen: false).tryAutoLogin().then((
        _,
      ) {
        setState(() {
          _isInit = false; // Kontrol bitti, loading ekranını kapat
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // 1. Henüz Token kontrolü bitmediyse Splash (Loading) göster
    if (_isInit || auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    // 2. Kullanıcı Giriş Yapmamışsa -> Login
    if (!auth.isAuthenticated || auth.user == null) {
      return const LoginScreen();
    }

    // 3. ROL KONTROLÜ VE YÖNLENDİRME
    // Null safety için roles listesinin boş olmadığından emin olalım
    final roles = auth.user!.roles ?? [];

    if (roles.contains('Admin')) {
      return const AdminDashboard();
    } else if (roles.contains('User')) {
      return const UserDashboard();
    } else {
      // Eğer 'Visitor' ise veya rolü tanımlanamadıysa buraya düşer
      return const VisitorDashboard();
    }
  }
}
