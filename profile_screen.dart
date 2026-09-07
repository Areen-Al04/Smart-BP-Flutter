import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'medical_background_screen.dart';
import 'responsive.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final phoneController = TextEditingController();
  final medsController = TextEditingController();

  String selectedGender = "Female";
  List<String> selectedDiseases = ["Heart Disease"];

  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);
  final Color webBg = const Color(0xFFF0F4F3);

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    phoneController.dispose();
    medsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    final r = AppResponsive(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [Colors.white, const Color(0xFFD1E8E2), webBg],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                // ✅ padding متغير حسب الشاشة
                padding: EdgeInsets.symmetric(
                  vertical: r.isMobile ? 30 : 80,
                  horizontal: r.isMobile ? 16 : 20,
                ),
                child: Container(
                  // ✅ عرض متغير بدل 900 ثابت
                  width: r.cardMaxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(r.isMobile ? 24 : 40),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 20)),
                      const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-5, -5)),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Padding(
                    // ✅ padding داخلي متغير
                    padding: r.cardPadding,
                    child: Column(
                      children: [
                        _buildHeader(isArabic, r),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
                        ),
                        _buildSectionTitle(isArabic ? "المعلومات الشخصية" : "Personal Information", Icons.badge_outlined),
                        const SizedBox(height: 20),
                        // ✅ موبايل = عمود، ديسكتوب = صف
                        if (r.isMobile) ...[
                          _buildWebField(isArabic ? "الاسم الكامل" : "Full Name", nameController, isArabic ? "أدخل اسمك هنا" : "Enter your name", Icons.person_outline),
                          const SizedBox(height: 16),
                          _buildWebField(isArabic ? "رقم الهاتف" : "Phone Number", phoneController, "+962 7XXXXXXXX", Icons.phone_iphone_outlined),
                          const SizedBox(height: 16),
                          _buildWebField(isArabic ? "العمر" : "Age", ageController, "age", Icons.cake_outlined, isNum: true),
                          const SizedBox(height: 16),
                          _buildGenderPicker(isArabic),
                        ] else ...[
                          _buildWebRow([
                            _buildWebField(isArabic ? "الاسم الكامل" : "Full Name", nameController, isArabic ? "أدخل اسمك هنا" : "Enter your name", Icons.person_outline),
                            _buildWebField(isArabic ? "رقم الهاتف" : "Phone Number", phoneController, "+962 7XXXXXXXX", Icons.phone_iphone_outlined),
                          ]),
                          const SizedBox(height: 25),
                          _buildWebRow([
                            _buildWebField(isArabic ? "العمر" : "Age", ageController, "age", Icons.cake_outlined, isNum: true),
                            _buildGenderPicker(isArabic),
                          ]),
                        ],
                        SizedBox(height: r.isMobile ? 30 : 50),
                        _buildSectionTitle(isArabic ? "تكوين الجسم" : "Body Composition", Icons.monitor_weight_outlined),
                        const SizedBox(height: 20),
                        if (r.isMobile) ...[
                          _buildWebField(isArabic ? "الطول (سم)" : "Height (cm)", heightController, "height", Icons.straighten, isNum: true),
                          const SizedBox(height: 16),
                          _buildWebField(isArabic ? "الوزن (كغم)" : "Weight (kg)", weightController, "weight", Icons.fitness_center, isNum: true),
                        ] else
                          _buildWebRow([
                            _buildWebField(isArabic ? "الطول (سم)" : "Height (cm)", heightController, "height", Icons.straighten, isNum: true),
                            _buildWebField(isArabic ? "الوزن (كغم)" : "Weight (kg)", weightController, "weight", Icons.fitness_center, isNum: true),
                          ]),
                        SizedBox(height: r.isMobile ? 40 : 60),
                        _buildFireNextButton(isArabic, r),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: TextButton.icon(
              onPressed: () => context.setLocale(isArabic ? const Locale('en') : const Locale('ar')),
              icon: const Icon(Icons.language, color: Color(0xFF004D40), size: 20),
              label: Text(isArabic ? "English" : "العربية",
                  style: const TextStyle(color: Color(0xFF004D40), fontWeight: FontWeight.bold, fontSize: 14)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isArabic, AppResponsive r) {
    if (r.isMobile) {
      // موبايل: عمودي
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: webPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset('assets/logoB.jpg', height: 60,
                errorBuilder: (c, e, s) => Icon(Icons.favorite, size: 45, color: webPrimary)),
          ),
          const SizedBox(height: 15),
          Text(isArabic ? "إنشاء ملف المريض" : "Create Patient Profile",
              style: TextStyle(fontSize: r.subtitleFontSize, fontWeight: FontWeight.bold, color: darkTeal),
              textAlign: TextAlign.center),
          Text(isArabic ? "الخطوة 1 من 3" : "Step 1 of 3: Medical Setup",
              style: const TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        ],
      );
    }
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: webPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Image.asset('assets/logoB.jpg', height: 70,
              errorBuilder: (c, e, s) => Icon(Icons.favorite, size: 50, color: webPrimary)),
        ),
        const SizedBox(width: 25),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? "إنشاء ملف المريض" : "Create Patient Profile",
                style: TextStyle(fontSize: r.subtitleFontSize, fontWeight: FontWeight.bold, color: darkTeal, letterSpacing: -0.5)),
            Text(isArabic ? "الخطوة 1 من 3: إعداد المعلومات الطبية" : "Step 1 of 3: Medical Information Setup",
                style: const TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: webPrimary, size: 20),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkTeal)),
      ],
    );
  }

  Widget _buildWebRow(List<Widget> children) {
    return Row(
      children: children
          .map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: c)))
          .toList(),
    );
  }

  Widget _buildWebField(String label, TextEditingController ctrl, String hint, IconData icon, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: webPrimary, size: 20),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isArabic ? "الجنس" : "Gender",
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 10),
        Row(
          children: [isArabic ? 'ذكر' : 'Male', isArabic ? 'أنثى' : 'Female'].map((g) {
            bool isS = selectedGender == (isArabic ? (g == 'ذكر' ? 'Male' : 'Female') : g);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedGender = (isArabic ? (g == 'ذكر' ? 'Male' : 'Female') : g)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isS ? webPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isS ? webPrimary : Colors.black.withOpacity(0.05)),
                  ),
                  child: Center(
                    child: Text(g,
                        style: TextStyle(
                            color: isS ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFireNextButton(bool isArabic, AppResponsive r) {
    return SizedBox(
      // ✅ عرض الزر متغير
      width: r.isMobile ? double.infinity : 350,
      height: 65,
      child: ElevatedButton(
        onPressed: () async {
          String enteredName = nameController.text.trim();
          String phone = phoneController.text.trim();
          String age = ageController.text.trim();
          String height = heightController.text.trim();
          String weight = weightController.text.trim();

          if (enteredName.isEmpty || phone.isEmpty || age.isEmpty || height.isEmpty || weight.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isArabic ? "يرجى إكمال جميع البيانات المطلوبة" : "Please complete all required fields"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ));
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('patient_name', enteredName);
          await prefs.setString('patient_age', age);
          await prefs.setString('patient_height', height);
          await prefs.setString('patient_weight', weight);
          await prefs.setString('patient_gender', selectedGender);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MedicalBackgroundScreen(userName: enteredName)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [webPrimary, darkTeal]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isArabic ? "الانتقال للخطوة التالية" : "PROCEED TO NEXT STEP",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(width: 15),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
