import 'package:flutter/material.dart';
import 'package:networld/src/src/core/design_system/app_ui.dart';

class CommentInputField extends StatelessWidget {
  const CommentInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isSending,
    required this.canSend,
    required this.hasText,
    required this.onSend,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isSending;
  final bool canSend;
  final bool hasText;
  final VoidCallback onSend;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return UIInputField(
      controller: controller,
      hintText: hintText,
      textInputAction: TextInputAction.newline,
      focusNode: focusNode,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasText)
            IconButton(
              onPressed: controller.clear,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: theme.colors.secondContentColor,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: (canSend && !isSending) ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: canSend ? UIColorsToken.pri350 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: canSend
                        ? UIColorsToken.pri350
                        : theme.colors.secondContentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: UICircularProgressBar(),
                        )
                      : Icon(
                          Icons.send,
                          size: 16,
                          color: canSend
                              ? UIColorsToken.black
                              : theme.colors.secondContentColor,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
