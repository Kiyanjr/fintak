import 'package:fintak/core/constants/app_colors.dart';
import 'package:fintak/data/models/transaction_model.dart';
import 'package:fintak/features/budget/viewmodels/budget_viewmodel.dart';
import 'package:fintak/features/budget/viewmodels/category_budget_card.dart';
import 'package:fintak/features/budget/widegts/budget_summer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetViewModelProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (budgetState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header component block
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Budget',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      color: AppColors.accent,
                      iconSize: 30,
                      onPressed: () => _showAddBudgetSheet(context, ref),
                    ),
                  ],
                ),
                
                const SizedBox(height: 18),
                
                // 2. Budget global calculations card 
                BudgetSummaryCard(
                  totalBudget: budgetState.totalBudget,
                  totalSpent: budgetState.totalSpent,
                ),
                
                const SizedBox(height: 24),
                
                // 3. Section sub-header details
                Text(
                  'By category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // 4. Rendering logic matching data criteria streams
                if (budgetState.categoryItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wallet_outlined,
                            size: 44,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No budgets set yet',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to add a category budget',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...budgetState.categoryItems.map(
                    (item) => CategoryBudgetCard(
                      item: item,
                      // Pass context and active WidgetRef directly to prompt confirmation safely
                      onDelete: () => _confirmDelete(context, ref, item.budgetId),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddBudgetForm(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: const Text('This will remove the budget limit for this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Directly triggers viewmodel provider state cleanups
              ref.read(budgetViewModelProvider.notifier).deleteBudget(budgetId);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddBudgetForm extends StatefulWidget {
  const _AddBudgetForm();

  @override
  State<_AddBudgetForm> createState() => _AddBudgetFormState();
}

class _AddBudgetFormState extends State<_AddBudgetForm> {
  TransactionCategory _selectedCategory = TransactionCategory.food;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paddingBottom = MediaQuery.of(context).viewInsets.bottom;

    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + paddingBottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set Category Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: TransactionCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name[0].toUpperCase() + category.name.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Budget Limit (€)',
                  prefixText: '€ ',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final limit = double.tryParse(_amountController.text) ?? 0.0;
                  if (limit > 0) {
                    ref.read(budgetViewModelProvider.notifier).addOrupdateBudegt(
                          _selectedCategory,
                          limit,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}