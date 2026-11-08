// Page of one category: its subcategories (each opens its own page) and its
// transactions, with search and filters. With a subcategory it is the page of
// that subcategory: only its transactions, and no Edit. A screen of its own,
// opened with [route]. No Figma node: built from the Settings pages, the
// category row and the Finance transaction list.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../finance/recurring/recurring_detail_screen.dart';
import '../finance/recurring/recurring_item.dart';
import '../../mock/models/recurring_transaction.dart';
import 'category_detail_controller.dart';
import 'category_form_sheet.dart';
import 'category_transactions_section.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    this.subcategoryId,
  });

  final String categoryId;

  /// Set: the page of that subcategory of the category.
  final String? subcategoryId;

  /// The route to push from any screen.
  static Route<void> route(String categoryId, {String? subcategoryId}) =>
      MaterialPageRoute<void>(
        builder: (_) => CategoryDetailScreen(
          categoryId: categoryId,
          subcategoryId: subcategoryId,
        ),
      );

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  CategoryDetailController? _controller;
  final _scroll = ScrollController();
  bool _closing = false;

  CategoryDetailController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= CategoryDetailController(
      context.repository,
      widget.categoryId,
      subcategoryId: widget.subcategoryId,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The category is gone (deleted from its form, or from elsewhere): close
  /// the page. Removes this route and not the top one, as the form may still
  /// be closing above it.
  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null) Navigator.of(context).removeRoute(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final category = controller.category;
        if (controller.isDeleted || category == null) {
          _close();
          return Scaffold(backgroundColor: colors.surfaceMed);
        }
        final subcategories = controller.subcategories;
        final recurring = controller.recurring;
        final isSub = controller.isSubcategory;
        Widget title(String text) => Text(
          text,
          style: typography.titleLarge.copyWith(color: colors.textHigh),
        );
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.l,
          children: [
            if (!isSub && subcategories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SossoldiSpacing.s,
                children: [
                  title(l10n.categoryDetailSubcategories),
                  SossoldiList(
                    children: [
                      for (final s in subcategories)
                        SossoldiCategoryItem(
                          key: ValueKey(s.id),
                          name: s.name,
                          // Icon and color come from the parent.
                          leading: Icon(
                            category.icon,
                            size: 24,
                            color: category.color.main,
                          ),
                          hasChevron: true,
                          onTap: () => Navigator.of(context).push(
                            CategoryDetailScreen.route(
                              category.id,
                              subcategoryId: s.id,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            if (recurring.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SossoldiSpacing.s,
                children: [
                  title(l10n.categoryDetailRecurring),
                  SossoldiList(
                    children: [
                      for (final r in recurring)
                        RecurringItem(
                          key: ValueKey(r.id),
                          type: r.type,
                          description: r.description,
                          accountId: r.accountId,
                          toAccountId: r.toAccountId,
                          categoryId: r.categoryId,
                          amount: r.amount,
                          currency: r.currency,
                          date: r.nextDate,
                          planned: r.status == RecurringStatus.active,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  RecurringDetailScreen(recurringId: r.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.s,
              children: [
                title(l10n.categoryDetailTransactions),
                CategoryTransactionsSection(
                  controller: controller,
                  onPageSelected: (p) {
                    controller.goToPage(p);
                    if (_scroll.hasClients) _scroll.jumpTo(0);
                  },
                ),
              ],
            ),
          ],
        );
        return Scaffold(
          backgroundColor: colors.surfaceMed,
          body: SafeArea(
            child: Column(
              children: [
                // The same bar as a sheet's: Back, title, action (none on a
                // subcategory).
                SossoldiBottomSheetToolbar.text(
                  title: isSub ? controller.subcategory!.name : category.name,
                  closeLabel: l10n.back,
                  closeIcon: PhosphorIconsRegular.caretLeft,
                  onClose: () => Navigator.of(context).pop(),
                  confirmLabel: isSub ? null : l10n.categoryPageEdit,
                  onConfirm: isSub
                      ? null
                      : () => showCategoryFormSheet(context, editing: category),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(SossoldiSpacing.l),
                    child: content,
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
