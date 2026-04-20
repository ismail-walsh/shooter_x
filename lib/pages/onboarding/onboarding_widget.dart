// onboarding_widget.dart
// Replaces lib/pages/onboarding/onboarding_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';

class OnboardingWidget extends StatefulWidget {
  const OnboardingWidget({super.key});
  static const String routeName = 'Onboarding';
  static const String routePath = '/onboarding';

  @override
  State<OnboardingWidget> createState() => _OnboardingWidgetState();
}

class _OnboardingWidgetState extends State<OnboardingWidget> {
  int _slide = 0;

  static const _slides = [
    'Your new shooting companion.\nAny field. Any target.',
    'Track every shot.\nImprove every session.',
    'Connect with your club.\nCompete with the best.',
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _nextSlide);
  }

  void _nextSlide() {
    if (!mounted) return;
    setState(() => _slide = (_slide + 1) % _slides.length);
    Future.delayed(const Duration(seconds: 3), _nextSlide);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Stack(
        children: [
          // Radial green glow background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.85,
                colors: [Color(0xFF182B18), Color(0xFF0D0D0D)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Logo
                _SXLogoSVG(size: 148),
                const SizedBox(height: 18),
                // Brand text
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'Shooter',
                      style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                    ),
                    TextSpan(
                      text: 'X',
                      style: GoogleFonts.interTight(
                          color: theme.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                // Slide text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _slides[_slide],
                    key: ValueKey(_slide),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 15,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 20),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == _slide;
                    return GestureDetector(
                      onTap: () => setState(() => _slide = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? theme.primary
                              : Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                // Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 48),
                  child: Column(
                    children: [
                      _GreenButton(
                        label: 'Log In',
                        onTap: () => _showAuthSheet(context, mode: 'login'),
                      ),
                      const SizedBox(height: 12),
                      _OutlineButton(
                        label: 'Sign Up',
                        onTap: () => _showAuthSheet(context, mode: 'signup'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthSheet(BuildContext context, {required String mode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthSheet(mode: mode),
    );
  }
}

// ─── AUTH BOTTOM SHEET ────────────────────────────────────────────────────────
class _AuthSheet extends StatefulWidget {
  const _AuthSheet({required this.mode});
  final String mode;

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isLogin = widget.mode == 'login';
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isLogin ? 'Log In to ShooterX' : 'Sign Up to ShooterX',
                  style: GoogleFonts.interTight(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: Icon(Icons.close_rounded,
                        color: Colors.white.withOpacity(0.6), size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (!isLogin) ...[
              _Field(ctrl: _nameCtrl, hint: 'First name'),
              const SizedBox(height: 10),
            ],
            _Field(ctrl: _emailCtrl, hint: 'Email address',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _Field(ctrl: _passCtrl, hint: 'Password', obscure: true),
            if (isLogin) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Forgot password?',
                    style: GoogleFonts.inter(
                        color: theme.primary, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 14),
            _GreenButton(
              label: 'Continue',
              onTap: () {
                Navigator.pop(context);
                context.goNamed('HomePage');
              },
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or',
                    style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13)),
              ),
              Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
            ]),
            const SizedBox(height: 14),
            _SocialButton(
              label: '${isLogin ? 'Sign in' : 'Sign up'} with Apple',
              icon: Icons.apple_rounded,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _SocialButton(
              label: '${isLogin ? 'Sign in' : 'Sign up'} with Google',
              icon: Icons.g_mobiledata_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.ctrl, required this.hint,
      this.obscure = false, this.keyboardType});
  final TextEditingController ctrl;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      cursorColor: theme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.3), fontSize: 15),
        filled: true,
        fillColor: theme.secondaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: theme.primary.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  const _GreenButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border:
              Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: GoogleFonts.interTight(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 9),
            Text(label,
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ─── LOGO SVG ─────────────────────────────────────────────────────────────────
class _SXLogoSVG extends StatelessWidget {
  const _SXLogoSVG({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/SXLogo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
