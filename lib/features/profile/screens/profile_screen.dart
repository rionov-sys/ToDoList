import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _autoSync = true;
  bool _notifications = true;
  bool _hapticFeedback = true;
  bool _isSyncing = false;

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    await context.read<TaskProvider>().triggerManualSync();
    if (mounted) {
      setState(() => _isSyncing = false);
      SnackBarHelper.showSuccess(context, 'Database lokal tersinkronisasi sempurna dengan server.');
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Data lokal Anda tetap tersimpan dengan aman pada penyimpanan offline.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.urgent),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              SnackBarHelper.showInfo(context, 'Anda telah keluar dari akun.');
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Status Summary Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PUSAT KENDALI AKUN',
                        style: AppTypography.labelSm.copyWith(letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 2),
                      Text('Profil & Sinkronisasi', style: AppTypography.headlineSm),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tersambung',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // User Profile Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineHairline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar Initials with Gradient
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'AK',
                          style: AppTypography.headlineMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user?.name ?? 'Alex Kusuma',
                                style: AppTypography.headlineSm.copyWith(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Pro Plan',
                                  style: AppTypography.labelSm.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'alex.kusuma@chronos.io',
                            style: AppTypography.bodySm,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                user?.timezone ?? 'Asia/Jakarta (WIB • UTC+7)',
                                style: AppTypography.monoTime.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sinkronisasi & Database Lokal Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.cloud_sync_rounded, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text('Sinkronisasi & Database Lokal', style: AppTypography.headlineSm.copyWith(fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _autoSync,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Otomatis Sinkronisasi ke Cloud', style: AppTypography.bodyMd),
                      subtitle: Text('Mengunggah perubahan lokal saat terhubung online', style: AppTypography.bodySm),
                      onChanged: (v) => setState(() => _autoSync = v),
                    ),
                    const Divider(height: 16, color: AppColors.outlineHairline),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Storage Footprint Cache', style: AppTypography.bodySm),
                            Text('Isar Local DB: 4.2 MB', style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _isSyncing ? null : _manualSync,
                          icon: _isSyncing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.sync_rounded, size: 16),
                          label: Text(_isSyncing ? 'Menyinkronkan...' : 'Sinkronkan Sekarang'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerLow,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Preferensi Aplikasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.outlineHairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preferensi Chronos', style: AppTypography.labelMd),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _notifications,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Pengingat & Notifikasi Tenggat', style: AppTypography.bodyMd),
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    SwitchListTile(
                      value: _hapticFeedback,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text('Getaran Haptic (Kinetic Feedback)', style: AppTypography.bodyMd),
                      onChanged: (v) => setState(() => _hapticFeedback = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Actions
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppColors.surfaceContainerLowest,
                leading: const Icon(Icons.lock_reset_rounded, color: AppColors.onSurfaceVariant),
                title: Text('Ganti Kata Sandi', style: AppTypography.bodyMd),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => SnackBarHelper.showInfo(context, 'Fitur keamanan akun segera hadir.'),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: AppColors.urgentContainer.withOpacity(0.5),
                leading: const Icon(Icons.logout_rounded, color: AppColors.urgent),
                title: Text('Keluar dari Akun', style: AppTypography.bodyMd.copyWith(color: AppColors.urgent, fontWeight: FontWeight.bold)),
                onTap: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
