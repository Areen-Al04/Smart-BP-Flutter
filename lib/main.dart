import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// استيراد الشاشات الخاصة بمشروعك
import 'splash_screen.dart';
import 'profile_screen.dart';
import 'measurement_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

// تعريف البلجن الخاص بالتنبيهات ليكون متاحاً لكل الصفحات
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // التأكد من تهيئة الإطارات البرمجية قبل أي شيء
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة مكتبة الترجمة
  await EasyLocalization.ensureInitialized();

  // إعدادات التنبيهات للأندرويد
  const AndroidInitializationSettings initializationSettingsAndroid = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initializationSettings = 
      InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const SmartBPApp(),
    ),
  );
}

class SmartBPApp extends StatelessWidget {
  const SmartBPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart BP - AI Health System',
      debugShowCheckedModeBanner: false,
      
      // إعدادات اللغة والترجمة المعتمدة في مشروعك
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E8E7E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E8E7E),
          primary: const Color(0xFF1E8E7E),
          secondary: const Color(0xFF004D40),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF0F4F3),
      ),

      // نقطة انطلاق التطبيق
      home: const SplashScreen(), 

      // الـ Routes الخاصة بالتنقل بين الشاشات
      routes: {
        '/profile': (context) => const ProfileSetupScreen(),
        '/settings': (context) => const SettingsScreen(userName: "Areen Al-Akalik"), // استخدمنا اسمك الافتراضي
        '/history': (context) => const HistoryScreen(userName: "Areen Al-Akalik"),
      },
    );
  }
}
