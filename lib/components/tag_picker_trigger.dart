import 'package:cinch/components/shake_on_invalid.dart';
import 'package:cinch/providers/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagPickerTrigger extends StatelessWidget {
  const TagPickerTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AddTransactionScreenProvider>(
      builder: (context, provider, _) {
        final selected = provider.selectedTag;
        return ShakeOnInvalid(
          isInvalid: provider.isFieldInvalid(
            AddTransactionScreenProvider.fieldTag,
          ),
          errorTick: provider.errorTick,
          child: Material(
            color: theme.colorScheme.surface.withValues(alpha: 0.9),
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: theme.colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => _TagPickSheetBody(provider: provider),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sell_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    if (selected != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        selected,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TagPickSheetBody extends StatefulWidget {
  const _TagPickSheetBody({required this.provider});

  final AddTransactionScreenProvider provider;

  @override
  State<_TagPickSheetBody> createState() => _TagPickSheetBodyState();
}

class _TagPickSheetBodyState extends State<_TagPickSheetBody> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        final trimmed = _searchController.text.trim();
        final q = trimmed.toLowerCase();
        final items = provider.tagOptions
            .where(
              (e) => q.isEmpty || e.toLowerCase().contains(q),
            )
            .toList()
          ..sort(
            (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
          );

        final sheetHeight = MediaQuery.sizeOf(context).height * 0.55;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search or type a new tag',
                      filled: false,
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 0,
                      ),
                      contentPadding: const EdgeInsets.only(
                        top: 8,
                        bottom: 12,
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primaryContainer,
                          width: 2,
                        ),
                      ),
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: items.length + (trimmed.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, i) {
                      final isCreate = trimmed.isNotEmpty && i == 0;
                      final label = isCreate
                          ? trimmed
                          : items[trimmed.isNotEmpty ? i - 1 : i];
                      return ListTile(
                        leading: isCreate
                            ? Icon(
                                Icons.add_rounded,
                                color: theme.colorScheme.primaryContainer,
                              )
                            : null,
                        title: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                        onTap: () {
                          provider.setTag(label);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
