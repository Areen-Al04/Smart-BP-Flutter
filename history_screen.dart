import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:csv/csv.dart';

import 'home_screen.dart';
import 'measurement_screen.dart';
import 'settings_screen.dart';
import 'responsive.dart';

class HistoryScreen extends StatefulWidget {
  final String userName;
  final Map<String, dynamic>? newRecord;

  const HistoryScreen({super.key, required this.userName, this.newRecord});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Color webPrimary = const Color(0xFF1E8E7E);
  final Color darkTeal = const Color(0xFF004D40);
  final Color webBg = const Color(0xFFF0F4F3);

  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    try {
      final rawData = await rootBundle.loadString("assets/data/avg_data.csv");
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
      List<Map<String, dynamic>> loadedRecords = [];
      for (var i = 2; i < listData.length; i++) {
        if (listData[i].length < 8) continue;
        var trialNum = listData[i][3];
        var sysValue = listData[i][4];
        var diaValue = listData[i][5];
        var hrValue = listData[i][6];
        if (trialNum == null || trialNum.toString().isEmpty) continue;
        double sys = double.tryParse(sysValue.toString()) ?? 0;
        double dia = double.tryParse(diaValue.toString()) ?? 0;
        int hr = int.tryParse(hrValue.toString()) ?? 0;
        if (sys > 0) {
          loadedRecords.add({
            'date': 'Trial $trialNum',
            'time': '3min Break',
            'bp': "${sys.toInt()}/${dia.toInt()}",
            'hr': hr.toString(),
            'spo2': '98%',
            'status': (sys > 130) ? 'High' : 'Normal',
            'symptoms': 'None',
            'notes': 'MAX Measurement'
          });
        }
      }
      setState(() {
        records = loadedRecords;
        if (widget.newRecord != null) records.insert(0, widget.newRecord!);
      });
    } catch (e) {
      debugPrint("Error loading CSV: $e");
    }
  }

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
              title: Text(isArabic ? "السجلات الطبية" : "Medical Records",
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
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.3,
                  colors: [Colors.white, webBg, const Color(0xFFD1E8E2)],
                ),
              ),
              child: records.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: r.pagePadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWebHeader(isArabic, r),
                          const SizedBox(height: 30),
                          // ✅ تخطيط متغير: موبايل = عمود، ديسكتوب = صف
                          if (r.isMobile) ...[
                            _buildDetailedChart(isArabic),
                            const SizedBox(height: 20),
                            _buildSummaryStats(isArabic),
                          ] else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildDetailedChart(isArabic)),
                                const SizedBox(width: 30),
                                Expanded(flex: 1, child: _buildSummaryStats(isArabic)),
                              ],
                            ),
                          const SizedBox(height: 30),
                          _buildRecordsTable(isArabic),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedChart(bool isArabic) {
    List<FlSpot> spots = [];
    for (int i = 0; i < records.length && i < 7; i++) {
      double sys = double.tryParse(records[i]['bp'].split('/')[0]) ?? 120;
      spots.add(FlSpot(i.toDouble(), sys));
    }
    return Container(
      height: 300,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isArabic ? "تغيرات الضغط (Systolic)" : "PRESSURE VARIATIONS (Systolic)",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots.reversed.toList(),
                  isCurved: true,
                  color: webPrimary,
                  barWidth: 5,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: webPrimary.withOpacity(0.05)),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  String _translateSymptom(String symptom, bool isArabic) {
    if (!isArabic) return symptom;
    switch (symptom) {
      case 'None': return 'لا يوجد';
      case 'Headache': return 'صداع';
      case 'Dizziness': return 'دوخة';
      case 'Fatigue': return 'تعب';
      case 'Chest Pain': return 'ألم في الصدر';
      case 'Shortness of Breath': return 'ضيق تنفس';
      default: return symptom;
    }
  }

  Widget _buildRecordsTable(bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          columns: [
            DataColumn(label: Text(isArabic ? 'التاريخ والوقت' : 'DATE & TIME')),
            DataColumn(label: Text(isArabic ? 'ضغط الدم' : 'BP')),
            DataColumn(label: Text(isArabic ? 'النبض/الأكسجين' : 'HR/SpO2')),
            DataColumn(label: Text(isArabic ? 'الأعراض' : 'SYMPTOMS')),
            DataColumn(label: Text(isArabic ? 'الملاحظات' : 'NOTES')),
            DataColumn(label: Text(isArabic ? 'الحالة' : 'STATUS')),
          ],
          rows: records.map((r) {
            bool isHigh = r['status'] == 'High';
            bool hasSymptom = r['symptoms'] != 'None';
            return DataRow(cells: [
              DataCell(Text("${r['date']}\n${r['time']}", style: const TextStyle(fontSize: 12))),
              DataCell(Text(r['bp'], style: TextStyle(color: darkTeal, fontWeight: FontWeight.bold))),
              DataCell(Text("${r['hr']} | ${r['spo2']}")),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasSymptom ? Colors.orange.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_translateSymptom(r['symptoms'], isArabic),
                    style: TextStyle(color: hasSymptom ? Colors.orange[900] : Colors.black87, fontSize: 12)),
              )),
              DataCell(SizedBox(width: 120, child: Text(r['notes'] ?? '-', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic), overflow: TextOverflow.ellipsis))),
              DataCell(Text(isArabic ? (isHigh ? "مرتفع" : "طبيعي") : r['status'],
                  style: TextStyle(color: isHigh ? Colors.red : Colors.green, fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWebHeader(bool isArabic, AppResponsive r) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isArabic ? "سجل السجلات الطبية" : "Medical History Log",
                style: TextStyle(fontSize: r.titleFontSize, fontWeight: FontWeight.bold, color: darkTeal)),
            Text(isArabic ? "السجلات التشخيصية لـ ${widget.userName}" : "Records for ${widget.userName}",
                style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        _buildExportButton(isArabic),
      ],
    );
  }

  Widget _buildExportButton(bool isArabic) {
    return ElevatedButton.icon(
      onPressed: _exportPDF,
      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
      label: Text(isArabic ? "تصدير PDF" : "EXPORT PDF", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: webPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildSummaryStats(bool isArabic) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [webPrimary, darkTeal]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insights, color: Colors.white, size: 50),
          const SizedBox(height: 20),
          Text(isArabic ? "المتوسط الشهري" : "MONTHLY AVERAGE",
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 10),
          const Text("121/79", style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 15), child: Divider(color: Colors.white24)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 10),
            Text(isArabic ? "الحالة: مستقرة" : "STATUS: STABLE",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ],
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
          _sidebarItem(Icons.dashboard, isArabic ? "لوحة التحكم" : "Dashboard", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(userName: widget.userName)))),
          _sidebarItem(Icons.add_chart, isArabic ? "قياس جديد" : "New Measurement", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MeasurementScreen(userName: widget.userName)))),
          _sidebarItem(Icons.history, isArabic ? "السجلات" : "Medical Records", true, () {}),
          _sidebarItem(Icons.settings, isArabic ? "الإعدادات" : "Settings", false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SettingsScreen(userName: widget.userName)))),
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

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/fonts/Amiri.ttf");
    final ttf = pw.Font.ttf(fontData);
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("Medical History Report / تقرير السجل الطبي",
                style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
            pw.SizedBox(height: 10),
            pw.Text("Patient Name / اسم المريض: ${widget.userName}", style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.Text("Date / التاريخ: ${DateTime.now().toString().split(' ')[0]}", style: pw.TextStyle(font: ttf, fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
              cellHeight: 30,
              data: <List<String>>[
                <String>['Trial', 'BP', 'HR/SpO2', 'Symptoms', 'Notes', 'Status'],
                ...records.map((r) => ["${r['date']}", "${r['bp']}", "${r['hr']} | ${r['spo2']}", "${r['symptoms']}", "${r['notes'] ?? '-'}", "${r['status'] == 'High' ? 'High' : 'Normal'}"]),
              ],
            ),
            pw.Spacer(),
            pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: pw.Text("Smart BP Management System", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
          ]),
        );
      },
    ));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Medical_History_${widget.userName}');
  }
}
