import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_service.dart'; 

class BluetoothScanScreen extends StatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  State<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends State<BluetoothScanScreen> {
  final Color webPrimary = const Color(0xFF1E8E7E);

  @override
  void initState() {
    super.initState();
    // استخدام الاسم الجديد للمدير
    AppBluetoothManager.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search for Smart BP Band"),
        backgroundColor: webPrimary,
        centerTitle: true,
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: AppBluetoothManager.scanResults, // الاسم الجديد هنا أيضاً
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No devices found. Make sure Bluetooth is ON."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final result = snapshot.data![index];
              final deviceName = result.device.platformName.isEmpty 
                                 ? "Unknown Device" 
                                 : result.device.platformName;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(result.device.remoteId.toString()),
                  leading: CircleAvatar(
                    backgroundColor: webPrimary.withOpacity(0.1),
                    child: Icon(Icons.bluetooth, color: webPrimary),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: webPrimary),
                    child: const Text("Connect", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      try {
                        // 1. محاولة الاتصال بالجهاز
                        await AppBluetoothManager.connectToDevice(result.device);
                        
                        // 2. تفعيل المراقبة في الخلفية فور نجاح الاتصال
                        AppBluetoothManager.startMonitoring();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connected to $deviceName Successfully!")),
                        );
                        
                        Navigator.pop(context); // العودة بعد النجاح
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Connection Failed: $e")),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: webPrimary,
        onPressed: () => AppBluetoothManager.startScan(),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}