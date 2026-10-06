import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';

/// Campo de búsqueda con debounce: avisa del texto cuando el usuario deja de
/// escribir, para no filtrar ni consultar en cada pulsación.
class SearchField extends StatefulWidget {
  const SearchField({
    required this.onChanged,
    this.hint = Strings.search,
    this.initialValue = '',
    this.debounce = const Duration(milliseconds: 300),
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final String initialValue;
  final Duration debounce;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {});
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(text.trim()));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _onTextChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: Strings.clearSearch,
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}
