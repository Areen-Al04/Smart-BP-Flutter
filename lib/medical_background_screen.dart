import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'measurement_screen.dart';
import 'responsive.dart';

class MedicalBackgroundScreen extends StatefulWidget {
  final String userName;
  const MedicalBackgroundScreen({super.key, required this.userName});

  @override
  State<MedicalBackgroundScreen> createState() => _MedicalBackgroundScreenState();
}

class _MedicalBackgroundScreenState extends State<MedicalBackgroundScreen> {
  final medsController = TextEditingController();
  final otherDiseasesController = TextEditingController();

  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);

  bool takesMedications = false;
  List<String> selectedDiseases = [];

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F3),
      body: Center(
        child: SingleChildScrollView(
          padding: r.pagePadding,
          child: Container(
            // ✅ عرض متغير حسب الشاشة بدل 700 ثابت
            width: r.cardMaxWidth,
            padding: r.cardPadding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(r.isMobile ? 24 : 40),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isArabic, r),
                const SizedBox(height: 40),
                _buildSectionTitle(isArabic ? "الأدوية الحالية" : "Current Medications", Icons.medication_outlined),
                const SizedBox(height: 15),
                _buildMedicationToggle(isArabic),
                if (takesMedications) ...[
                  const SizedBox(height: 15),
                  _buildTextField(medsController, isArabic ? "أدخل أسماء الأدوية..." : "Enter medication names...", 3),
                ],
                const SizedBox(height: 40),
                _buildSectionTitle(isArabic ? "التاريخ الطبي" : "Medical Background", Icons.history_edu),
                const SizedBox(height: 15),
                _buildDiseaseChips(isArabic),
                const SizedBox(height: 15),
                _buildTextField(otherDiseasesController, isArabic ? "أمراض أخرى أو ملاحظات..." : "Other diseases or notes...", 2),
                const SizedBox(height: 60),
                _buildFinishButton(isArabic, r),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isArabic, AppResponsive r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isArabic ? "التاريخ الطبي" : "Medical Background",
            style: TextStyle(fontSize: r.subtitleFontSize, fontWeight: FontWeight.bold, color: darkTeal)),
        Text(isArabic ? "الخطوة 2 من 3: الحالة الصحية والأدوية" : "Step 2 of 3: Health Status & Medications",
            style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildMedicationToggle(bool isArabic) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      children: [
        Text(isArabic ? "هل تتناول أدوية حالياً؟" : "Do you take medications?"),
        Switch(
          value: takesMedications,
          activeColor: webPrimary,
          onChanged: (val) => setState(() => takesMedications = val),
        ),
        Text(
          takesMedications ? (isArabic ? "نعم" : "Yes") : (isArabic ? "لا" : "No"),
          style: TextStyle(fontWeight: FontWeight.bold, color: takesMedications ? webPrimary : Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: webPrimary, size: 20),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkTeal)),
      ],
    );
  }

  Widget _buildDiseaseChips(bool isArabic) {
    List<String> diseases = isArabic
        ? ["ضغط الدم", "السكري", "أمراض القلب", "الربو", "لا يوجد"]
        : ["Blood Pressure", "Diabetes", "Heart Disease", "Asthma", "None"];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: diseases.map((disease) {
        bool isSelected = selectedDiseases.contains(disease);
        return FilterChip(
          label: Text(disease),
          selected: isSelected,
          onSelected: (val) => setState(() {
            if (val) selectedDiseases.add(disease);
            else selectedDiseases.remove(disease);
          }),
          selectedColor: webPrimary.withOpacity(0.2),
          checkmarkColor: webPrimary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }

  Widget _buildFinishButton(bool isArabic, AppResponsive r) {
    return Center(
      child: SizedBox(
        // ✅ عرض الزر متغير حسب الشاشة
        width: r.isMobile ? double.infinity : 350,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MeasurementScreen(userName: widget.userName)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkTeal,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
          ),
          child: Text(
            isArabic ? "إكمال إلى القياس" : "PROCEED TO MEASUREMENT",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
