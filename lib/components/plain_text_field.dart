import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlainTextField extends StatelessWidget {
  const PlainTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.hintText,
    this.style,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final String? hintText;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool readOnly;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  static InputDecoration plainDecoration(InputDecoration? base) {
    const none = InputBorder.none;
    final d = base ?? const InputDecoration();
    return d.copyWith(
      border: none,
      enabledBorder: none,
      focusedBorder: none,
      errorBorder: none,
      focusedErrorBorder: none,
      disabledBorder: none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final merged = (decoration ?? const InputDecoration()).copyWith(
      hintText: hintText ?? decoration?.hintText,
    );
    final cs = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.primaryContainer,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: style,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        readOnly: readOnly,
        obscureText: obscureText,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        maxLines: maxLines,
        minLines: minLines,
        expands: expands,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTapOutside: (_) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        inputFormatters: inputFormatters,
        decoration: plainDecoration(merged),
      ),
    );
  }
}
