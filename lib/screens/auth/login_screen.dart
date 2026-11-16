import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../widgets/habitz_widgets.dart';
import '../home/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = true;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // SUBMIT
  // ==========================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // TODO: ganti dengan proses autentikasi / database kamu yang asli.
    // Di sini sesi hanya disimpan lokal agar AuthGate mengenali login.
    final prefs = await SharedPreferences.getInstance();
    final email = _emailController.text.trim();

    await prefs.setBool('is_logged_in', true);
    await prefs.setInt('user_id', 1);
    await prefs.setString('user_email', email);

    if (_isRegister) {
      await prefs.setString('user_name', _nameController.text.trim());
    } else if ((prefs.getString('user_name') ?? '').isEmpty) {
      // Saat masuk tanpa nama tersimpan, pakai bagian depan e-mail.
      await prefs.setString('user_name', email.split('@').first);
    }

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  void _setMode(bool register) {
    if (_isRegister == register) return;
    setState(() => _isRegister = register);
  }

  // ==========================================
  // STYLE
  // ==========================================

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIcon: Icon(icon, size: 21, color: AppColors.purple),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF6F3FC),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppColors.purple, 1.6),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  // ==========================================
  // UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: HabitzBackground(
        child: Stack(
          children: [
            // DEKORASI LATAR
            Positioned(
              top: -70,
              right: -50,
              child: _orb(210, AppColors.purple.withValues(alpha: 0.16)),
            ),
            Positioned(
              top: 150,
              left: -80,
              child: _orb(170, AppColors.pink.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -90,
              right: -40,
              child: _orb(240, AppColors.purpleSoft.withValues(alpha: 0.55)),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 28 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBrand(),
                        const SizedBox(height: 26),
                        _buildCard(),
                        const SizedBox(height: 18),
                        const Text(
                          'Berita luar angkasa terbaru, di genggamanmu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  // ==========================================
  // BRAND (LOGO + NAMA APP)
  // ==========================================

  Widget _buildBrand() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          'SpaceNews Explorer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // KARTU FORM
  // ==========================================

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.16),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModeToggle(),

            const SizedBox(height: 22),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(_isRegister),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRegister ? 'Buat akunmu' : 'Selamat datang kembali',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isRegister
                        ? 'Mulai jelajahi berita luar angkasa.'
                        : 'Senang melihatmu lagi. Lanjutkan penjelajahanmu.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FIELD NAMA (hanya saat daftar, dengan animasi)
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _isRegister
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        decoration: _decoration(
                          'Nama lengkap',
                          Icons.person_outline_rounded,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama wajib diisi'
                            : null,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                'Alamat e-mail',
                Icons.mail_outline_rounded,
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'E-mail wajib diisi';
                if (!value.contains('@')) return 'E-mail tidak valid';
                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: _decoration(
                'Kata sandi',
                Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.secondaryText,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
            ),

            const SizedBox(height: 22),

            _buildSubmitButton(),

            const SizedBox(height: 6),

            Center(
              child: TextButton(
                onPressed: () => _setMode(!_isRegister),
                child: Text.rich(
                  TextSpan(
                    text: _isRegister
                        ? 'Sudah punya akun? '
                        : 'Belum punya akun? ',
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: _isRegister ? 'Masuk' : 'Daftar',
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w800,
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
    );
  }

  // ==========================================
  // TOGGLE DAFTAR / MASUK
  // ==========================================

  Widget _buildModeToggle() {
    Widget segment(String label, bool register) {
      final selected = _isRegister == register;

      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _setMode(register),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: selected ? AppColors.purple : AppColors.secondaryText,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [segment('Daftar', true), segment('Masuk', false)]),
    );
  }

  // ==========================================
  // TOMBOL GRADIENT
  // ==========================================

  Widget _buildSubmitButton() {
    final radius = BorderRadius.circular(18);

    return Opacity(
      opacity: _loading ? 0.75 : 1,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.purple, AppColors.purpleDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.38),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: _loading ? null : _submit,
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isRegister ? 'Ayo mulai!' : 'Masuk',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
