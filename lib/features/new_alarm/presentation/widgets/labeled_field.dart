import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Decoración compartida de los campos del asistente: etiqueta arriba,
/// contenido debajo y un botón para vaciarlo.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    required this.onClear,
    this.focused = false,
  });

  final String label;
  final Widget child;

  /// `null` oculta el botón de limpiar, que es lo que ocurre con el campo vacío.
  final VoidCallback? onClear;

  final bool focused;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: focused ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(
          color: focused ? AppColors.secondary : AppColors.border,
          width: focused ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: AppTypography.labelField.copyWith(
                      color: focused ? AppColors.secondary : AppColors.textSecondary,
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Limpiar $label',
              onPressed: onClear,
            )
          else
            const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

/// Campo de texto editable con etiqueta.
class LabeledTextField extends StatefulWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.onClear,
    this.hint,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String? hint;

  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChanged);

  void _onFocusChanged() => setState(() {});

  @override
  void didUpdateWidget(LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // El ViewModel es la fuente de verdad: si el valor cambió por fuera
    // (por ejemplo al limpiarlo), el controlador se sincroniza.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: widget.label,
      focused: _focusNode.hasFocus,
      onClear: widget.value.isEmpty ? null : widget.onClear,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        style: AppTypography.titleCard,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.hint,
          hintStyle: AppTypography.bodyDefault,
        ),
      ),
    );
  }
}

/// Campo de solo lectura que abre un selector al tocarlo.
class LabeledTapField extends StatelessWidget {
  const LabeledTapField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bool tieneValor = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: LabeledField(
        label: label,
        onClear: tieneValor ? onClear : null,
        child: Text(
          tieneValor ? value! : hint,
          style: tieneValor ? AppTypography.titleCard : AppTypography.bodyDefault,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
