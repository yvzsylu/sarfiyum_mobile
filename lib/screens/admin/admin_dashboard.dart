import 'package:flutter/material.dart';
import '../../widgets/custom_drawer.dart'; // Birazdan oluşturacağız

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Paneli"),
        backgroundColor: Colors.red[800], // Admin olduğu belli olsun
      ),
      drawer: const CustomDrawer(), // Ortak Menü
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.red),
            Text("Yönetici Alanı", style: TextStyle(fontSize: 24)),
            Text("Kullanıcıları buradan yönetebilirsiniz."),
          ],
        ),
      ),
    );
  }
}