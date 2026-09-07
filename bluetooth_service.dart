import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart'; 
import 'main.dart'; 

class AppBluetoothManager {
  // --- الأكواد الخاصة بساعتك (UUIDs) المستخرجة من الصورة ---
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String rxCharacteristicUuid = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"; // للإرسال (Write)
  static const String txCharacteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8"; // للاستقبال (Notify)

  // --- إضافة الـ StreamController لبث البيانات الحقيقية من الساعة إلى الشاشات ---
  static final _dataController = StreamController<List<int>>.broadcast();
  static Stream<List<int>> get realTimeData => _dataController.stream;

  // --- الكود الأصلي الخاص بكِ ---
  static Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  static Future<void> startScan() async {
    if (await FlutterBluePlus.isSupported == false) return;
    
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: true,
    );
  }

  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  static Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  // --- التعديل المطور: إرسال أمر البدء وتفعيل استقبال البيانات الحقيقية ---
  static Future<void> startBloodPressureMeasurement(BluetoothDevice device) async {
    try {
      // 1. اكتشاف الخدمات داخل الساعة
      List<BluetoothService> services = await device.discoverServices();
      
      for (BluetoothService service in services) {
        // التحقق من الخدمة المطلوبة (Smart BP Service)
        if (service.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            
            // أ. البحث عن قناة الـ Write (RX) لإرسال أمر التشغيل
            if (characteristic.uuid.toString().toLowerCase() == rxCharacteristicUuid.toLowerCase()) {
              await characteristic.write([0x01]); // القيمة 0x01 لبدء الحساس
              print("تم إرسال أمر بدء القياس للساعة بنجاح.");
            }

            // ب. استقبال البيانات وتمريرها عبر الـ Stream لتحديث الواجهة
            if (characteristic.uuid.toString().toLowerCase() == txCharacteristicUuid.toLowerCase()) {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  print("وصلت قراءة حقيقية من السوار: $value");
                  // إرسال البيانات المكتشفة إلى الـ StreamController ليتم عرضها في الشاشة
                  _dataController.add(value); 
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print("خطأ أثناء إرسال أمر التشغيل أو تفعيل الاستقبال: $e");
    }
  }

  // --- نظام المراقبة الدوري بالمنطق الطبي (كما هو دون تغيير) ---

  static Timer? _periodicTimer;

  static void startMonitoring() {
    _periodicTimer?.cancel();

    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (timer) async {
      print("جاري فحص المؤشرات الحيوية تلقائياً...");
      
      double systolic = 145; 
      double diastolic = 95;

      String status = "Normal";
      String advice = "";
      bool isEmergency = false;

      if (systolic >= 140 || diastolic >= 90) {
        status = "ارتفاع في ضغط الدم";
        advice = "يرجى الراحة وتجنب التوتر. ضغطك الحالي: $systolic/$diastolic";
        isEmergency = true;
      } else if (systolic <= 90 || diastolic <= 60) {
        status = "انخفاض في ضغط الدم";
        advice = "يرجى شرب السوائل. ضغطك الحالي: $systolic/$diastolic";
        isEmergency = true;
      }

      if (isEmergency) {
        _showEmergencyNotification("تنبيه صحي ($status): $advice");
      } else {
        print("الضغط طبيعي ($systolic/$diastolic)، لا حاجة لتنبيه المستخدم.");
      }
    });
  }

  static void stopMonitoring() {
    _periodicTimer?.cancel();
  }

  static Future<void> _showEmergencyNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'smart_bp_alerts',
      'Health Alerts',
      channelDescription: 'تنبيهات المراقبة الصحية الدورية لـ Smart BP',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF1E8E7E),
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, 
      'Smart BP Alert', 
      message, 
      platformDetails,
    );
  }
}