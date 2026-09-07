import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async'; 
import 'ai_screen.dart'; 
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'bluetooth_service.dart'; 
import 'bluetooth_scan_screen.dart'; 
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;

class MeasurementScreen extends StatefulWidget {
  final List<String> userChronicDiseases;
  final String userName;

  const MeasurementScreen({
    super.key, 
    this.userChronicDiseases = const [], 
    this.userName = "User"
  });

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> with TickerProviderStateMixin {
  // --- متغيرات الحالة ---
  bool isMeasuring = false;
  String bpValue = "--/--";
  String hrValue = "--";
  String spo2Value = "--";
  
  double currentSystolic = 0;
  double currentDiastolic = 0;
  int currentHeartRate = 0;
  String selectedSymptom = 'None';
  final TextEditingController notesController = TextEditingController();

  // ✅ ميزة القياس التلقائي
  Timer? _autoTimer;
  Timer? _countdownTimer;
  bool autoMeasureEnabled = false;
  int _nextMeasureCountdown = 900; // 15 دقيقة

  late AnimationController _pulseController;

  // الثيم الموحد
  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color webBg = const Color(0xFFF0F4F3);
  final Color darkTeal = const Color(0xFF004D40);

  // الـ UUIDs من الصورة المرفقة
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String TX_UUID      = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String RX_UUID      = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";

  final List<Map<String, String>> symptomsList = [
    {'en': 'None', 'ar': 'لا يوجد'},
    {'en': 'Headache', 'ar': 'صداع'},
    {'en': 'Dizziness', 'ar': 'دوخة'},
    {'en': 'Fatigue', 'ar': 'تعب'},
    {'en': 'Chest Pain', 'ar': 'ألم في الصدر'},
    {'en': 'Shortness of Breath', 'ar': 'ضيق تنفس'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000)
    )..repeat(reverse: true);

    // بدء القياس تلقائياً عند الدخول للشاشة إذا كان هناك جهاز متصل
    _checkDeviceAndStart();
  }

  void _checkDeviceAndStart() async {
    var connected = await FlutterBluePlus.connectedDevices;
    if (connected.isNotEmpty) {
      _startLiveMeasurement();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    notesController.dispose();
    _autoTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- دالة القياس الأساسية ---
  void _startLiveMeasurement() async {
    bool isArabic = context.locale.languageCode == 'ar';

    // دعم الويب (محاكاة)
    if (kIsWeb) {
      setState(() { isMeasuring = true; bpValue = "--/--"; hrValue = "--"; spo2Value = "--"; });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() {
        isMeasuring = false; currentSystolic = 120; currentDiastolic = 80;
        currentHeartRate = 72; bpValue = "120/80"; hrValue = "72"; spo2Value = "99";
      });
      return;
    }

    // التحقق من الاتصال (للموبايل)
    var connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isArabic ? "يرجى ربط السوار الذكي أولاً" : "Please connect your Smart Band first"),
        backgroundColor: Colors.orange,
      ));
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BluetoothScanScreen()));
      return;
    }

    BluetoothDevice device = connectedDevices.first;
    setState(() { isMeasuring = true; bpValue = "--/--"; hrValue = "--"; spo2Value = "--"; });

    try {
      List<BluetoothService> services = await device.discoverServices();
      BluetoothService? bpService;
      for (var s in services) {
        if (s.serviceUuid.toString().toLowerCase() == SERVICE_UUID) {
          bpService = s;
          break;
        }
      }
      if (bpService == null) throw Exception("BP Service not found");

      BluetoothCharacteristic? txChar;
      BluetoothCharacteristic? rxChar;
      for (var c in bpService.characteristics) {
        String uuid = c.characteristicUuid.toString().toLowerCase();
        if (uuid == TX_UUID) txChar = c;
        if (uuid == RX_UUID) rxChar = c;
      }
      
      if (txChar == null || rxChar == null) throw Exception("Characteristics not found");

      await txChar.setNotifyValue(true);
      
      // الاستماع للبيانات الحقيقية القادمة من ESP32
      txChar.onValueReceived.listen((value) {
        String jsonString = String.fromCharCodes(value);
        print("📥 الحساس أرسل: $jsonString");
  void _handleEspMessage(String json) {
  print("🔍 جاري فحص البيانات القادمة: $json"); // سطر مهم جداً للتأكد من وصول البيانات للـ Console
  
  try {
    // التحقق من أن النص يحتوي على نتائج الضغط
    if (json.contains('BP_RESULT')) {
      // استخدام البحث عن الأرقام مباشرة لتجنب أخطاء صيغة الـ JSON
      final sysMatch = RegExp(r'"sys":\s*([\d.]+)').firstMatch(json);
      final diaMatch = RegExp(r'"dia":\s*([\d.]+)').firstMatch(json);
      final hrMatch = RegExp(r'"hr":\s*([\d.]+)').firstMatch(json);
      final spo2Match = RegExp(r'"spo2":\s*([\d.]+)').firstMatch(json);

      if (sysMatch != null && diaMatch != null) {
        double sys = double.parse(sysMatch.group(1)!);
        double dia = double.parse(diaMatch.group(1)!);
        double hr = hrMatch != null ? double.parse(hrMatch.group(1)!) : 0;
        double spo2 = spo2Match != null ? double.parse(spo2Match.group(1)!) : 0;

        if (mounted) {
          setState(() {
            isMeasuring = false;
            currentSystolic = sys;
            currentDiastolic = dia;
            currentHeartRate = hr.toInt();
            bpValue = "${sys.toInt()}/${dia.toInt()}";
            hrValue = hr.toInt().toString();
            spo2Value = spo2.toInt().toString();
          });
          print("✅ تم تحديث الواجهة بالقيم الحقيقية: $bpValue");
        }
      }
    } else if (json.contains('PROGRESS')) {
       print("📊 الحساس يقيس الآن... جاري التقدم");
    }
  } catch (e) {
    print("❌ خطأ في تحليل بيانات الحساس: $e");
  }
}
      });

      await Future.delayed(const Duration(milliseconds: 500));
      // إرسال أمر البدء للسوار
      await rxChar.write("START".codeUnits, withoutResponse: false);
      print("📤 تم إرسال أمر START للسوار");

    } catch (e) {
      print("❌ BLE Error: $e");
      if (mounted) {
        setState(() { isMeasuring = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isArabic ? "خطأ في الاتصال بالحساس" : "Sensor connection error"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _handleEspMessage(String json) {
    try {
      if (json.contains('"type":"BP_RESULT"')) {
        // استخراج القيم باستخدام RegExp لضمان الدقة
        double sys  = double.parse(RegExp(r'"sys":([\d.]+)').firstMatch(json)!.group(1)!);
        double dia  = double.parse(RegExp(r'"dia":([\d.]+)').firstMatch(json)!.group(1)!);
        double hr   = double.parse(RegExp(r'"hr":([\d.]+)').firstMatch(json)!.group(1)!);
        double spo2 = double.parse(RegExp(r'"spo2":([\d.]+)').firstMatch(json)!.group(1)!);

        if (mounted) {
          setState(() {
            isMeasuring      = false;
            currentSystolic  = sys;
            currentDiastolic = dia;
            currentHeartRate = hr.toInt();
            bpValue          = "${sys.toInt()}/${dia.toInt()}";
            hrValue          = hr.toInt().toString();
            spo2Value        = spo2.toInt().toString();
          });
        }
      } else if (json.contains('"type":"ERROR"')) {
        if (mounted) {
          setState(() { isMeasuring = false; });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("فشل القياس - يرجى إعادة وضع الإصبع بشكل صحيح"),
            backgroundColor: Colors.orange,
          ));
        }
      }
    } catch (e) {
      print("❌ Parsing Error: $e");
    }
  }

  // --- دوال التحكم بالقياس التلقائي ---
  void _toggleAutoMeasure(bool value) {
    setState(() => autoMeasureEnabled = value);
    if (value) {
      _startAutoMeasureCycle();
    } else {
      _stopAutoMeasureCycle();
    }
  }

  void _startAutoMeasureCycle() {
    setState(() => _nextMeasureCountdown = 900);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_nextMeasureCountdown > 0) {
          _nextMeasureCountdown--;
        } else {
          _nextMeasureCountdown = 900;
        }
      });
    });

    _autoTimer = Timer.periodic(const Duration(minutes: 15), (t) {
      if (!mounted) { t.cancel(); return; }
      _startLiveMeasurement();
    });
  }

  void _stopAutoMeasureCycle() {
    _autoTimer?.cancel();
    _countdownTimer?.cancel();
  }

  String _formatCountdown(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _saveAndGoToHistory() {
    if (currentSystolic == 0) return;

    Map<String, dynamic> newRecord = {
      'date': DateTime.now().toString().split(' ')[0],
      'time': DateFormat('hh:mm a').format(DateTime.now()),
      'bp': bpValue,
      'hr': hrValue,
      'spo2': spo2Value,
      'symptoms': selectedSymptom,
      'notes': notesController.text.isEmpty ? "Routine Check" : notesController.text,
      'status': (currentSystolic > 135) ? 'High' : 'Normal',
    };

    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          userName: widget.userName,
          newRecord: newRecord
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: webBg,
      drawer: isMobile ? _buildWebSidebar(context, isArabic) : null,
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
            label: Text(isArabic ? "English" : "العربية", style: const TextStyle(color: Color(0xFF1E8E7E), fontWeight: FontWeight.bold)),
            onPressed: () => context.setLocale(isArabic ? const Locale('en') : const Locale('ar')),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) _buildWebSidebar(context, isArabic),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight, radius: 1.3,
                  colors: [Colors.white, webBg, const Color(0xFFD1E8E2)],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWebHeader(isArabic, isMobile),
                    const SizedBox(height: 25),
                    _buildAutoMeasureCard(isArabic),
                    const SizedBox(height: 25),
                    if (isMobile) ...[
                      _buildMeasurementStatusCard(isArabic),
                      const SizedBox(height: 20),
                      _buildResultsGrid(isArabic, isMobile),
                      const SizedBox(height: 20),
                      _buildSymptomsAndNotesFields(isArabic),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: _buildMeasurementStatusCard(isArabic)),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 2, 
                            child: Column(
                              children: [
                                _buildResultsGrid(isArabic, isMobile),
                                const SizedBox(height: 30),
                                _buildSymptomsAndNotesFields(isArabic),
                              ],
                            )
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                    if (!isMeasuring && currentSystolic > 0) 
                      Column(
                        children: [
                          Center(child: _buildAIAnalysisButton(isArabic, isMobile)),
                          const SizedBox(height: 15),
                          Center(
                            child: SizedBox(
                              width: isMobile ? double.infinity : 450,
                              height: 55,
                              child: OutlinedButton.icon(
                                onPressed: _saveAndGoToHistory,
                                icon: const Icon(Icons.save_as_outlined),
                                label: Text(isArabic ? "حفظ القراءة في السجل" : "SAVE TO MEDICAL RECORDS"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: webPrimary,
                                  side: BorderSide(color: webPrimary, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- الأجزاء البصرية (Widgets) ---

  Widget _buildAutoMeasureCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: autoMeasureEnabled ? webPrimary.withOpacity(0.4) : Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: autoMeasureEnabled ? webPrimary : Colors.grey, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isArabic ? "القياس التلقائي (15 دقيقة)" : "Auto-Measure (15 min)", style: TextStyle(fontWeight: FontWeight.bold, color: darkTeal)),
                Text(
                  autoMeasureEnabled 
                    ? (isArabic ? "القياس القادم: ${_formatCountdown(_nextMeasureCountdown)}" : "Next: ${_formatCountdown(_nextMeasureCountdown)}")
                    : (isArabic ? "تفعيل الجدولة التلقائية" : "Enable scheduled readings"),
                  style: TextStyle(color: autoMeasureEnabled ? webPrimary : Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(value: autoMeasureEnabled, activeColor: webPrimary, onChanged: _toggleAutoMeasure),
        ],
      ),
    );
  }

  Widget _buildMeasurementStatusCard(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          Text(isArabic ? "حالة الحساس" : "SENSOR STATUS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: webPrimary, letterSpacing: 2)),
          const SizedBox(height: 30),
          isMeasuring 
            ? ScaleTransition(
                scale: Tween(begin: 0.85, end: 1.15).animate(_pulseController),
                child: Icon(Icons.favorite, color: Colors.red.shade400, size: 80))
            : Icon(Icons.watch_rounded, color: webPrimary, size: 80),
          const SizedBox(height: 30),
          Text(isMeasuring ? (isArabic ? "جاري القياس..." : "MEASURING...") : (isArabic ? "جاهز للمسح" : "READY TO SCAN"), 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isMeasuring ? Colors.red.shade400 : darkTeal)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: isMeasuring ? null : _startLiveMeasurement,
              style: ElevatedButton.styleFrom(backgroundColor: webPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: Text(isArabic ? "بدء القياس الآن" : "MEASURE NOW", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(bool isArabic, bool isMobile) {
    return Column(
      children: [
        if (isMobile) ...[
          _buildResultCard(isArabic ? "ضغط الدم" : "BLOOD PRESSURE", bpValue, Icons.speed, Colors.teal, "mmHg", isFullWidth: true),
          const SizedBox(height: 15),
          _buildResultCard(isArabic ? "نبض القلب" : "HEART RATE", hrValue, Icons.favorite, Colors.redAccent, "BPM", isFullWidth: true),
        ] else
          Row(
            children: [
              _buildResultCard(isArabic ? "ضغط الدم" : "BLOOD PRESSURE", bpValue, Icons.speed, Colors.teal, "mmHg"),
              const SizedBox(width: 20),
              _buildResultCard(isArabic ? "نبض القلب" : "HEART RATE", hrValue, Icons.favorite, Colors.redAccent, "BPM"),
            ],
          ),
        const SizedBox(height: 20),
        _buildResultCard(isArabic ? "تشبع الأكسجين" : "OXYGEN SATURATION", spo2Value, Icons.air, Colors.blueAccent, "%", isFullWidth: true),
      ],
    );
  }

  Widget _buildResultCard(String title, String value, IconData icon, Color color, String unit, {bool isFullWidth = false}) {
    Widget card = Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 15),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 10)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: darkTeal)),
                    const SizedBox(width: 4),
                    Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }

  Widget _buildSymptomsAndNotesFields(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(30)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isArabic ? "الحالة الشعورية والأعراض" : "SYMPTOMS & FEELINGS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: webPrimary, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedSymptom,
            decoration: InputDecoration(labelText: isArabic ? 'اختر العرض الحالي' : 'Select Symptom', prefixIcon: Icon(Icons.sick_outlined, color: webPrimary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
            items: symptomsList.map((s) => DropdownMenuItem(value: s['en'], child: Text(isArabic ? s['ar']! : s['en']!))).toList(),
            onChanged: (val) => setState(() => selectedSymptom = val!),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(labelText: isArabic ? 'ملاحظات إضافية' : 'Notes', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisButton(bool isArabic, bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 450, height: 65,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIAnalysisScreen(bp: bpValue, hr: hrValue, spo2: spo2Value, diseases: widget.userChronicDiseases))),
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: Text(isArabic ? "تحليل النتائج بالذكاء الاصطناعي" : "AI ANALYSIS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: darkTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  Widget _buildWebSidebar(BuildContext context, bool isArabic) {
    return Container(
      width: 260, color: darkTeal,
      child: Column(
        children: [
          const SizedBox(height: 50),
          Image.asset(
            'assets/logo.jpg', 
            height: 60, 
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.health_and_safety, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 40),
          _sidebarItem(Icons.dashboard, isArabic ? "الرئيسية" : "Dashboard", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)))),
          _sidebarItem(Icons.add_chart, isArabic ? "قياس جديد" : "New Measurement", true, () {}),
          _sidebarItem(Icons.history, isArabic ? "السجلات" : "History", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HistoryScreen(userName: widget.userName)))),
          _sidebarItem(Icons.settings, isArabic ? "الإعدادات" : "Settings", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsScreen(userName: widget.userName)))),
          const Spacer(),
          _sidebarItem(Icons.logout, isArabic ? "خروج" : "Logout", false, () => Navigator.pop(context)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      selected: isActive,
      onTap: onTap,
    );
  }

  Widget _buildWebHeader(bool isArabic, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isArabic ? "مركز القياس الذكي" : "Smart Measurement Hub", style: TextStyle(fontSize: isMobile ? 24 : 32, fontWeight: FontWeight.bold, color: darkTeal)),
        Text(isArabic ? "حالة النظام: متصل" : "System Status: Connected", style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}