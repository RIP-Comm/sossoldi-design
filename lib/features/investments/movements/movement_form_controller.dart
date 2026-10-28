import 'package:flutter/widgets.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/holding.dart';
import '../../../mock/models/investment_movement.dart';
import '../../../mock/models/movement_edit.dart';

/// What is wrong in a field of the form, to be written in the user's
/// language by the screen.
enum FieldError { required, notANumber, notPositive, future, chooseAsset }

/// State of the form of a movement, shared by the sheet that adds one and
/// the page that changes one. It keeps what was typed, checks it and turns it
/// into a [MovementDraft]; the repository does the rest (and may refuse).
///
/// When [editing] is set the type and the asset are fixed: only the date, the
/// account and the numbers change.
class MovementFormController extends ChangeNotifier {
  MovementFormController(
    this.repository, {
    MovementType type = MovementType.buy,
    String? holdingId,
    this.editing,
  }) : _type = editing?.type ?? type,
       _holdingId = editing?.holdingId ?? holdingId,
       _date = editing?.date ?? repository.today,
       _accountId = editing?.accountId {
    // A buy of a position of the catalog is a buy of that asset.
    if (editing == null &&
        _type == MovementType.buy &&
        _holdingId != null &&
        repository.holding(_holdingId!).assetId != null) {
      _assetId = repository.holding(_holdingId!).assetId;
      _holdingId = null;
    }
    final m = editing;
    if (m != null) {
      quantity.text = _text(m.quantity);
      price.text = _text(m.price);
      fee.text = m.fee == 0 ? '' : _text(m.fee);
      amount.text =
          (m.type == MovementType.dividend || m.type == MovementType.cost)
          ? _text(m.amount)
          : '';
      description.text = m.description ?? '';
    }
    for (final c in [quantity, price, fee, amount, description, manualName]) {
      c.addListener(_typed);
    }
  }

  final MockRepository repository;

  /// The movement being changed; null when adding one.
  final InvestmentMovement? editing;

  final quantity = TextEditingController();
  final price = TextEditingController();
  final fee = TextEditingController();
  final amount = TextEditingController();
  final description = TextEditingController();
  final manualName = TextEditingController();

  MovementType _type;
  String? _holdingId;
  String? _assetId;
  bool _manual = false;
  ManualAssetType _manualType = ManualAssetType.collectible;
  DateTime _date;
  String? _accountId;
  bool _submitted = false;
  MovementFailure? _failure;
  DateTime? _failedOn;

  bool get isEditing => editing != null;
  MovementType get type => _type;

  /// The position chosen (sell, dividend, cost, or a buy of one held).
  String? get holdingId => _holdingId;

  /// The catalog asset chosen for a buy.
  String? get assetId => _assetId;

  /// A buy of an asset entered by hand.
  bool get isManual => _manual;
  ManualAssetType get manualType => _manualType;
  DateTime get date => _date;

  /// The account; the first broker until one is chosen.
  String? get accountId =>
      _accountId ??
      (repository.brokerAccounts.isEmpty
          ? null
          : repository.brokerAccounts.first.id);

  /// The movement was tried to be saved: errors show.
  bool get submitted => _submitted;

  /// What the repository refused with, if it did.
  MovementFailure? get failure => _failure;
  DateTime? get failedOn => _failedOn;

  bool get isTrade => _type == MovementType.buy || _type == MovementType.sell;

  /// Which fields the type needs.
  bool get needsAsset => _type != MovementType.cost;

  static String _text(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }

  void _typed() {
    _failure = null;
    notifyListeners();
  }

  void selectType(MovementType t) {
    if (isEditing || t == _type) return;
    _type = t;
    _failure = null;
    // The asset chosen goes with the type: a catalog asset held is the
    // position of a sell, and the position of a buy is its asset.
    if (t == MovementType.buy) {
      final h = _holdingId == null ? null : repository.holding(_holdingId!);
      if (h?.assetId != null) {
        _assetId = h!.assetId;
        _holdingId = null;
      }
    } else if (_assetId != null) {
      final held = repository.holdings
          .where((h) => h.assetId == _assetId)
          .firstOrNull;
      _holdingId = held?.id;
      _assetId = null;
    }
    notifyListeners();
  }

  void selectHolding(String? id) {
    _holdingId = id;
    _failure = null;
    notifyListeners();
  }

  void selectCatalogAsset(String? id) {
    _assetId = id;
    _failure = null;
    notifyListeners();
  }

  void setManual(bool manual) {
    if (manual == _manual) return;
    _manual = manual;
    _assetId = null;
    _failure = null;
    notifyListeners();
  }

  void setManualType(ManualAssetType t) {
    _manualType = t;
    notifyListeners();
  }

  void setDate(DateTime d) {
    _date = DateTime(d.year, d.month, d.day);
    _failure = null;
    notifyListeners();
  }

  void setAccount(String id) {
    _accountId = id;
    notifyListeners();
  }

  /// A number typed with a comma or a point; null when it is not one.
  static double? parse(String text) {
    final v = double.tryParse(text.trim().replaceAll(',', '.'));
    return v != null && v.isFinite ? v : null;
  }

  FieldError? _number(TextEditingController c, {bool optional = false}) {
    if (c.text.trim().isEmpty) return optional ? null : FieldError.required;
    final v = parse(c.text);
    if (v == null) return FieldError.notANumber;
    if (optional ? v < 0 : v <= 0) return FieldError.notPositive;
    return null;
  }

  FieldError? get assetError {
    if (!needsAsset && !isEditing) return null;
    if (isEditing) return null;
    if (_type == MovementType.buy) {
      if (_manual) {
        return manualName.text.trim().isEmpty ? FieldError.required : null;
      }
      return _assetId == null && _holdingId == null
          ? FieldError.chooseAsset
          : null;
    }
    return _holdingId == null ? FieldError.chooseAsset : null;
  }

  FieldError? get quantityError => isTrade ? _number(quantity) : null;
  FieldError? get priceError => isTrade ? _number(price) : null;
  FieldError? get feeError => isTrade ? _number(fee, optional: true) : null;
  FieldError? get amountError => isTrade ? null : _number(amount);
  FieldError? get descriptionError =>
      _type == MovementType.cost && description.text.trim().isEmpty
      ? FieldError.required
      : null;
  FieldError? get dateError =>
      _type != MovementType.dividend && _date.isAfter(repository.today)
      ? FieldError.future
      : null;

  /// The errors to show: none until a save was tried.
  FieldError? shown(FieldError? e) => _submitted ? e : null;

  bool get isValid =>
      assetError == null &&
      quantityError == null &&
      priceError == null &&
      feeError == null &&
      amountError == null &&
      descriptionError == null &&
      dateError == null;

  /// What the form says, as a draft; null while it is not valid.
  MovementDraft? get draft {
    if (!isValid) return null;
    return MovementDraft(
      type: _type,
      date: _date,
      holdingId: _holdingId,
      assetId: _type == MovementType.buy && !_manual ? _assetId : null,
      manualName: _type == MovementType.buy && _manual
          ? manualName.text.trim()
          : null,
      manualType: _type == MovementType.buy && _manual ? _manualType : null,
      accountId: accountId,
      quantity: isTrade ? parse(quantity.text) : null,
      price: isTrade ? parse(price.text) : null,
      fee: isTrade ? (parse(fee.text) ?? 0) : 0,
      amount: isTrade ? null : parse(amount.text),
      description: description.text,
    );
  }

  /// The liquidity if this were saved (main currency), to warn about a buy
  /// that goes over it; null when not valid.
  double? get liquidityAfter {
    final d = draft;
    if (d == null) return null;
    return repository.liquidityAfter(d, replacing: editing?.id);
  }

  /// Tries to save: adds the movement, or changes [editing]. Returns whether
  /// it went through; otherwise the errors show, and [failure] says why the
  /// repository refused, if it did.
  bool submit() {
    _submitted = true;
    _failure = null;
    final d = draft;
    if (d == null) {
      notifyListeners();
      return false;
    }
    final result = isEditing
        ? repository.updateMovement(editing!.id, changes: d)
        : repository.addMovement(d);
    if (!result.ok) {
      _failure = result.failure;
      _failedOn = result.failedOn;
      notifyListeners();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    for (final c in [quantity, price, fee, amount, description, manualName]) {
      c.dispose();
    }
    super.dispose();
  }
}
