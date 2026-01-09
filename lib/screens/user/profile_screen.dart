import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Resimlerin olduğu kök URL (Environment'tan alınmalı normalde)
  final String apiRoot = "https://sarfiyum.com";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final user = provider.userProfile;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Hafif gri arka plan
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "PROFİLİM",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF161A30),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? Center(child: Text(provider.errorMessage ?? "Veri yüklenemedi"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- ÜST KART (Mavi Alan + Avatar + İsim) ---
                  _buildProfileHeaderCard(context, provider, user),

                  const SizedBox(height: 20),

                  // --- KİŞİSEL & ADRES BİLGİLERİ (Angular'daki alt component) ---
                  _buildPersonalInfoCard(user),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeaderCard(
    BuildContext context,
    ProfileProvider provider,
    dynamic user,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Mavi Arka Plan
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF222831),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          // Avatar ve Buton Alanı
          Transform.translate(
            offset: const Offset(0, -40), // Yukarı kaydır
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // AVATAR
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user.tenantLogoUrl != null
                          ? NetworkImage("$apiRoot${user.tenantLogoUrl}")
                          : null,
                      child: user.tenantLogoUrl == null
                          ? Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D1B46),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const Spacer(),
                  // LOGO YÜKLE BUTONU
                  ElevatedButton.icon(
                    onPressed: provider.isUploading
                        ? null
                        : () async {
                            bool success = await provider.uploadLogo();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Logo güncellendi"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else if (provider.errorMessage != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.errorMessage!),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: provider.isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0D1B46),
                            ),
                          )
                        : const Icon(Icons.upload, size: 18),
                    label: const Text("Logo Yükle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D1B46),
                      side: const BorderSide(color: Color(0xFF0D1B46)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İsim ve Username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (user.isUserActive)
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                Text(
                  "@${user.username}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // İstatistik Kartları (Tarih, Durum, Telefon)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tarih
                _buildInfoItem(
                  Icons.calendar_month,
                  user.tenantCreatedAt != null
                      ? DateFormat('MM/yyyy').format(user.tenantCreatedAt!)
                      : '-',
                  "Kayıt Tarihi",
                ),
                // Durum
                _buildInfoItem(
                  Icons.check_circle,
                  user.isTenantActive ? 'Aktif' : 'Pasif',
                  "Firma Durumu",
                  color: user.isTenantActive ? Colors.green : Colors.red,
                ),
                // Telefon
                _buildInfoItem(
                  Icons.phone,
                  user.tenantPhoneNumber ?? '-',
                  "İş Telefonu",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Alt Bilgi Kartı (Personal Info Component karşılığı)
  Widget _buildPersonalInfoCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Firma & Adres Bilgileri",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1B46),
            ),
          ),
          const SizedBox(height: 15),
          _buildDetailRow("Firma Adı", user.tenantName ?? '-'),
          _buildDetailRow("Vergi No", user.tenantTaxNumber ?? '-'),
          _buildDetailRow("E-Posta", user.email),
          const Divider(height: 20),
          _buildDetailRow(
            "Şehir/İlçe",
            "${user.tenantCity ?? ''} / ${user.tenantDistrict ?? ''}",
          ),
          _buildDetailRow("Tam Adres", user.tenantFullAddress ?? '-'),
        ],
      ),
    );
  }

  // Yardımcı Widget: İkonlu Bilgi (Üst Kısım için)
  Widget _buildInfoItem(
    IconData icon,
    String title,
    String subtitle, {
    Color color = const Color(0xFF0D1B46),
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  // Yardımcı Widget: Satır Detay (Alt Kısım için)
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
