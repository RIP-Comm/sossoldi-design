import 'package:flutter/widgets.dart';

import '../../mock/mock_repository.dart';
import '../../mock/models/holding.dart';
import '../../mock/models/movement_edit.dart';
import '../accounts/account_form_controller.dart' show parseAmount;

/// What is wrong in a field of the asset form, to be written in the user's
/// language by the screen.
enum AssetFieldError {
  chooseAsset,
  duplicate,
  nameRequired,
  nameTaken,
  amountRequired,
  amountInvalid,
  amountNotPositive,
  amountDecimals,
  priceRequired,
  priceInvalid,
  priceNotPositive,
}

/// The decimals a quantity may have (a fraction of a coin, for instance).
const maxQuantityDecimals = 8;

/// State of the form of an asset of the onboarding (new or edit): it keeps
/// what was typed, checks it and has the repository add, change or delete the
/// opening buy. With [editing] the type and the asset are fixed.
class AssetFormController extends ChangeNotifier {
  AssetFormController(this.repository, {required this.locale, this.editing}) {
    final h = editing;
    if (h != null) {
      _manual = h.isManual;
      _manualType = h.manualType ?? ManualAssetType.other;
      _assetId = h.assetId;
      final m = repository.openingMovementOf(h.id)!;
      quantity.text = _text(m.quantity!);
      price.text = _text(m.price!);
      _countsForNetWorth = h.countsForNetWorth;
      if (h.isManual) manualName.text = h.manualName!;
    }
    for (final c in [quantity, price, manualName]) {
      c.addListener(_typed);
    }
  }

  final MockRepository repository;
  final String locale;

  /// The position being changed; null when adding one.
  final Holding? editing;

  final quantity = TextEditingController();
  final price = TextEditingController();
  final manualName = TextEditingController();

  bool _manual = false;
  ManualAssetType _manualType = ManualAssetType.collectible;
  String? _assetId;
  bool _countsForNetWorth = true;
  bool _submitted = false;
  MovementFailure? _failure;

  bool get isEditing => editing != null;

  String? get assetId => _assetId;

  /// An asset entered by hand, not found in the catalog.
  bool get isManual => _manual;
  ManualAssetType get manualType => _manualType;
  bool get countsForNetWorth => _countsForNetWorth;

  /// What the repository refused with, if it did.
  MovementFailure? get failure => _failure;

  static String _text(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  void _typed() {
    _failure = null;
    notifyListeners();
  }

  void setManual(bool manual) {
    if (isEditing || manual == _manual) return;
    _manual = manual;
    _assetId = null;
    _failure = null;
    notifyListeners();
  }

  void setManualType(ManualAssetType t) {
    if (isEditing) return;
    _manualType = t;
    notifyListeners();
  }

  void selectAsset(String? id) {
    _assetId = id;
    _failure = null;
    notifyListeners();
  }

  void setCountsForNetWorth(bool value) {
    _countsForNetWorth = value;
    notifyListeners();
  }

  /// The currency of the price: the asset's, the main one for a manual asset
  /// (or before an asset is chosen).
  String get currency => _assetId == null
      ? repository.mainCurrency
      : repository.asset(_assetId!).currency;

  AssetFieldError? get _assetError {
    if (isEditing) return null;
    if (isManual) {
      if (manualName.text.trim().isEmpty) return AssetFieldError.nameRequired;
      return repository.manualAssetNameTaken(manualName.text)
          ? AssetFieldError.nameTaken
          : null;
    }
    if (_assetId == null) return AssetFieldError.chooseAsset;
    return repository.assetHeld(_assetId!) ? AssetFieldError.duplicate : null;
  }

  AssetFieldError? get _quantityError {
    final text = quantity.text.trim();
    if (text.isEmpty) return AssetFieldError.amountRequired;
    final v = parseAmount(text, locale);
    if (v == null) return AssetFieldError.amountInvalid;
    if (v <= 0) return AssetFieldError.amountNotPositive;
    // More than 8 decimals: the value is not a whole number of 1e-8 units.
    final scaled = v * 1e8;
    if ((scaled - scaled.round()).abs() > 1e-6) {
      return AssetFieldError.amountDecimals;
    }
    return null;
  }

  AssetFieldError? get _priceError {
    final text = price.text.trim();
    if (text.isEmpty) return AssetFieldError.priceRequired;
    final v = parseAmount(text, locale);
    if (v == null) return AssetFieldError.priceInvalid;
    return v <= 0 ? AssetFieldError.priceNotPositive : null;
  }

  /// The errors to show: the asset one as soon as there is one (a duplicate
  /// should be seen when picked), the others once a field was typed in or a
  /// save was tried.
  AssetFieldError? get assetError {
    final e = _assetError;
    if (e == AssetFieldError.duplicate || e == AssetFieldError.nameTaken) {
      return e;
    }
    return _submitted ? e : null;
  }

  AssetFieldError? get quantityError =>
      _submitted || quantity.text.isNotEmpty ? _quantityError : null;
  AssetFieldError? get priceError =>
      _submitted || price.text.isNotEmpty ? _priceError : null;

  /// Whether the form can be saved: the check of the toolbar is on.
  bool get isValid =>
      _assetError == null && _quantityError == null && _priceError == null;

  /// Saves the asset. False when the form is not valid or the repository
  /// refused ([failure] says why).
  bool submit() {
    _submitted = true;
    if (!isValid) {
      notifyListeners();
      return false;
    }
    final q = parseAmount(quantity.text, locale)!;
    final p = parseAmount(price.text, locale)!;
    final result = isEditing
        ? repository.updateOpeningAsset(
            editing!.id,
            quantity: q,
            averageCost: p,
            countsForNetWorth: _countsForNetWorth,
          )
        : repository.addOpeningAsset(
            assetId: isManual ? null : _assetId,
            manualName: isManual ? manualName.text.trim() : null,
            manualType: _manualType,
            quantity: q,
            averageCost: p,
            countsForNetWorth: _countsForNetWorth,
          );
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  /// Deletes the asset being edited (its opening buy goes, the position with
  /// it). False when other movements depend on it.
  bool delete() {
    final result = repository.deleteOpeningAsset(editing!.id);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  @override
  void dispose() {
    for (final c in [quantity, price, manualName]) {
      c.dispose();
    }
    super.dispose();
  }
}
