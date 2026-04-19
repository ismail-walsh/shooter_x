// sx_shared_widgets.dart
// Drop into lib/components/sx_shared_widgets.dart
// Reusable components used across all ShooterX screens.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/nav/nav.dart';

// ─── BRAND LOGO TEXT ──────────────────────────────────────────────────────────
class SXBrandText extends StatelessWidget {
  const SXBrandText({super.key, this.fontSize = 22});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Shooter',
            style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'X',
            style: GoogleFonts.interTight(
              color: FlutterFlowTheme.of(context).primary,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PAGE HEADER ─────────────────────────────────────────────────────────────
class SXPageHeader extends StatelessWidget {
  const SXPageHeader({
    super.key,
    required this.title,
    this.actions = const [],
  });
  final Widget title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title,
          Row(children: actions, mainAxisSize: MainAxisSize.min),
        ],
      ),
    );
  }
}

// ─── BACK HEADER ─────────────────────────────────────────────────────────────
class SXBackHeader extends StatelessWidget {
  const SXBackHeader({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      color: theme.primaryBackground,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chevron_left_rounded,
                      color: theme.primary, size: 24),
                  Text('Back',
                      style: GoogleFonts.inter(
                          color: theme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          Text(title,
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ),
    );
  }
}

// ─── SECTION TITLE ────────────────────────────────────────────────────────────
class SXSectionTitle extends StatelessWidget {
  const SXSectionTitle({
    super.key,
    required this.label,
    this.actionLabel,
    this.onAction,
  });
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.interTight(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!,
                  style: GoogleFonts.inter(
                      color: FlutterFlowTheme.of(context).primary,
                      fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

// ─── AVATAR BUTTON ────────────────────────────────────────────────────────────
class SXAvatarButton extends StatelessWidget {
  const SXAvatarButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person_rounded,
            color: Colors.white.withOpacity(0.5), size: 18),
      ),
    );
  }
}

// ─── ICON BUTTON CIRCLE ───────────────────────────────────────────────────────
class SXIconButton extends StatelessWidget {
  const SXIconButton({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.5), size: 18),
      ),
    );
  }
}

// ─── GREEN BUTTON ─────────────────────────────────────────────────────────────
class SXGreenButton extends StatelessWidget {
  const SXGreenButton({
    super.key,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.height = 50.0,
  });
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final green = FlutterFlowTheme.of(context).primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : green,
          borderRadius: BorderRadius.circular(13),
          border: outlined ? Border.all(color: green) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.interTight(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── OUTLINE BUTTON WITH ICON ─────────────────────────────────────────────────
class SXOutlineButton extends StatelessWidget {
  const SXOutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });
  final String label;
  final Widget? icon;
  final VoidCallback? onTap;

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
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 9)],
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

// ─── DIVIDER WITH OR ─────────────────────────────────────────────────────────
class SXOrDivider extends StatelessWidget {
  const SXOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: Colors.white.withOpacity(0.1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or',
              style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ),
        Expanded(
            child: Divider(
                color: Colors.white.withOpacity(0.1), thickness: 1)),
      ],
    );
  }
}

// ─── TEXT FIELD ───────────────────────────────────────────────────────────────
class SXTextField extends StatelessWidget {
  const SXTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      cursorColor: theme.primary,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.3), fontSize: 15),
        filled: true,
        fillColor: theme.secondaryBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: theme.primary.withOpacity(0.5), width: 1),
        ),
      ),
    );
  }
}

// ─── ACTION GRID BUTTON ───────────────────────────────────────────────────────
class SXActionButton extends StatelessWidget {
  const SXActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(13),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: theme.alternate,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.primary, size: 18),
              ),
              const SizedBox(height: 7),
              Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      height: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SESSION CARD ─────────────────────────────────────────────────────────────
class SXSessionCard extends StatelessWidget {
  const SXSessionCard({
    super.key,
    required this.date,
    required this.location,
    required this.score,
    this.badge,
    this.tintColor,
    this.onTap,
  });
  final String date;
  final String location;
  final String score;
  final String? badge;
  final Color? tintColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tint = tintColor ?? const Color(0xFF1E2A1E);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 128,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(38, 38),
                      painter: _TargetPainter(),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.secondaryBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(badge!,
                          style: GoogleFonts.inter(
                              color: theme.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(location,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3)),
                  const SizedBox(height: 4),
                  Text(score,
                      style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal target crosshair painter for session cards
class _TargetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final c = Offset(size.width / 2, size.height / 2);
    for (final r in [size.width * 0.45, size.width * 0.28, size.width * 0.11]) {
      canvas.drawCircle(c, r, paint);
    }
    canvas.drawLine(Offset(c.dx, 0), Offset(c.dx, size.height * 0.25), paint);
    canvas.drawLine(
        Offset(c.dx, size.height * 0.75), Offset(c.dx, size.height), paint);
    canvas.drawLine(Offset(0, c.dy), Offset(size.width * 0.25, c.dy), paint);
    canvas.drawLine(
        Offset(size.width * 0.75, c.dy), Offset(size.width, c.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── LEADERBOARD ROW ─────────────────────────────────────────────────────────
class SXLeaderboardRow extends StatelessWidget {
  const SXLeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.level,
    required this.xp,
    required this.time,
    this.isMe = false,
    this.onTap,
  });
  final int rank;
  final String name;
  final int level;
  final String xp;
  final String time;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isMe
            ? theme.primary.withOpacity(0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text('$rank',
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12)),
            ),
            const SizedBox(width: 10),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                  color: theme.alternate, shape: BoxShape.circle),
              child: Icon(Icons.person_rounded,
                  color: Colors.white.withOpacity(0.4), size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMe ? '$name (you)' : name,
                      style: GoogleFonts.inter(
                          color:
                              isMe ? theme.primary : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Text('Level $level',
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10)),
                ],
              ),
            ),
            Text(xp,
                style: GoogleFonts.inter(
                    color: theme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(time,
                style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── EVENT LIST TILE ─────────────────────────────────────────────────────────
class SXEventTile extends StatelessWidget {
  const SXEventTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.detail,
    this.onTap,
  });
  final String name;
  final String subtitle;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.calendar_month_rounded,
                  color: theme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.interTight(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          color: theme.primary, fontSize: 11)),
                  const SizedBox(height: 1),
                  Text(detail,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── LIVE BADGE ───────────────────────────────────────────────────────────────
class SXLiveBadge extends StatelessWidget {
  const SXLiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('LIVE',
          style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800)),
    );
  }
}

// ─── LEVEL BADGE ──────────────────────────────────────────────────────────────
class SXLevelBadge extends StatelessWidget {
  const SXLevelBadge({super.key, required this.level});
  final int level; // 0=Beginner, 1=Intermediate, 2=Advanced

  static const _labels = ['Beginner', 'Intermediate', 'Advanced'];
  static const _colors = [
    Color(0xFF3DD162),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[level.clamp(0, 2)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _labels[level.clamp(0, 2)],
        style: GoogleFonts.inter(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── CARD CONTAINER ───────────────────────────────────────────────────────────
class SXCard extends StatelessWidget {
  const SXCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: borderColor ?? theme.borderColor, width: 1),
        ),
        child: child,
      ),
    );
  }
}

// ─── PILL SELECTOR ────────────────────────────────────────────────────────────
class SXPillSelector extends StatelessWidget {
  const SXPillSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = options[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active
                    ? theme.primary
                    : theme.secondaryBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                options[i],
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}
