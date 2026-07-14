import 'package:fintak/features/auth/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../auth/widgets/auth_text_field.dart';
class EditTransactionSheet extends ConsumerStatefulWidget {
  // Receives the existing transaction to pre-fill the form
  final TransactionModel transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  // Controllers pre-filled with existing transaction data
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  // Local state for fields not handled by a text controller
  late TransactionType _type;
  late TransactionCategory _category;
  late DateTime _date;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill everything from the existing transaction
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _date = widget.transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Validate before saving
  bool _validate() {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a title');
      return false;
    }
    final parsed = double.tryParse(_amountController.text.trim());
    if (parsed == null) {
      setState(() => _errorMessage = 'Please enter a valid amount');
      return false;
    }
    if (parsed <= 0) {
      setState(() => _errorMessage = 'Amount must be greater than zero');
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create updated transaction keeping the same id
      final updated = widget.transaction.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _category,
        date: _date,
        note: _noteController.text.trim(),
      );

      // Tell HomeViewModel to update — it handles syncing Budget and Stats too
      await ref.read(homeViewmodelProvider.notifier).updateTransaction(updated);

      setState(() => _isLoading = false);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update transaction. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        // Push sheet above keyboard
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Income / Expense toggle ──────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _type = TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.expense
                            ? AppColors.red
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == TransactionType.expense
                              ? AppColors.red
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _type == TransactionType.expense
                                ? Colors.white
                                : onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _type == TransactionType.income
                            ? AppColors.green
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _type == TransactionType.income
                              ? AppColors.green
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _type == TransactionType.income
                                ? Colors.white
                                : onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Title field ──────────────────────────
            AuthTextField(
              controller:  _titleController,
              lable: 'Title',
              hint: 'e.g. Netflix, Salary...',
              icon: Icons.title_rounded,
              onChanged: (_) => setState(() => _errorMessage = null),
              // Pass controller so field is pre-filled
            ),

            const SizedBox(height: 12),

            // ── Amount field ─────────────────────────
            AuthTextField(
              controller:  _amountController,
              lable: 'Amount (\$)',
              hint: '0.00',
              icon: Icons.euro_rounded,
              keynoardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() => _errorMessage = null),
            ),

            const SizedBox(height: 12),

            // ── Category label ───────────────────────
            Text(
              'Category',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 8),

            // ── Category chips ───────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TransactionCategory.values.map((category) {
                  final isSelected = _category == category;
                  final label =
                      category.name[0].toUpperCase() +
                      category.name.substring(1);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _category = category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // ── Date picker ──────────────────────────
            Text(
              'Date',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: onSurface.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 6),

            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkField : AppColors.lightField,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('MMMM d, yyyy').format(_date),
                      style: TextStyle(fontSize: 13, color: onSurface),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Note field ───────────────────────────
            AuthTextField(
              controller:  _noteController,
              lable: 'Note (optional)',
              hint: 'Any extra details...',
              icon: Icons.notes_rounded,
              onChanged: (_) {},
            ),

            const SizedBox(height: 12),

            // ── Error message ────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _errorMessage != null
                  ? Container(
                      key: ValueKey(_errorMessage),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            const SizedBox(height: 16),

            // ── Save button ──────────────────────────
            AppButton(
              label: 'Save Changes',
              isLoading: _isLoading,
              onPressed: _save,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
