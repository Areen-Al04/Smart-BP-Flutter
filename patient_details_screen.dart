import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, String> patientData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      patientData = {
        "Name": prefs.getString('patient_name') ?? "N/A",
        "Age": prefs.getString('patient_age') ?? "N/A",
        "Height": prefs.getString('patient_height') ?? "N/A",
        "Weight": prefs.getString('patient_weight') ?? "N/A",
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Information"),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  _infoTile("Full Name", patientData["Name"]!, Icons.person),
                  _infoTile("Age", patientData["Age"]!, Icons.cake),
                  _infoTile("Height", "${patientData["Height"]} cm", Icons.straighten),
                  _infoTile("Weight", "${patientData["Weight"]} kg", Icons.fitness_center),
                ],
              ),
            ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E8E7E)),
        title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}