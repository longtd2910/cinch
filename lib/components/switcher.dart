import 'package:flutter/material.dart';

class Switcher extends StatefulWidget {
  final List<String> labels;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  const Switcher({
    super.key,
    required this.labels,
    this.initialIndex = 0,
    this.onChanged,
  });

  @override
  State<Switcher> createState() => _SwitcherState();
}

class _SwitcherState extends State<Switcher> {
  late int selectedIndex = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          for (int i = 0; i < widget.labels.length; ++i)
            Expanded(
              child: GestureDetector(
                onTapDown: (detail) {
                  if (selectedIndex == i) return;
                  setState(() {
                    selectedIndex = i;
                  });
                  widget.onChanged?.call(i);
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: (i == selectedIndex)
                        ? (selectedIndex == 0) ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.secondaryContainer
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.labels[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: (i == selectedIndex)
                          ? (selectedIndex == 0) ? Theme.of(context).colorScheme.onErrorContainer : Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.secondary,
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
