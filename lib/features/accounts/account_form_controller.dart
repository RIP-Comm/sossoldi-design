import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/tokens/category_colors.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/account.dart';
import '../../mock/models/account_edit.dart';

/// What is wrong in a field of the account form, to be written in the user's
/// language by the screen.
enum AccountFieldError {
  nameRequired,
  nameTaken,
  amountRequired,
  amountInvalid,
}

/// Reads an amount typed by the user, or null when it is not a number.
/// The decimal separator may be a comma or a point, whichever the keyboard
/// gives; spaces are ignored and so is the separator of thousands of
/// [locale] ("1.500" is fifteen hundred in Italian, "1,500" in English). A
/// minus sign is allowed.
double? parseAmount(String text, String locale) {
  var t = text.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (t.isEmpty) return null;
  final group = NumberFormat.decimalPattern(locale).symbols.GROUP_SEP;
  final points = '.'.allMatches(t).length;
  final commas = ','.allMatches(t).length;
  if (points > 0 && commas > 0) {
    // Both: the last one is the decimal separator, the other groups digits.
    final decimal = t.lastIndexOf('.') > t.lastIndexOf(',') ? '.' : ',';
    final thousands = decimal == '.' ? ',' : '.';
    t = t.replaceAll(thousands, '').replaceAll(decimal, '.');
  } else if (points + commas > 1) {
    // The same one several times: they group digits.
    t = t.replaceAll(RegExp(r'[.,]'), '');
  } else if (points + commas == 1) {
    final separator = points == 1 ? '.' : ',';
    final isGroup =
        separator == group &&
        RegExp('^-?\\d{1,3}\\$separator\\d{3}\$').hasMatch(t);
    t = isGroup ? t.replaceAll(separator, '') : t.replaceAll(separator, '.');
  }
  if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(t)) return null;
  final value = double.tryParse(t);
  return value != null && value.isFinite ? value : null;
}

/// State of the account form (new or edit): it keeps what was typed, checks
/// it and turns it into an [AccountDraft]. The repository does the rest and
/// may refuse.
class AccountFormController extends ChangeNotifier {
  AccountFormController(this.repository, {required this.locale, this.editing})
    : _currency = editing?.currency ?? repository.mainCurrency,
      _color = editing?.color ?? CategoryColors.all.first,
      _icon = editing?.icon ?? PhosphorIconsRegular.bank {
    final a = editing;
    if (a != null) {
      name.text = a.name;
      amount.text = _format(a.initialBalance);
    }
    name.addListener(_typed);
    amount.addListener(_typed);
  }

  final MockRepository repository;

  /// The locale amounts are typed and shown in.
  final String locale;

  /// The account being changed; null when creating one.
  final Account? editing;

  final name = TextEditingController();
  final amount = TextEditingController();

  String _currency;
  CategoryColor _color;
  IconData _icon;
  bool _nameTouched = false;
  bool _amountTouched = false;
  bool _submitted = false;
  AccountFailure? _failure;

  bool get isEditing => editing != null;
  String get currency => _currency;
  CategoryColor get color => _color;
  IconData get icon => _icon;

  /// What the repository refused with, if it did.
  AccountFailure? get failure => _failure;

  static String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString().replaceAll('.', ',');

  void _typed() {
    _nameTouched = _nameTouched || name.text.isNotEmpty;
    _amountTouched = _amountTouched || amount.text.isNotEmpty;
    _failure = null;
    notifyListeners();
  }

  void setCurrency(String code) {
    if (code == _currency) return;
    _currency = code;
    _failure = null;
    notifyListeners();
  }

  void setColor(CategoryColor value) {
    if (value == _color) return;
    _color = value;
    notifyListeners();
  }

  void setIcon(IconData value) {
    if (value == _icon) return;
    _icon = value;
    notifyListeners();
  }

  /// The amount typed; null when empty or not a number.
  double? get parsedAmount => parseAmount(amount.text, locale);

  AccountFieldError? get _nameError {
    if (name.text.trim().isEmpty) return AccountFieldError.nameRequired;
    if (repository.accountNameTaken(name.text, excluding: editing?.id)) {
      return AccountFieldError.nameTaken;
    }
    return null;
  }

  AccountFieldError? get _amountError {
    if (amount.text.trim().isEmpty) return AccountFieldError.amountRequired;
    return parsedAmount == null ? AccountFieldError.amountInvalid : null;
  }

  /// The error of the name, once the user has typed in it or tried to save.
  AccountFieldError? get nameError =>
      _nameTouched || _submitted ? _nameError : null;

  /// The error of the amount, once the user has typed in it or tried to save.
  AccountFieldError? get amountError =>
      _amountTouched || _submitted ? _amountError : null;

  /// Whether the form can be saved: the check of the toolbar is on.
  bool get isValid => _nameError == null && _amountError == null;

  AccountDraft get draft => AccountDraft(
    name: name.text,
    initialBalance: parsedAmount ?? 0,
    currency: _currency,
    color: _color,
    icon: _icon,
    type: editing?.type ?? AccountType.checking,
  );

  /// Saves the account. False when the form is not valid or the repository
  /// refused ([failure] says why).
  bool submit() {
    _submitted = true;
    if (!isValid) {
      notifyListeners();
      return false;
    }
    final result = isEditing
        ? repository.updateAccount(editing!.id, draft)
        : repository.addAccount(draft);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  /// Deletes the account being edited. False when something refers to it.
  bool delete() {
    final result = repository.deleteAccount(editing!.id);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }
}
