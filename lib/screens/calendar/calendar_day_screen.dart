import 'package:cinch/components/calendar_day_timeline.dart';
import 'package:cinch/core/models/transaction.dart';
import 'package:cinch/core/services/transaction_storage_service.dart';
import 'package:cinch/core/utils/money_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _TransactionTypeFilter { all, income, expense }

class CalendarDayScreen extends StatefulWidget {
  const CalendarDayScreen({super.key});

  @override
  State<CalendarDayScreen> createState() => _CalendarDayScreenState();
}

class _CalendarDayScreenState extends State<CalendarDayScreen> {
  final _searchController = TextEditingController();
  var _typeFilter = _TransactionTypeFilter.all;
  String? _selectedTag;
  String? _selectedSource;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onFiltersChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onFiltersChanged)
      ..dispose();
    super.dispose();
  }

  void _onFiltersChanged() {
    setState(() {});
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _typeFilter != _TransactionTypeFilter.all ||
        _selectedTag != null ||
        _selectedSource != null ||
        _selectedLocation != null;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _typeFilter = _TransactionTypeFilter.all;
      _selectedTag = null;
      _selectedSource = null;
      _selectedLocation = null;
    });
  }

  List<String> _sortedValues(Iterable<String> values) {
    final unique = {
      for (final value in values)
        if (value.trim().isNotEmpty) value.trim(),
    }.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return unique;
  }

  List<Transaction> _filteredTransactions(List<Transaction> transactions) {
    final query = _searchController.text.trim().toLowerCase();
    return transactions.where((transaction) {
      if (_typeFilter == _TransactionTypeFilter.income && !transaction.type) {
        return false;
      }
      if (_typeFilter == _TransactionTypeFilter.expense && transaction.type) {
        return false;
      }
      if (_selectedTag != null && !transaction.tags.contains(_selectedTag)) {
        return false;
      }
      if (_selectedSource != null && transaction.source != _selectedSource) {
        return false;
      }
      if (_selectedLocation != null &&
          transaction.location != _selectedLocation) {
        return false;
      }
      if (query.isEmpty) return true;

      final amount = transaction.amount.toString();
      final formattedAmount = formatMoneyWithCommas(amount);
      final searchable = [
        transaction.note,
        transaction.source,
        transaction.location,
        amount,
        formattedAmount,
        ...transaction.tags,
      ];
      return searchable.any((value) => value.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionStorageService>().loadAll();
    final filteredTransactions = _filteredTransactions(transactions);
    final tags = _sortedValues(transactions.expand((t) => t.tags));
    final sources = _sortedValues(transactions.map((t) => t.source));
    final locations = _sortedValues(transactions.map((t) => t.location));
    final emptyMessage = transactions.isEmpty
        ? 'No transactions yet'
        : _hasActiveFilters
        ? 'No matching transactions'
        : 'No transactions yet';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchField(controller: _searchController),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TypeFilterChip(
                    label: 'All',
                    selected: _typeFilter == _TransactionTypeFilter.all,
                    onSelected: () {
                      setState(() {
                        _typeFilter = _TransactionTypeFilter.all;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TypeFilterChip(
                    label: 'Income',
                    selected: _typeFilter == _TransactionTypeFilter.income,
                    onSelected: () {
                      setState(() {
                        _typeFilter = _TransactionTypeFilter.income;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TypeFilterChip(
                    label: 'Expense',
                    selected: _typeFilter == _TransactionTypeFilter.expense,
                    onSelected: () {
                      setState(() {
                        _typeFilter = _TransactionTypeFilter.expense;
                      });
                    },
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _FilterMenuChip(
                      label: 'Tag',
                      selectedValue: _selectedTag,
                      options: tags,
                      onSelected: (value) {
                        setState(() {
                          _selectedTag = value;
                        });
                      },
                    ),
                  ],
                  if (sources.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _FilterMenuChip(
                      label: 'Source',
                      selectedValue: _selectedSource,
                      options: sources,
                      onSelected: (value) {
                        setState(() {
                          _selectedSource = value;
                        });
                      },
                    ),
                  ],
                  if (locations.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _FilterMenuChip(
                      label: 'Location',
                      selectedValue: _selectedLocation,
                      options: locations,
                      onSelected: (value) {
                        setState(() {
                          _selectedLocation = value;
                        });
                      },
                    ),
                  ],
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    ActionChip(
                      label: const Text('Clear'),
                      onPressed: _clearFilters,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CalendarDayTimeline(
                transactions: filteredTransactions,
                emptyMessage: emptyMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search transactions',
        filled: false,
        // isDense: true,
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 24,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear search',
                onPressed: controller.clear,
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        contentPadding: const EdgeInsets.only(top: 8, bottom: 12),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
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
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
    );
  }
}

class _FilterMenuChip extends StatelessWidget {
  const _FilterMenuChip({
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String? selectedValue;
  final List<String> options;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedValue != null;
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: (value) => onSelected(value.isEmpty ? null : value),
      itemBuilder: (context) {
        return [
          PopupMenuItem<String>(
            value: '',
            child: Text('All ${label.toLowerCase()}s'),
          ),
          for (final option in options)
            PopupMenuItem<String>(value: option, child: Text(option)),
        ];
      },
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                selectedValue ?? label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
        backgroundColor: isSelected
            ? theme.colorScheme.secondaryContainer
            : null,
        labelStyle: isSelected
            ? theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              )
            : null,
      ),
    );
  }
}
