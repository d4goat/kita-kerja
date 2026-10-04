import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const NeoCard({
    super.key,
    required this.child,
    this.maxWidth = 440,
    this.padding = const EdgeInsets.all(28),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Utils.border,
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final bool isLoading;

  const NeoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = Utils.primary,
    this.textColor = Colors.white,
    this.height = 42,
    this.width,
    this.isLoading = false,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double offsetVal = _isPressed ? 1 : 3;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: Matrix4.translationValues(
            _isPressed ? 2 : 0,
            _isPressed ? 2 : 0,
            0,
          ),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Utils.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Utils.border,
                offset: Offset(offsetVal, offsetVal),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class NeoTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const NeoTextField({
    super.key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Utils.border,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Utils.border,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF999999),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Utils.border, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Utils.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Utils.danger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Utils.danger, width: 2),
            ),
            suffixIcon: widget.isPassword
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _obscureText
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(Icons.remove_red_eye_outlined),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

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
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: value ? Utils.primary : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Utils.border, width: 2),
            ),
            alignment: Alignment.center,
            child: value
                ? const Icon(Icons.check, size: 11, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Utils.border,
            ),
          ),
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
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF666666),
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
  final bool isDanger;
  final bool isSuccess;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  const NeoTableCell({
    super.key,
    this.child,
    this.text,
    this.isBold = false,
    this.isDanger = false,
    this.isSuccess = false,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child:
            child ??
            Text(
              text ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: isDanger
                    ? Utils.danger
                    : isSuccess
                    ? const Color(0xFF1B7F2D)
                    : Utils.border,
              ),
            ),
      ),
    );
  }
}

class NeoTable extends StatelessWidget {
  final List<Widget> headers;
  final List<List<Widget>> rows;
  final Map<int, TableColumnWidth>? columnWidths;
  final bool isLoading;
  final Widget? emptyWidget;
  final String emptyText;
  final IconData emptyIcon;
  final Color headerBackgroundColor;
  final bool showVerticalBorders;
  final bool showHorizontalBorders;
  final BorderSide? verticalBorder;
  final BorderSide? horizontalBorder;
  final bool showContainer;

  const NeoTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnWidths,
    this.isLoading = false,
    this.emptyWidget,
    this.emptyText = 'Tidak ada data ditemukan',
    this.emptyIcon = Icons.inbox_outlined,
    this.headerBackgroundColor = const Color(0xFFF9F9F9),
    this.showVerticalBorders = true,
    this.showHorizontalBorders = true,
    this.verticalBorder,
    this.horizontalBorder,
    this.showContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveVerticalBorder = showVerticalBorders
        ? (verticalBorder ?? const BorderSide(color: Utils.border, width: 1.5))
        : BorderSide.none;

    final effectiveHorizontalBorder = showHorizontalBorders
        ? (horizontalBorder ??
              const BorderSide(color: Utils.border, width: 1.5))
        : BorderSide.none;

    final Widget content = isLoading
        ? const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: Utils.primary),
            ),
          )
        : rows.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(40),
            child:
                emptyWidget ??
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(emptyIcon, size: 48, color: const Color(0xFF888888)),
                      const SizedBox(height: 12),
                      Text(
                        emptyText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Utils.border,
                        ),
                      ),
                    ],
                  ),
                ),
          )
        : Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            border: TableBorder(
              horizontalInside: effectiveHorizontalBorder,
              verticalInside: effectiveVerticalBorder,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: headerBackgroundColor,
                  border: const Border(
                    bottom: BorderSide(color: Utils.border, width: 2),
                  ),
                ),
                children: headers,
              ),
              ...rows.map((rowCells) {
                return TableRow(children: rowCells);
              }),
            ],
          );

    if (!showContainer) return content;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Utils.border, width: 2),
        boxShadow: const [
          BoxShadow(color: Utils.border, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
    );
  }
}
