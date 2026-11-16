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
  // SUBMIT / LOGIN / REGISTER
  // ==========================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Catatan:
      // Autentikasi masih menggunakan penyimpanan lokal.
      // Belum menggunakan database atau server autentikasi.

      if (_isRegister) {
        await prefs.setString('user_name', _nameController.text.trim());
      } else if ((prefs.getString('user_name') ?? '').isEmpty) {
        await prefs.setString('user_name', email.split('@').first);
      }

      await prefs.setBool('is_logged_in', true);
      await prefs.setInt('user_id', 1);
      await prefs.setString('user_email', email);

      // Password sengaja tidak disimpan sebagai SharedPreferences.

      if (!mounted) return;

      setState(() => _loading = false);

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================
  // MODE DAFTAR / MASUK
  // ==========================================

  void _setMode(bool register) {
    if (_isRegister == register) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isRegister = register;
      _formKey.currentState?.reset();
    });
  }

  // ==========================================
  // INPUT DECORATION
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(AppColors.purple, 1.6),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.6),
    );
  }

  // ==========================================
  // MAIN UI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,

      body: HabitzBackground(
        child: Stack(
          children: [
            // DEKORASI ORB

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

            // KONTEN UTAMA
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
                      ),

                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),

                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,

                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 25 * (1 - value)),
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

                                const SizedBox(height: 20),

                                const Text(
                                  'Berita luar angkasa terbaru, '
                                  'di genggamanmu.',
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DEKORASI ORB
  // ==========================================

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
  // BRAND
  // ==========================================

  Widget _buildBrand() {
    return const Column(
      children: [
        SizedBox(height: 16),

        Text(
          'SpaceNews Explorer',
          textAlign: TextAlign.center,
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
  // FORM CARD
  // ==========================================

  Widget _buildCard() {
    return Container(
      width: double.infinity,

      // Padding bawah ditambah agar footer
      // tidak terlalu dekat dengan batas kartu.
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),

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
            // TOGGLE DAFTAR / MASUK

            _buildModeToggle(),

            const SizedBox(height: 22),

            // JUDUL FORM
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
                        : 'Senang melihatmu lagi. '
                              'Lanjutkan penjelajahanmu.',

                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FIELD NAMA
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

                        validator: (value) {
                          if (!_isRegister) return null;

                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }

                          return null;
                        },
                      ),
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),

            // FIELD EMAIL
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],

              decoration: _decoration(
                'Alamat e-mail',
                Icons.mail_outline_rounded,
              ),

              validator: (value) {
                final email = value?.trim() ?? '';

                if (email.isEmpty) {
                  return 'E-mail wajib diisi';
                }

                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Format e-mail tidak valid';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            // FIELD PASSWORD
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: [
                _isRegister
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],

              onFieldSubmitted: (_) {
                if (!_loading) _submit();
              },

              decoration: _decoration(
                'Kata sandi',
                Icons.lock_outline_rounded,

                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },

                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,

                    size: 20,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kata sandi wajib diisi';
                }

                if (value.length < 6) {
                  return 'Minimal 6 karakter';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            // TOMBOL SUBMIT
            _buildSubmitButton(),

            const SizedBox(height: 12),

            // FOOTER DAFTAR / MASUK
            // Menggunakan InkWell agar area klik
            // lebih stabil dan tidak terpotong.
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),

                child: InkWell(
                  onTap: () {
                    _setMode(!_isRegister);
                  },

                  borderRadius: BorderRadius.circular(12),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),

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

          onTap: () {
            _setMode(register);
          },

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
                  : Text(
                      _isRegister ? 'Ayo mulai!' : 'Masuk',

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
