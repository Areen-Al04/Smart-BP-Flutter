import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'responsive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _rotation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Colors.white, Color(0xFFF0F4F3), Color(0xFFD1E8E2)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.002)
                      ..rotateY(_rotation.value)
                      ..rotateX(_rotation.value * 0.5)
                      ..scale(_scale.value),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 40,
                            offset: const Offset(20, 20),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.asset(
                          'assets/logo.jpg',
                          // ✅ حجم متغير حسب الشاشة بدل 420 ثابت
                          width: r.logoSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: r.isMobile ? 40 : 70),
                  Text(
                    "SMART BP",
                    style: TextStyle(
                      // ✅ حجم خط متغير                      fontSize: r.isMobile ? 28 : 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: r.isMobile ? 4 : 6,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "AI-POWERED HEALTH SYSTEM",
                    style: TextStyle(
                      fontSize: r.isMobile ? 11 : 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: r.isMobile ? 2 : 3,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: r.isMobile ? 40 : 60),
                  SizedBox(
                    width: 50,
                    height: 45,
                    child: CircularProgressIndicator(
                      color: const Color(0xFF1E8E7E),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
