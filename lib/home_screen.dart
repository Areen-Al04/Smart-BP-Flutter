import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'measurement_screen.dart';
import 'history_screen.dart';
import 'package:flutter_application_1/settings_screen.dart'; 
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; 
import 'bluetooth_service.dart'; 

class HomeScreen extends StatefulWidget {
  final String userName; 

  const HomeScreen({super.key, required this.userName}); 

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);
  final Color webBg = const Color(0xFFF0F4F3);
  
  late String displayName;
  
  BluetoothDevice? connectedDevice; 

  @override
  void initState() {
    super.initState();
    displayName = widget.userName;
    _loadStoredName();
    
    // تشغيل المراقبة التلقائية العامة عند بدء الشاشة
    AppBluetoothManager.startMonitoring();
  }

  _loadStoredName() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedName = prefs.getString('patient_name');
    if (storedName != null && storedName.isNotEmpty) {
      setState(() {
        displayName = storedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: webBg,
      drawer: isMobile ? _buildSidebar(context, isArabic) : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isMobile ? Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: darkTeal),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ) : null,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language, color: Color(0xFF1E8E7E)),
            label: Text(
              isArabic ? "English" : "العربية", 
              style: const TextStyle(color: Color(0xFF1E8E7E), fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              context.setLocale(isArabic ? const Locale('en') : const Locale('ar'));
            },
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(context, isArabic),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [Colors.white, webBg, const Color(0xFFD1E8E2)],
                ),
              ),
              child: SingleChildScrollView( 
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20.0 : 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(isArabic, isMobile), 
                      const SizedBox(height: 40),
                      
                      isMobile 
                        ? Column(children: _buildStatsCardsList(isArabic)) 
                        : _buildStatsCards(isArabic),
                        
                      const SizedBox(height: 40),
                      _buildMainActionCard(context, isArabic, isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(bool isArabic, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? "أهلاً بكِ مجدداً، $displayName!" : "Welcome back, $displayName!", 
          style: TextStyle(
            fontSize: isMobile ? 28 : 36, 
            fontWeight: FontWeight.w900, 
            color: darkTeal
          )
        ),
        Text(
          isArabic ? "إليكِ نظرة عامة على صحتكِ اليوم." : "Here is your health overview for today.", 
          style: const TextStyle(color: Colors.grey, fontSize: 16)
        ),
      ],
    );
  }

  Widget _buildStatsCards(bool isArabic) {
    return Row(
      children: _buildStatsCardsList(isArabic, isExpanded: true),
    );
  }

  List<Widget> _buildStatsCardsList(bool isArabic, {bool isExpanded = false}) {
    List<Widget> cards = [
      _statCard(isArabic ? "متوسط الضغط" : "Avg. BP", "118/76", Icons.speed, Colors.teal),
      _statCard(isArabic ? "نبض القلب" : "Avg. Heart Rate", "72 bpm", Icons.favorite, Colors.redAccent),
      _statCard(isArabic ? "جودة النوم" : "Sleep Quality", "8h 20m", Icons.bedtime, Colors.indigo),
    ];

    if (isExpanded) {
      return cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: c))).toList();
    } else {
      return cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 20), child: c)).toList();
    }
  }

  Widget _statCard(String title, String val, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: col, size: 30),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkTeal)),
        ],
      ),
    );
  }

  Widget _buildMainActionCard(BuildContext context, bool isArabic, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [webPrimary, darkTeal]),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: webPrimary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? "جاهزة لفحص جديد؟" : "Ready for a new scan?", 
                style: TextStyle(color: Colors.white, fontSize: isMobile ? 24 : 28, fontWeight: FontWeight.bold),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 10),
              Text(
                isArabic ? "قومي بتوصيل الحساس وابدئي تحليل الذكاء الاصطناعي." : "Connect your sensor and start the AI analysis.", 
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: isMobile ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 30),
              // --- الزر المعدل: اتصال + إرسال أمر + انتقال ---
              ElevatedButton(
                onPressed: () async {
                  // 1. جلب قائمة الأجهزة المتصلة بالبلوتوث حالياً
                  List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
                  
                  if (devices.isNotEmpty) {
                    connectedDevice = devices.first;
                    // 2. إرسال أمر بدء القياس وفتح قنوات الـ Notify
                    await AppBluetoothManager.startBloodPressureMeasurement(connectedDevice!);
                  } else {
                    // ملاحظة اختيارية: يمكن هنا توجيه المستخدم لشاشة المسح إذا لم يكن هناك جهاز متصل
                    print("لا يوجد جهاز متصل حالياً.");
                  }
                  
                  // 3. الانتقال لصفحة القياس لمتابعة النتائج الحية
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => MeasurementScreen(userName: displayName))
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text(
                  isArabic ? "بدء القياس" : "START MEASUREMENT", 
                  style: TextStyle(color: darkTeal, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          if (!isMobile) const Icon(Icons.auto_awesome, color: Colors.white24, size: 150),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isArabic) {
    return Container(
      width: 260,
      color: darkTeal,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            'assets/logo.jpg', 
            height: 70, 
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => const Icon(Icons.monitor_heart, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 15),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  displayName.toUpperCase(), 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  isArabic ? "ملف المريض" : "Patient Profile",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Divider(color: Colors.white24, thickness: 1),
          ),

          _sidebarItem(Icons.dashboard, isArabic ? "لوحة التحكم" : "Dashboard", true, () {}),
          _sidebarItem(Icons.add_chart, isArabic ? "قياس جديد" : "New Measurement", false, () async {
            // تنفيذ نفس المنطق عند الضغط من القائمة الجانبية
            List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
            if (devices.isNotEmpty) {
              await AppBluetoothManager.startBloodPressureMeasurement(devices.first);
            }
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => MeasurementScreen(userName: displayName))
            );
          }),
          _sidebarItem(Icons.history, isArabic ? "السجلات الطبية" : "Medical Records", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryScreen(userName: displayName)))),
          _sidebarItem(Icons.settings, isArabic ? "الإعدادات" : "Settings", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsScreen(userName: displayName)))),
          const Spacer(),
          _sidebarItem(Icons.logout, isArabic ? "خروج" : "Logout", false, () => Navigator.pop(context)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        onTap: onTap,
      ),
    );
  }
}
