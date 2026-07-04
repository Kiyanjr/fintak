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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Show spinner while loading
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
          padding: const EdgeInsets.only(bottom: 90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header: title + add button ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budget',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: onSurface)),
                        const SizedBox(height: 2),
                        // Current month and year subtitle
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                              fontSize: 11,
                              color: onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                    // Add budget button
                    IconButton(
                      onPressed: () =>
                          _showAddBudgetSheet(context, ref),
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Summary cards (spent, remaining, progress bar) ──
                BudgetSummaryCard(
                  totalBudget: budgetState.totalBudget,
                  totalSpent: budgetState.totalSpent,
                ),

                const SizedBox(height: 20),

                // ── Section title ──
                Text('By category',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onSurface)),

                const SizedBox(height: 10),

                // ── Category list or empty state ──
                budgetState.categoryItems.isEmpty
                    ? _buildEmptyState(context)
                    : Column(
                        children: budgetState.categoryItems
                            .map((item) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: CategoryBudgetCard(
                                    item: item,
                                    // Pass delete callback — shows confirm dialog
                                    onDelete: () => _confirmDelete(
                                        context, ref, item.budgetId),
                                  ),
                                ))
                            .toList(),
                      ),

                // Error message if something went wrong
                if (budgetState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.redSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        budgetState.errorMessage!,
                        style: const TextStyle(
                            color: AppColors.red, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state widget ──────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.wallet_outlined,
                size: 48,
                color: Colors.grey.withOpacity(0.35)),
            const SizedBox(height: 10),
            Text('No budgets set yet',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.withOpacity(0.6))),
            const SizedBox(height: 4),
            Text('Tap + to add a category budget',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }

  // ── Add budget bottom sheet ─────────────────
  // Opens a simple sheet where the user picks a category and enters a limit
  void _showAddBudgetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddBudgetSheet(
        // Pass the callback — called when user saves
        onSave: (category, limit) {
          ref
              .read(budgetViewModelProvider.notifier)
              .addOrUpdateBudget(category, limit);
        },
      ),
    );
  }

  // ── Delete confirmation dialog ──────────────
  void _confirmDelete(
      BuildContext context, WidgetRef ref, String budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: const Text(
            'This will remove the budget limit for this category.'),
        actions: [
          // Cancel — just close the dialog
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          // Delete — call viewmodel then close dialog
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(budgetViewModelProvider.notifier)
                  .deleteBudget(budgetId);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// _AddBudgetSheet
// Local StatefulWidget — only used inside this file
// No separate ViewModel needed — logic is simple enough to live here
// ─────────────────────────────────────────────
class _AddBudgetSheet extends StatefulWidget {
  final void Function(TransactionCategory category, double limit) onSave;

  const _AddBudgetSheet({required this.onSave});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  // Default selections
  TransactionCategory _selectedCategory = TransactionCategory.food;
  final _limitController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  // Validate and call the onSave callback
  void _save() {
    final parsed = double.tryParse(_limitController.text.trim());

    if (parsed == null || parsed <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }

    widget.onSave(_selectedCategory, parsed);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Push sheet up when keyboard opens
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Sheet header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Set Category Budget',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: onSurface)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close_rounded,
                    color: onSurface.withOpacity(0.5)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Category dropdown label ──
          Text('Category',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: onSurface.withOpacity(0.6))),

          const SizedBox(height: 6),

          // ── Category dropdown ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkField : AppColors.lightField,
              borderRadius: BorderRadius.circular(13),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TransactionCategory>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                items: TransactionCategory.values.map((cat) {
                  // Capitalize for display
                  final label =
                      cat.name[0].toUpperCase() + cat.name.substring(1);
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(label,
                        style:
                            TextStyle(fontSize: 13, color: onSurface)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Budget limit label ──
          Text('Monthly limit (€)',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: onSurface.withOpacity(0.6))),

          const SizedBox(height: 6),

          // ── Budget limit text field ──
          Container(
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.darkField : AppColors.lightField,
              borderRadius: BorderRadius.circular(13),
            ),
            child: TextField(
              controller: _limitController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 13, color: onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: onSurface.withOpacity(0.3)),
                prefixIcon: Icon(Icons.euro_rounded,
                    size: 18,
                    color: onSurface.withOpacity(0.4)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
              ),
              // Clear error when user starts typing
              onChanged: (_) => setState(() => _error = null),
            ),
          ),

          // ── Error message ──
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.redSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!,
                  style: const TextStyle(
                      color: AppColors.red, fontSize: 12)),
            ),
          ],

          const SizedBox(height: 20),

          // ── Save button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Save Budget',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
