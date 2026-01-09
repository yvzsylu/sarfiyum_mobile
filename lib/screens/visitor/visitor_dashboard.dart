import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart'; // Ortak menüyü burada da kullanabiliriz

class VisitorDashboard extends StatelessWidget {
  const VisitorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sarfiyum - Ziyaretçi"),
        backgroundColor: Colors.blueGrey, // Ziyaretçi için farklı bir renk (Opsiyonel)
        foregroundColor: Colors.white,
      ),
      drawer: const CustomDrawer(), // Menü
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.public, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              const Text(
                "Misafir Modu",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Sadece halka açık canlı fiyatları izleyebilirsiniz. İşlem yapmak için lütfen yetkili bir hesaba geçiş yapın.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}