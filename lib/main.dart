import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarfiyum_mobile/providers/tenant_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sarfiyum_mobile/providers/category_settings_provider.dart';
import 'package:sarfiyum_mobile/providers/profile_provider.dart';
import 'package:sarfiyum_mobile/providers/viewer_provider.dart';
import 'package:sarfiyum_mobile/providers/visitor_settings_provider.dart';
import 'package:sarfiyum_mobile/services/secure_storage_service.dart';
import 'package:sarfiyum_mobile/services/base_api_service.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/gold_hub_provider.dart';
import 'providers/multiplier_settings_provider.dart';

// Screens
import 'screens/common/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/user/user_dashboard.dart';

// 🔥 1. GLOBAL KEY TANIMLA (En tepeye)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _checkFreshInstall();
  runApp(const MyApp());
}

Future<void> _checkFreshInstall() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('is_installed_before') == null) {
    await SecureStorageService().clearAll();
    await prefs.setBool('is_installed_before', true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GoldHubProvider()),
        ChangeNotifierProvider(create: (_) => MultiplierSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ViewerProvider()),
        ChangeNotifierProvider(create: (_) => CategorySettingsProvider()),
        ChangeNotifierProvider(create: (_) => TenantSettingsProvider()),
        ChangeNotifierProvider(create: (_) => VisitorSettingsProvider()),
      ],
      child: MaterialApp(
        // 🔥 2. NAVIGATOR KEY'İ BURAYA EKLE
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Sarfiyum Mobile',
        theme: ThemeData(
          primarySwatch: Colors.amber,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        // LifecycleManager ile tüm uygulamayı sarıyoruz
        home: const LifecycleManager(child: AuthWrapper()),
      ),
    );
  }
}

// Uygulama Durumunu Dinleyen Widget (Background Logout için)
class LifecycleManager extends StatefulWidget {
  final Widget child;
  const LifecycleManager({super.key, required this.child});

  @override
  State<LifecycleManager> createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Uygulama arka plana geçtiğinde (Home tuşu, başka uygulama açma vs.)
    if (state == AppLifecycleState.paused) {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      // 🔥 SADECE VIEWER İSE BEKLEMEDEN ANINDA LOGOUT 🔥
      if (auth.isViewer) {
        print("👀 Viewer arka plana geçti. Anında çıkış yapılıyor.");
        auth.logoutForBackground();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
  void initState() {
    super.initState();

    // 🔥 API'den 401 gelirse (Oturum başka yerde açıldı) AuthProvider'ı tetikle
    BaseApiService.onTokenExpired = () {
      print("🚨 API Callback Tetiklendi: Global Logout başlatılıyor.");

      // Navigator key üzerinden mevcut context'i bul
      final context = navigatorKey.currentContext;

      if (context != null) {
        // Provider'a ulaş ve logout yap
        Provider.of<AuthProvider>(context, listen: false).handleUnauthorized();
      }
    };
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Uygulama açılır açılmaz Token kontrolü yap (User/Admin için)
      Provider.of<AuthProvider>(context, listen: false).tryAutoLogin().then((
        success,
      ) {
        setState(() {
          _isInit = false; // Kontrol bitti
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (_isInit || auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    // Giriş yapılmamışsa Login
    if (!auth.isAuthenticated || auth.user == null) {
      return const LoginScreen();
    }

    final roles = auth.user!.roles ?? [];

    if (roles.any((r) => r.toLowerCase() == 'admin')) {
      return const AdminDashboard();
    } else if (roles.any(
      (r) => r.toLowerCase() == 'user' || r.toLowerCase() == 'viewer',
    )) {
      return const UserDashboard();
    } else {
      return const UserDashboard();
    }
  }
}
