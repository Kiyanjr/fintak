import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/features/auth/widgets/app_button.dart';
import 'package:fintak/features/auth/widgets/auth_text_field.dart';
import 'package:fintak/features/home/viewmodels/add_transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionViewModelProvider);
    final viewModel = ref.read(addTransactionViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20, // pushes the sheet up when the keyboard appears so fields aren't hidden
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Income / Expense toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          viewModel.updateType(TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: state.type == TransactionType.expense
                              ? AppColors.red
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.type == TransactionType.expense
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
                              color: state.type == TransactionType.expense
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => viewModel.updateType(TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: state.type == TransactionType.income
                              ? AppColors.green
                              : Colors.transparent,
                          border: Border.all(
                            color: state.type == TransactionType.income
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
                              color: state.type == TransactionType.income
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AuthTextField(
                lable: 'Title',
                hint: 'e.g. Netflix , Salary....',
                icon: Icons.title_rounded,
                onChanged: viewModel.updateTitle,
              ),
              SizedBox(height: 12),
              AuthTextField(
                lable: 'Amount (\$)',
                hint: '0.00',
                icon: Icons.attach_money_rounded,
                onChanged: viewModel.updateAmount,
                keynoardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TransactionCategory.values.map((category) {
                    final isSelected = state.category == category;
                    final lable =
                        category.name[0].toUpperCase() +
                        category.name.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => viewModel.updateCategory(category),
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
                            lable,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.date,
                    firstDate: DateTime(2025),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) viewModel.updateDate(picked);
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
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM d, yyyy').format(state.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                lable: 'Note (optional)',
                hint: 'Any extra details...',
                icon: Icons.notes_rounded,
                onChanged: viewModel.updateNote,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Save Transaction',
                isLoading: state.isLoading,
                onPressed: () => viewModel.saveTransaction(ref, context),
              ),
              SizedBox(height: 8)
            ], // :)
          ),
        ),
      ),
    );
  }
}
