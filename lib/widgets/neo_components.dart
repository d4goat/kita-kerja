import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kita_kerja/core/utils/utils.dart';

/// Reusable Neo-Brutalism Container with solid 3px border, hard shadow, zero radius.
class NeoContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final AlignmentGeometry? alignment;

  const NeoContainer({
    super.key,
    required this.child,
    this.backgroundColor = Utils.neoCream,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow = Utils.shadowMd,
    this.border,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: border ?? Utils.borderW,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Reusable Neo-Brutalism Card (for modals, auth forms, KPI cards).
class NeoCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final List<BoxShadow> boxShadow;

  const NeoCard({
    super.key,
    required this.child,
    this.maxWidth = 440,
    this.padding = const EdgeInsets.all(28),
    this.backgroundColor = Utils.neoCream,
    this.boxShadow = Utils.shadowLg,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

enum NeoButtonVariant { primary, secondary, neutral, success, danger }
enum NeoButtonSize { sm, md, lg, xl }

/// Reusable Neo-Brutalism Button with strict mechanical pressed/hover animations.
/// Color NEVER changes on press/hover; state is expressed through transform and shadow offset.
class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final NeoButtonSize size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const NeoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.size = NeoButtonSize.md,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  Color _resolveBg() {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    switch (widget.variant) {
      case NeoButtonVariant.primary:
        return Utils.neoBlue;
      case NeoButtonVariant.secondary:
        return Utils.neoYellow;
      case NeoButtonVariant.neutral:
        return Utils.neoCream;
      case NeoButtonVariant.success:
        return Utils.neoGreen;
      case NeoButtonVariant.danger:
        return Utils.neoRed;
    }
  }

  Color _resolveFg() {
    if (widget.textColor != null) return widget.textColor!;
    switch (widget.variant) {
      case NeoButtonVariant.primary:
        return Utils.neoCream; // Blue fill -> Cream text/icon
      case NeoButtonVariant.secondary:
      case NeoButtonVariant.neutral:
      case NeoButtonVariant.success:
      case NeoButtonVariant.danger:
        return Utils.neoBlack; // Yellow/Cream/Green/Red -> Black text/icon
    }
  }

  double _resolveHeight() {
    if (widget.height != null) return widget.height!;
    switch (widget.size) {
      case NeoButtonSize.sm:
        return 36;
      case NeoButtonSize.md:
        return 44;
      case NeoButtonSize.lg:
        return 56;
      case NeoButtonSize.xl:
        return 88;
    }
  }

  TextStyle _resolveTextStyle(Color fg) {
    if (widget.size == NeoButtonSize.xl) {
      return GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: fg,
        letterSpacing: 0.5,
      );
    }
    return GoogleFonts.inter(
      fontSize: widget.size == NeoButtonSize.sm ? 12 : 14,
      fontWeight: FontWeight.w700,
      color: fg,
      letterSpacing: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final bg = _resolveBg();
    final fg = _resolveFg();
    final h = _resolveHeight();

    // Interaction offsets:
    // Default: translate(0, 0), shadow (4, 4)
    // Hover: translate(-2, -2), shadow (6, 6)
    // Pressed: translate(4, 4), shadow (0, 0)
    // Disabled: translate(0, 0), shadow (0, 0)
    double tx = 0;
    double ty = 0;
    List<BoxShadow> shadow = Utils.shadowMd;

    if (!isEnabled) {
      tx = 0;
      ty = 0;
      shadow = Utils.shadowNone;
    } else if (_isPressed) {
      tx = 4;
      ty = 4;
      shadow = Utils.shadowNone;
    } else if (_isHovered) {
      tx = -2;
      ty = -2;
      shadow = Utils.shadowLg;
    }

    final childContent = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
          Text('Memproses…', style: _resolveTextStyle(fg)),
        ] else ...[
          if (!isEnabled) ...[
            Icon(Icons.lock, size: widget.size == NeoButtonSize.sm ? 14 : 18, color: fg),
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            IconTheme(
              data: IconThemeData(color: fg, size: widget.size == NeoButtonSize.sm ? 16 : 20),
              child: widget.icon!,
            ),
            const SizedBox(width: 8),
          ],
          Text(widget.text, style: _resolveTextStyle(fg)),
        ],
      ],
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(tx, ty, 0),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: h,
          padding: EdgeInsets.symmetric(horizontal: widget.size == NeoButtonSize.sm ? 12 : 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          child: childContent,
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Icon Button.
class NeoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;

  const NeoIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.backgroundColor = Utils.neoCream,
    this.iconColor = Utils.neoBlack,
    this.tooltip,
  });

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    double tx = 0;
    double ty = 0;
    List<BoxShadow> shadow = Utils.shadowSm;

    if (!isEnabled) {
      shadow = Utils.shadowNone;
    } else if (_isPressed) {
      tx = 2;
      ty = 2;
      shadow = Utils.shadowNone;
    } else if (_isHovered) {
      tx = -1;
      ty = -1;
      shadow = Utils.shadowMd;
    }

    final btn = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(tx, ty, 0),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.zero,
            border: Utils.borderW,
            boxShadow: shadow,
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, color: widget.iconColor, size: widget.size * 0.5),
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}

/// Reusable Neo-Brutalism Text Field with strict zero radius, 3px border, solid contrast.
class NeoTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const NeoTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.onChanged,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Utils.neoBlack,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(_isFocused ? -2 : 0, _isFocused ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: Utils.neoCream,
            borderRadius: BorderRadius.zero,
            boxShadow: _isFocused ? Utils.shadowMd : Utils.shadowNone,
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            readOnly: widget.readOnly,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            onChanged: widget.onChanged,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Utils.neoBlack,
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Utils.neoBlack.withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: Utils.neoCream,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: widget.prefix,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: Utils.borderSideW,
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: Utils.borderSideW,
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: Utils.borderSideW,
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: Utils.borderSideW,
              ),
              suffixIcon: widget.isPassword
                  ? Container(
                      decoration: const BoxDecoration(
                        border: Border(left: Utils.borderSideWSm),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => setState(() => _obscureText = !_obscureText),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Utils.neoBlack,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  : widget.suffix,
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable Neo-Brutalism Checkbox (24x24 box, 3px border, 0 radius).
class NeoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const NeoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Utils.neoBlack : Utils.neoCream,
                borderRadius: BorderRadius.zero,
                border: Utils.borderW,
                boxShadow: Utils.shadowSm,
              ),
              alignment: Alignment.center,
              child: value
                  ? const Icon(Icons.check, size: 16, color: Utils.neoCream)
                  : null,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Utils.neoBlack,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Toggle Switch (56x28 box, 3px border, 0 radius).
class NeoToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool readOnly;

  const NeoToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: readOnly ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: readOnly ? null : () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? Utils.neoGreen : Utils.neoCream,
                borderRadius: BorderRadius.zero,
                border: Utils.borderW,
                boxShadow: Utils.shadowSm,
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Utils.neoBlack,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value ? 'Aktif' : 'Nonaktif',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Status Badge.
/// Exact 28px height, 2px border, hard shadow 2px, 0 radius, solid icon + text.
class NeoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const NeoBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  /// Status Pekerjaan
  factory NeoBadge.taskStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'sedang dikerjakan':
        return const NeoBadge(
          label: 'SEDANG DIKERJAKAN',
          icon: Icons.play_arrow,
          backgroundColor: Utils.neoBlue,
          foregroundColor: Utils.neoCream,
        );
      case 'review':
      case 'ditinjau':
        return const NeoBadge(
          label: 'DITINJAU',
          icon: Icons.remove_red_eye,
          backgroundColor: Utils.neoYellow,
          foregroundColor: Utils.neoBlack,
        );
      case 'completed':
      case 'selesai':
        return const NeoBadge(
          label: 'SELESAI',
          icon: Icons.check,
          backgroundColor: Utils.neoGreen,
          foregroundColor: Utils.neoBlack,
        );
      case 'not_started':
      case 'belum mulai':
      default:
        return const NeoBadge(
          label: 'BELUM MULAI',
          icon: Icons.hourglass_empty,
          backgroundColor: Utils.neoCream,
          foregroundColor: Utils.neoBlack,
        );
    }
  }

  /// Prioritas Pekerjaan
  factory NeoBadge.taskPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const NeoBadge(
          label: 'URGENT',
          icon: Icons.keyboard_double_arrow_up,
          backgroundColor: Utils.neoBlack,
          foregroundColor: Utils.neoCream,
        );
      case 'high':
      case 'tinggi':
        return const NeoBadge(
          label: 'TINGGI',
          icon: Icons.keyboard_arrow_up,
          backgroundColor: Utils.neoRed,
          foregroundColor: Utils.neoBlack,
        );
      case 'medium':
      case 'sedang':
        return const NeoBadge(
          label: 'SEDANG',
          icon: Icons.drag_handle,
          backgroundColor: Utils.neoYellow,
          foregroundColor: Utils.neoBlack,
        );
      case 'low':
      case 'rendah':
      default:
        return const NeoBadge(
          label: 'RENDAH',
          icon: Icons.keyboard_arrow_down,
          backgroundColor: Utils.neoCream,
          foregroundColor: Utils.neoBlack,
        );
    }
  }

  /// Status Kehadiran
  factory NeoBadge.attendance(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'hadir':
        return const NeoBadge(
          label: 'HADIR',
          icon: Icons.check,
          backgroundColor: Utils.neoGreen,
          foregroundColor: Utils.neoBlack,
        );
      case 'late':
      case 'terlambat':
        return const NeoBadge(
          label: 'TERLAMBAT',
          icon: Icons.access_time_filled,
          backgroundColor: Utils.neoYellow,
          foregroundColor: Utils.neoBlack,
        );
      case 'sick':
      case 'sakit':
        return const NeoBadge(
          label: 'SAKIT',
          icon: Icons.medical_services,
          backgroundColor: Utils.neoCream,
          foregroundColor: Utils.neoBlack,
        );
      case 'leave':
      case 'izin':
      case 'cuti':
      case 'izin / cuti':
        return const NeoBadge(
          label: 'IZIN / CUTI',
          icon: Icons.calendar_month,
          backgroundColor: Utils.neoBlue,
          foregroundColor: Utils.neoCream,
        );
      case 'absent':
      case 'tidak hadir':
      default:
        return const NeoBadge(
          label: 'TIDAK HADIR',
          icon: Icons.close,
          backgroundColor: Utils.neoRed,
          foregroundColor: Utils.neoBlack,
        );
    }
  }

  /// Status Beban Kerja
  factory NeoBadge.workload(String status) {
    switch (status.toLowerCase()) {
      case 'overload':
        return const NeoBadge(
          label: 'OVERLOAD',
          icon: Icons.warning_rounded,
          backgroundColor: Utils.neoRed,
          foregroundColor: Utils.neoBlack,
        );
      case 'high':
      case 'tinggi':
        return const NeoBadge(
          label: 'TINGGI',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Utils.neoYellow,
          foregroundColor: Utils.neoBlack,
        );
      case 'normal':
        return const NeoBadge(
          label: 'NORMAL',
          icon: Icons.check,
          backgroundColor: Utils.neoGreen,
          foregroundColor: Utils.neoBlack,
        );
      case 'low':
      case 'kurang':
      default:
        return const NeoBadge(
          label: 'KURANG',
          icon: Icons.keyboard_arrow_down,
          backgroundColor: Utils.neoCream,
          foregroundColor: Utils.neoBlack,
        );
    }
  }

  /// Status Akun / Karyawan
  factory NeoBadge.account(String status) {
    if (status.toLowerCase() == 'active' || status.toLowerCase() == 'aktif') {
      return const NeoBadge(
        label: 'AKTIF',
        icon: Icons.check,
        backgroundColor: Utils.neoGreen,
        foregroundColor: Utils.neoBlack,
      );
    } else {
      return const NeoBadge(
        label: 'NONAKTIF',
        icon: Icons.block,
        backgroundColor: Utils.neoBlack,
        foregroundColor: Utils.neoCream,
      );
    }
  }

  /// Status Gaji
  factory NeoBadge.salary(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'dibayar':
        return const NeoBadge(
          label: 'DIBAYAR',
          icon: Icons.check,
          backgroundColor: Utils.neoGreen,
          foregroundColor: Utils.neoBlack,
        );
      case 'processed':
      case 'diproses':
        return const NeoBadge(
          label: 'DIPROSES',
          icon: Icons.settings,
          backgroundColor: Utils.neoYellow,
          foregroundColor: Utils.neoBlack,
        );
      case 'draft':
      default:
        return const NeoBadge(
          label: 'DRAFT',
          icon: Icons.edit,
          backgroundColor: Utils.neoCream,
          foregroundColor: Utils.neoBlack,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Utils.borderWSm,
        boxShadow: Utils.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: foregroundColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Neo-Brutalism Tag (non-status, 24px height, cream, no shadow, 0 radius).
class NeoTag extends StatelessWidget {
  final String label;

  const NeoTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        borderRadius: BorderRadius.zero,
        border: Utils.borderWSm,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Utils.neoBlack,
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Square Avatar (Yellow fill, black initials, 3px border, 0 radius).
class NeoAvatar extends StatelessWidget {
  final String name;
  final double size;

  const NeoAvatar({super.key, required this.name, this.size = 40});

  String _getInitials() {
    if (name.trim().isEmpty) return 'KK';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Utils.neoYellow,
        borderRadius: BorderRadius.zero,
        border: Utils.borderW,
        boxShadow: Utils.shadowSm,
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: Utils.neoBlack,
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Alert / Banner (Green/Yellow/Red/Black, 3px border, shadow md).
class NeoAlert extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? action;

  const NeoAlert({
    super.key,
    required this.text,
    required this.icon,
    this.backgroundColor = Utils.neoYellow,
    this.foregroundColor = Utils.neoBlack,
    this.action,
  });

  factory NeoAlert.danger({required String text, Widget? action}) {
    return NeoAlert(
      text: text,
      icon: Icons.warning_rounded,
      backgroundColor: Utils.neoRed,
      foregroundColor: Utils.neoBlack,
      action: action,
    );
  }

  factory NeoAlert.warning({required String text, Widget? action}) {
    return NeoAlert(
      text: text,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Utils.neoYellow,
      foregroundColor: Utils.neoBlack,
      action: action,
    );
  }

  factory NeoAlert.success({required String text, Widget? action}) {
    return NeoAlert(
      text: text,
      icon: Icons.check_circle_rounded,
      backgroundColor: Utils.neoGreen,
      foregroundColor: Utils.neoBlack,
      action: action,
    );
  }

  factory NeoAlert.info({required String text, Widget? action}) {
    return NeoAlert(
      text: text,
      icon: Icons.info_rounded,
      backgroundColor: Utils.neoBlack,
      foregroundColor: Utils.neoCream,
      action: action,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.zero,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foregroundColor,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Reusable Neo-Brutalism KPI Card (Section 7.1).
class NeoKPICard extends StatelessWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconContainerColor;
  final Color iconColor;

  const NeoKPICard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    this.iconContainerColor = Utils.neoBlack,
    this.iconColor = Utils.neoCream,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          borderRadius: BorderRadius.zero,
          border: Utils.borderW,
          boxShadow: Utils.shadowMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.zero,
                    border: Utils.borderW,
                    boxShadow: Utils.shadowSm,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 22, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Utils.neoBlack,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Utils.neoBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Workload Meter (Section 7.3).
class NeoWorkloadMeter extends StatelessWidget {
  final double percentage;
  final String label;
  final String detailText;
  final bool showBadge;

  const NeoWorkloadMeter({
    super.key,
    required this.percentage,
    required this.label,
    required this.detailText,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final clampedNormal = (percentage / 100.0).clamp(0.0, 1.0);
    final isOverload = percentage > 100.0;
    final overloadPct = isOverload ? ((percentage - 100.0) / 100.0).clamp(0.0, 0.5) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Utils.neoBlack,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isOverload ? Utils.neoRed : Utils.neoBlack,
                ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 10),
                NeoBadge.workload(
                  isOverload ? 'overload' : (percentage >= 80 ? 'high' : 'normal'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Bar track with 3px border
          Container(
            height: 24,
            decoration: const BoxDecoration(
              color: Utils.neoCream,
              borderRadius: BorderRadius.zero,
              border: Utils.borderW,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final normalWidth = totalWidth * clampedNormal;

                return Stack(
                  children: [
                    // Blue filled segment
                    Container(
                      width: normalWidth,
                      color: Utils.neoBlue,
                    ),
                    // 100% Marker Line
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 3, color: Utils.neoBlack),
                    ),
                    // Red Overload Segment if > 100%
                    if (isOverload)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: (totalWidth * overloadPct).clamp(16.0, totalWidth * 0.35),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Utils.neoRed,
                            border: Border(left: Utils.borderSideW),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detailText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Utils.neoBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable Neo-Brutalism Tabs (Section 6.8).
class NeoTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const NeoTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedIndex == index;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Utils.neoBlack : Utils.neoCream,
                borderRadius: BorderRadius.zero,
                border: Border(
                  top: Utils.borderSideW,
                  bottom: Utils.borderSideW,
                  left: Utils.borderSideW,
                  right: index == tabs.length - 1 ? Utils.borderSideW : BorderSide.none,
                ),
                boxShadow: isSelected ? Utils.shadowNone : Utils.shadowSm,
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Utils.neoCream : Utils.neoBlack,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Reusable Neo-Brutalism Table (Section 6.7).
class NeoTable extends StatelessWidget {
  final List<Widget> headers;
  final List<List<Widget>> rows;
  final Map<int, TableColumnWidth>? columnWidths;
  final bool isLoading;
  final Widget? emptyWidget;
  final String emptyText;
  final IconData emptyIcon;

  const NeoTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
    this.isLoading = false,
    this.emptyWidget,
    this.emptyText = 'Tidak ada data ditemukan',
    this.emptyIcon = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          border: Utils.borderW,
          boxShadow: Utils.shadowMd,
        ),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Utils.neoBlack),
      );
    }

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          border: Utils.borderW,
          boxShadow: Utils.shadowMd,
        ),
        child: emptyWidget ??
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Utils.neoYellow,
                      border: Utils.borderW,
                      boxShadow: Utils.shadowMd,
                    ),
                    alignment: Alignment.center,
                    child: Icon(emptyIcon, size: 40, color: Utils.neoBlack),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyText,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                ],
              ),
            ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Utils.neoCream,
        borderRadius: BorderRadius.zero,
        border: Utils.borderW,
        boxShadow: Utils.shadowMd,
      ),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: columnWidths,
        border: const TableBorder(
          horizontalInside: Utils.borderSideWSm,
        ),
        children: [
          // Header Row: Fill Neo Black, text Neo Cream
          TableRow(
            decoration: const BoxDecoration(
              color: Utils.neoBlack,
              border: Border(bottom: Utils.borderSideW),
            ),
            children: headers,
          ),
          // Data Rows: Fill Neo Cream, divider 2px
          ...rows.map((rowCells) {
            return TableRow(
              decoration: const BoxDecoration(
                color: Utils.neoCream,
              ),
              children: rowCells,
            );
          }),
        ],
      ),
    );
  }
}

class NeoTableHeaderCell extends StatelessWidget {
  final String label;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const NeoTableHeaderCell(
    this.label, {
    super.key,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Utils.neoCream,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class NeoTableCell extends StatelessWidget {
  final Widget? child;
  final String? text;
  final bool isBold;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const NeoTableCell({
    super.key,
    this.child,
    this.text,
    this.isBold = false,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: child ??
            Text(
              text ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: Utils.neoBlack,
              ),
            ),
      ),
    );
  }
}

/// Reusable Neo-Brutalism Modal / Confirm Dialog.
class NeoDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;

  const NeoDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth = 480,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    double maxWidth = 480,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => NeoDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: const BoxDecoration(
          color: Utils.neoCream,
          borderRadius: BorderRadius.zero,
          border: Utils.borderW,
          boxShadow: Utils.shadowXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: Utils.borderSideWSm),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Utils.neoBlack,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Utils.neoCream,
                          border: Border.all(color: Utils.neoBlack, width: 2),
                        ),
                        child: const Icon(Icons.close, size: 16, color: Utils.neoBlack),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: content,
              ),
            ),
            // Footer Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(top: Utils.borderSideWSm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
