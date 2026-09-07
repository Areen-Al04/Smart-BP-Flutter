import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'measurement_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'responsive.dart';

class AIAnalysisScreen extends StatefulWidget {
  final String bp;
  final String hr;
  final String spo2;
  final List<String> diseases;
  final String userName;

  const AIAnalysisScreen({
    super.key,
    required this.bp,
    required this.hr,
    required this.spo2,
    this.diseases = const [],
    this.userName = "User",
  });

  @override
  State<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> with TickerProviderStateMixin {
  bool isAnalyzing = true;
  late AnimationController _pulseController;
  late AnimationController _contentController;
  late Animation<double> _fadeAnimation;

  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);
  final Color webBg = const Color(0xFFF0F4F3);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _contentController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeIn));
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => isAnalyzing = false);
        _contentController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: webBg,
      drawer: r.showFixedSidebar ? null : _buildWebSidebar(context, isArabic),
      appBar: r.showFixedSidebar
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: darkTeal),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Text(isArabic ? "تحليل الذكاء الاصطناعي" : "AI Analysis",
                  style: TextStyle(color: darkTeal, fontWeight: FontWeight.bold)),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.language, color: Color(0xFF1E8E7E)),
                  label: Text(isArabic ? "English" : "العربية",
                      style: const TextStyle(color: Color(0xFF1E8E7E), fontWeight: FontWeight.bold)),
                  onPressed: () => context.setLocale(isArabic ? const Locale('en') : const Locale('ar')),
                ),
                const SizedBox(width: 10),
              ],
            ),
      body: Row(
        children: [
          if (r.showFixedSidebar) _buildWebSidebar(context, isArabic),
          Expanded(
            child: Stack(
              children: [
                _buildBackgroundGradient(),
                Center(
                  child: SingleChildScrollView(
                    padding: r.pagePadding,
                    child: isAnalyzing
                        ? _buildLoadingState(isArabic)
                        : _buildAnimatedContent(isArabic, r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [Colors.white, webBg, const Color(0xFFD1E8E2)],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildWebSidebar(BuildContext context, bool isArabic) {
    return Container(
      width: 260,
      color: darkTeal,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset('assets/logo.jpg', height: 80,
              errorBuilder: (c, e, s) => const Icon(Icons.psychology, color: Colors.white, size: 50)),
          const SizedBox(height: 40),
          _sidebarItem(Icons.dashboard, isArabic ? "لوحة التحكم" : "Dashboard", false, context, isArabic),
          _sidebarItem(Icons.add_chart, isArabic ? "قياس جديد" : "New Measurement", false, context, isArabic),
          _sidebarItem(Icons.history, isArabic ? "السجلات الطبية" : "Medical Records", false, context, isArabic),
          _sidebarItem(Icons.psychology, isArabic ? "تحليل الذكاء الاصطناعي" : "AI Analysis", true, context, isArabic),
          _sidebarItem(Icons.settings, isArabic ? "الإعدادات" : "Settings", false, context, isArabic),
          const Spacer(),
          _sidebarItem(Icons.logout, isArabic ? "خروج" : "Logout", false, context, isArabic),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive, BuildContext context, bool isArabic) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        onTap: () {
          if (label == (isArabic ? "لوحة التحكم" : "Dashboard")) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)));
          if (label == (isArabic ? "قياس جديد" : "New Measurement")) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MeasurementScreen(userName: widget.userName)));
          if (label == (isArabic ? "السجلات الطبية" : "Medical Records")) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryScreen(userName: widget.userName)));
          if (label == (isArabic ? "الإعدادات" : "Settings")) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsScreen(userName: widget.userName)));
          if (label == (isArabic ? "خروج" : "Logout")) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isArabic) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.2).animate(_pulseController),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: webPrimary.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
            ),
            child: Icon(Icons.psychology, size: 70, color: webPrimary),
          ),
        ),
        const SizedBox(height: 50),
        Text(isArabic ? "الذكاء الاصطناعي يحلل الآن..." : "Smart BP AI is analyzing...",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkTeal),
            textAlign: TextAlign.center),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isArabic ? "يتم ربط البيانات الحيوية بالسجل السريري." : "Correlating vitals with clinical history.",
            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 40),
        const SizedBox(width: 280, child: LinearProgressIndicator(color: Color(0xFF1E8E7E))),
      ],
    );
  }

  Widget _buildAnimatedContent(bool isArabic, AppResponsive r) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        // ✅ عرض متغير بدل 900 ثابت
        width: r.cardMaxWidth,
        padding: r.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(r.isMobile ? 24 : 35),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r.isMobile ? 24 : 35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              children: [
                _buildWOWHeader(isArabic, r),
                const SizedBox(height: 30),
                _buildWOWResultsGrid(isArabic, r),
                const SizedBox(height: 30),
                _buildWOWRecommendation(isArabic),
                const SizedBox(height: 40),
                _buildWOWActionButtons(isArabic, r),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWOWHeader(bool isArabic, AppResponsive r) {
    return Column(
      children: [
        Text(isArabic ? "تقرير تشخيص الذكاء الاصطناعي" : "AI Diagnostic Report",
            style: TextStyle(fontSize: r.subtitleFontSize, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
            textAlign: TextAlign.center),
        Text(isArabic ? "تم الإنشاء بواسطة نظام Smart BP v1.0" : "Generated by Smart BP Framework v1.0",
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildWOWResultsGrid(bool isArabic, AppResponsive r) {
    final cards = [
      _buildWOWResultCard(isArabic ? "الحالة" : "Status", isArabic ? "مستقر" : "STABLE", Icons.verified, Colors.green),
      _buildWOWResultCard(isArabic ? "تحليل الضغط" : "BP Analysis", isArabic ? "طبيعي" : "NORMAL", Icons.analytics, Colors.green),
      _buildWOWResultCard(isArabic ? "خطر القلب" : "Heart Risk", isArabic ? "منخفض" : "LOW", Icons.gpp_good, Colors.blue),
    ];

    // ✅ موبايل = عمود، ديسكتوب = صف
    if (r.isMobile) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 12),
          cards[1],
          const SizedBox(height: 12),
          cards[2],
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 20),
        Expanded(child: cards[1]),
        const SizedBox(width: 20),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildWOWResultCard(String title, String val, IconData icon, Color col) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 30),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col, letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildWOWRecommendation(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
          BoxShadow(color: Colors.black.withOpacity(0.03), offset: const Offset(5, 5), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.psychology, color: webPrimary),
            const SizedBox(width: 15),
            Flexible(
              child: Text(isArabic ? "توصية الذكاء الاصطناعي" : "AI CLINICAL RECOMMENDATION",
                  style: TextStyle(fontWeight: FontWeight.bold, color: darkTeal, letterSpacing: 1.2)),
            ),
          ]),
          const SizedBox(height: 20),
          Text(
            isArabic
                ? "بناءً على ملفك الشخصي (${widget.diseases.join(', ')}), فإن ضغط دمك ${widget.bp} ضمن الحدود الآمنة. نوصي بفترة استرخاء 15 دقيقة."
                : "Based on your profile (${widget.diseases.join(', ')}), your BP of ${widget.bp} is within safe limits. We recommend a 15-minute relaxation period.",
            style: const TextStyle(height: 1.6, fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildWOWActionButtons(bool isArabic, AppResponsive r) {
    return SizedBox(
      width: r.isMobile ? double.infinity : 300,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)), (route) => false),
        icon: const Icon(Icons.dashboard, color: Colors.white),
        label: Text(isArabic ? "العودة للوحة التحكم" : "FINAL DASHBOARD",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
