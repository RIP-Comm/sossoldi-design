import '../../mock/models/investment_movement.dart';
import '../../mock/models/transaction.dart';

/// The two things the Add sheet records.
enum AddMode { transaction, movement }

/// What the Add sheet can be opened with, to fill some fields in advance.
/// It is the hook for Siri or Shortcuts later (nothing uses it that way
/// yet): every field is optional and the ones that do not make sense for the
/// [mode] are ignored.
class AddSheetDraft {
  const AddSheetDraft({
    this.mode = AddMode.transaction,
    this.transactionType,
    this.amount,
    this.accountId,
    this.toAccountId,
    this.categoryId,
    this.subcategoryId,
    this.description,
    this.date,
    this.recurring = false,
    this.movementType,
    this.holdingId,
  });

  /// A transaction (expense unless [transactionType] says otherwise).
  const AddSheetDraft.transaction({
    this.transactionType,
    this.amount,
    this.accountId,
    this.toAccountId,
    this.categoryId,
    this.subcategoryId,
    this.description,
    this.date,
    this.recurring = false,
  }) : mode = AddMode.transaction,
       movementType = null,
       holdingId = null;

  /// An investment movement (a buy unless [movementType] says otherwise),
  /// with the position already chosen when [holdingId] is given.
  const AddSheetDraft.movement({this.movementType, this.holdingId})
    : mode = AddMode.movement,
      transactionType = null,
      amount = null,
      accountId = null,
      toAccountId = null,
      categoryId = null,
      subcategoryId = null,
      description = null,
      date = null,
      recurring = false;

  final AddMode mode;

  // Transaction
  final TransactionType? transactionType;
  final double? amount;
  final String? accountId;
  final String? toAccountId;
  final String? categoryId;
  final String? subcategoryId;
  final String? description;
  final DateTime? date;

  /// The recurring switch already on.
  final bool recurring;

  // Movement
  final MovementType? movementType;
  final String? holdingId;
}
