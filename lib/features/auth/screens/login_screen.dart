import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;

  final _emailController = TextEditingController(text: 'alex.kusuma@chronos.io');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Alex Kusuma');

  @override
  void dispose() {
    _emailController.disposenatural();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      SnackBarHelper.showError(context, 'Masukkan format email yang valid.');
      return;
    }
    if (password.length < 6) {
      SnackBarHelper.showError(context, 'Kata sandi minimal 6 karakter.');
      return;
    }

    final authProvider = context.read<AuthProvider>();

    bool success = false;
    if (_isRegisterMode) {
      if (name.isEmpty) {
        SnackBarHelper.showError(context, 'Nama lengkap wajib diisi.');
        return;
      }
      success = await authProvider.register(email: email, password: password, name: name);
    } else {
      success = await authProvider.login(email: email, password: password);
    }

    if (!mounted) return;

    if (success) {
      SnackBarHelper.showSuccess(
        context,
        _isRegisterMode ? 'Akun berhasil didaftarkan! Selamat datang.' : 'Berhasil masuk ke Chronos OS.',
      );
    } else {
      SnackBarHelper.showError(
        context,
        authProvider.errorMessage ?? 'Autentikasi gagal. Periksa koneksi Anda.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Branding & Hero
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'KINETIC FOCUS OS',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onPrimaryFixed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isRegisterMode ? 'Buat Akun Chronos' : 'Selamat Datang di Chronos',
                  style: AppTypography.headlineLg.copyWith(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Kelola tugas harian dan tracking timeline pengerjaan dengan arsitektur offline-first.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Mode Selector: Segmented Pill Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegisterMode = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isRegisterMode ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: !_isRegisterMode
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 18,
                                  color: !_isRegisterMode ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Masuk',
                                  style: AppTypography.labelMd.copyWith(
                                    color: !_isRegisterMode ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isRegisterMode = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isRegisterMode ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: _isRegisterMode
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_rounded,
                                  size: 18,
                                  color: _isRegisterMode ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Daftar',
                                  style: AppTypography.labelMd.copyWith(
                                    color: _isRegisterMode ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main Form Card Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineHairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isRegisterMode) ...[
                        AppTextField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          hintText: 'e.g. Alex Kusuma',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        controller: _emailController,
                        label: 'Email Kerja',
                        hintText: 'nama@perusahaan.com',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Kata Sandi',
                        hintText: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (v) => setState(() => _rememberMe = v ?? true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ingat Saya',
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              SnackBarHelper.showInfo(context, 'Tautan reset dikirim ke email demo Anda.');
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                            child: Text(
                              'Lupa Sandi?',
                              style: AppTypography.labelSm.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: _isRegisterMode ? 'Daftar Akun Baru' : 'Masuk ke Workspace',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Offline-First Demo Access Button
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthProvider>().login(
                          email: 'alex.kusuma@chronos.io',
                          password: 'demo_password',
                        );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
                  label: Text(
                    'Masuk Cepat Mode Offline (Demo Data)',
                    style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryFixedDim),
                    backgroundColor: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on TextEditingController {
  void disposenatural() {}
}
