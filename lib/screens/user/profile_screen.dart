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
  // 🔥 TEMA RENGİ
  final Color _primaryColor = const Color(0xFF161A30);

  // Resimlerin olduğu kök URL
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
      backgroundColor: Colors.white,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          "PROFİLİM",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        // 🔥 1. İSTEK: AppBar (Header) Arkaplanı GRADIENT yapıldı
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_primaryColor, const Color(0xFF243B55)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent, // Gradient görünmesi için şeffaf
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : user == null
          ? Center(child: Text(provider.errorMessage ?? "Veri yüklenemedi"))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- ÜST KART ---
                  _buildProfileHeaderCard(context, provider, user),

                  const SizedBox(height: 10),

                  // --- KİŞİSEL & ADRES BİLGİLERİ ---
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
        borderRadius: BorderRadius.circular(16),
        // Modern Gölge
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 🔥 2. İSTEK: Logonun olduğu yer TEK RENK (Solid) yapıldı
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: _primaryColor, // Sadece Koyu Lacivert
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), // Kartın köşeleriyle uyumlu
                topRight: Radius.circular(16),
              ),
            ),
          ),

          // Avatar ve Buton Alanı
          Transform.translate(
            offset: const Offset(0, -50), // Yukarı kaydır
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // AVATAR
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: user.tenantLogoUrl != null
                              ? NetworkImage("$apiRoot${user.tenantLogoUrl}")
                              : null,
                          child: user.tenantLogoUrl == null
                              ? Text(
                                  user.initials,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: _primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const Spacer(),
                      // LOGO YÜKLE BUTONU
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton.icon(
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
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _primaryColor,
                                  ),
                                )
                              : Icon(
                                  Icons.upload_rounded,
                                  size: 18,
                                  color: _primaryColor,
                                ),
                          label: Text(
                            "Logo Yükle",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Colors.grey.withOpacity(0.2),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // İsim ve Kullanıcı Adı
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF161A30),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user.isUserActive)
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 22,
                              ),
                          ],
                        ),
                        Text(
                          "@${user.username}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),

                  // İstatistikler Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.calendar_month_rounded,
                        user.tenantCreatedAt != null
                            ? DateFormat(
                                'MM/yyyy',
                              ).format(user.tenantCreatedAt!)
                            : '-',
                        "Kayıt Tarihi",
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildInfoItem(
                        Icons.check_circle_rounded,
                        user.isTenantActive ? 'Aktif' : 'Pasif',
                        "Firma Durumu",
                        color: user.isTenantActive ? Colors.green : Colors.red,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade200,
                      ),
                      _buildInfoItem(
                        Icons.phone_iphone_rounded,
                        user.tenantPhoneNumber ?? '-',
                        "Telefon",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Alt Bilgi Kartı
  Widget _buildPersonalInfoCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_rounded, color: _primaryColor),
              const SizedBox(width: 10),
              Text(
                "Firma & Adres Bilgileri",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow("Firma Adı", user.tenantName ?? '-'),
          _buildDetailRow("Vergi No", user.tenantTaxNumber ?? '-'),
          _buildDetailRow("E-Posta", user.email),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.grey.shade200),
          ),
          _buildDetailRow(
            "Şehir/İlçe",
            "${user.tenantCity ?? ''} / ${user.tenantDistrict ?? ''}",
          ),
          _buildDetailRow("Tam Adres", user.tenantFullAddress ?? '-'),
        ],
      ),
    );
  }

  // Yardımcı Widget: İkonlu Bilgi
  Widget _buildInfoItem(
    IconData icon,
    String title,
    String subtitle, {
    Color? color,
  }) {
    final finalColor = color ?? const Color(0xFF161A30);
    return Column(
      children: [
        Icon(icon, color: finalColor, size: 26),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: finalColor,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // Yardımcı Widget: Satır Detay
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
