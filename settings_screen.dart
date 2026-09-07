import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home_screen.dart';
import 'measurement_screen.dart';
import 'history_screen.dart';
import 'ai_screen.dart';
import 'patient_details_screen.dart';
import 'bluetooth_scan_screen.dart';
import 'responsive.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  const SettingsScreen({super.key, this.userName = "User"});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool aiReminders = true;

  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);
  final Color webBg = const Color(0xFFF0F4F3);

  @override
  Widget build(BuildContext context) {
    bool isArabic = context.locale.languageCode == 'ar';
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: webBg,
      // ✅ Drawer للموبايل
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
              title: Text(isArabic ? "الإعدادات" : "Settings",
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
            child: SingleChildScrollView(
              padding: r.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r.showFixedSidebar)
                    Text(isArabic ? "الإعدادات" : "Settings",
                        style: TextStyle(fontSize: r.titleFontSize, fontWeight: FontWeight.bold, color: darkTeal)),
                  if (r.showFixedSidebar) const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.language, color: webPrimary),
                          title: Text(isArabic ? "لغة التطبيق" : "App Language",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isArabic ? "اختر اللغة المفضلة للواجهة" : "Select your preferred language"),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _languageOption("English", const Locale('en'), !isArabic),
                            const SizedBox(width: 10),
                            _languageOption("العربية", const Locale('ar'), isArabic),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider()),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.bluetooth_searching, color: webPrimary),
                          title: Text(isArabic ? "ربط السوار الذكي" : "Connect Smart Band",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isArabic ? "ابحث عن سوار Smart BP وقم بمزامنته" : "Scan and sync your Smart BP band"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BluetoothScanScreen())),
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(isArabic ? "تنبيهات تحليل الذكاء الاصطناعي" : "AI Analysis Reminders"),
                          subtitle: Text(isArabic ? "احصل على إشعارات حول حالتك الصحية" : "Get notified about your health trends"),
                          value: aiReminders,
                          activeColor: webPrimary,
                          onChanged: (v) => setState(() => aiReminders = v),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.person_outline, color: webPrimary),
                          title: Text(isArabic ? "معلومات الحساب" : "Profile Information",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(isArabic ? "عرض تفاصيل المريض والقياسات الحيوية" : "View patient details and vitals"),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientDetailsScreen())),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageOption(String label, Locale locale, bool isSelected) {
    return InkWell(
      onTap: () => context.setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? webPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? webPrimary : Colors.grey.shade300),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            )),
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
              errorBuilder: (c, e, s) => const Icon(Icons.monitor_heart, color: Colors.white, size: 50)),
          const SizedBox(height: 40),
          _sidebarItem(Icons.dashboard, isArabic ? "لوحة التحكم" : "Dashboard", false, context, isArabic),
          _sidebarItem(Icons.add_chart, isArabic ? "قياس جديد" : "New Measurement", false, context, isArabic),
          _sidebarItem(Icons.history, isArabic ? "السجلات" : "Medical Records", false, context, isArabic),
          _sidebarItem(Icons.settings, isArabic ? "الإعدادات" : "Settings", true, context, isArabic),
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
          if (isActive) return;
          Widget? nextScreen;
          if (label == (isArabic ? "لوحة التحكم" : "Dashboard")) {
            nextScreen = HomeScreen(userName: widget.userName);
          } else if (label == (isArabic ? "قياس جديد" : "New Measurement")) {
            nextScreen = MeasurementScreen(userName: widget.userName);
          } else if (label == (isArabic ? "السجلات" : "Medical Records")) {
            nextScreen = HistoryScreen(userName: widget.userName);
          } else if (label == (isArabic ? "خروج" : "Logout")) {
            Navigator.pop(context);
            return;
          }
          if (nextScreen != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextScreen!));
          }
        },
      ),
    );
  }
}
