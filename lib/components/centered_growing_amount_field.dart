import 'package:cinch/components/shake_on_invalid.dart';
import 'package:cinch/core/utils/money_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CenteredGrowingAmountField extends StatefulWidget {
  const CenteredGrowingAmountField({
    super.key,
    required this.controller,
    this.isInvalid = false,
    this.errorTick = 0,
  });

  final TextEditingController controller;
  final bool isInvalid;
  final int errorTick;

  @override
  State<CenteredGrowingAmountField> createState() =>
      _CenteredGrowingAmountFieldState();
}

class _CenteredGrowingAmountFieldState
    extends State<CenteredGrowingAmountField> {
  static const _hint = '0';

  TextStyle _amountStyle(BuildContext context, {required bool hasValue}) {
    final cs = Theme.of(context).colorScheme;
    return GoogleFonts.nunito(
      fontSize: 42,
      fontWeight: FontWeight.w600,
      color: hasValue ? cs.primary : cs.onSurface,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CenteredGrowingAmountField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  double _fieldWidth(BuildContext context, double parentMaxWidth) {
    final hasValue = widget.controller.text.trim().isNotEmpty;
    final text = widget.controller.text.isEmpty
        ? _hint
        : widget.controller.text;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: _amountStyle(context, hasValue: hasValue),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final maxW = parentMaxWidth * 0.75;
    return (painter.width + 28).clamp(48.0, maxW);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.trim().isNotEmpty;
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ShakeOnInvalid(
            isInvalid: widget.isInvalid,
            errorTick: widget.errorTick,
            child: Material(
              color: cs.surface.withValues(alpha: 0.9),
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 40,
                    color: hasValue ? cs.primary : cs.onSurface,
                  ),
                  SizedBox(
                    width: _fieldWidth(context, constraints.maxWidth),
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [MoneyInputFormatter()],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        errorBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: _hint,
                        hintStyle: _amountStyle(context, hasValue: false),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                      ),
                      style: _amountStyle(context, hasValue: hasValue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
