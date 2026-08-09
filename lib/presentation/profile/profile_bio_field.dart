import 'package:flutter/material.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';

class ProfileBioField extends StatefulWidget {
  final String initialBio;
  final Function(String) onSave;

  const ProfileBioField({
    super.key,
    required this.initialBio,
    required this.onSave,
  });

  @override
  State<ProfileBioField> createState() => _ProfileBioFieldState();
}

class _ProfileBioFieldState extends State<ProfileBioField> {
  late final TextEditingController _controller;
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBio);
    _controller.addListener(() {
      setState(() {
        _isChanged = _controller.text != widget.initialBio;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.aboutMe.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: theme.colorScheme.outline,
            ),
          ),
        ),

        // Поле ввода
        TextFormField(
          controller: _controller,
          maxLines: 4,
          minLines: 3,
          maxLength: 180,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 15, height: 1.4),
          decoration: InputDecoration(
            hintText: context.l10n.tellUsAboutYourself,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.all(16),

            // Настройка границ
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),

            // Стилизация счетчика символов
            counterStyle: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ),

        // Анимированная кнопка сохранения (появляется только при изменении)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isChanged
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  child: FilledButton.icon(
                    onPressed: () {
                      widget.onSave(_controller.text.trim());
                      setState(() => _isChanged = false);
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(context.l10n.saveAboutMe),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
