import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../tokens/colors/ui_colors_token.dart';

/// Single-line (by default) text field aligned with Networld tokens and [AppTheme].
class UIInputField extends StatelessWidget {
  const UIInputField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.enabled = true,
    this.obscureText = false,
    this.autocorrect = true,
    this.errorText,
    this.maxLines = 1,
    this.focusNode,
    this.autofillHints,
    this.suffixIcon,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool obscureText;
  final bool autocorrect;
  final String? errorText;
  final int maxLines;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final colors = theme.colors;
    final typo = theme.typo;

    final borderRadius = BorderRadius.circular(14);
    final borderColor = colors.cardBorderColor;
    final errorBorderColor = UIColorsToken.neg500;

    OutlineInputBorder outline(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: typo.textSm.medium.copyWith(
              color: colors.secondContentColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          enabled: enabled,
          obscureText: obscureText,
          autocorrect: autocorrect,
          maxLines: maxLines,
          focusNode: focusNode,
          autofillHints: autofillHints,
          style: typo.textMd.regular.copyWith(color: colors.contentColor),
          cursorColor: UIColorsToken.pri400,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: typo.textMd.regular.copyWith(
              color: colors.disabledContentColor,
            ),
            filled: true,
            fillColor: colors.bgColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            isDense: false,
            suffixIcon: suffixIcon,
            errorText: hasError ? errorText : null,
            errorStyle: typo.textXs.regular.copyWith(color: errorBorderColor),
            errorMaxLines: 2,
            border: outline(borderColor),
            enabledBorder: outline(borderColor),
            disabledBorder: outline(colors.disabledContentColor.withValues(alpha: 0.35)),
            focusedBorder: outline(UIColorsToken.pri500.withValues(alpha: 0.85), width: 1.25),
            errorBorder: outline(errorBorderColor),
            focusedErrorBorder: outline(errorBorderColor, width: 1.25),
          ),
        ),
      ],
    );
  }
}
