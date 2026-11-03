import 'package:flutter/foundation.dart';

import 'model/dashboard_layout.dart';
import 'model/default_dashboard_layout.dart';

/// State of the Dashboard for the session: the layout and whether it is
/// being edited. Not persisted.
class DashboardController extends ChangeNotifier {
  DashboardController({DashboardLayout? layout})
    : _layout = layout ?? startDashboardLayout {
    _nextId = _layout.items.length;
  }

  DashboardLayout _layout;
  bool _editing = false;
  late int _nextId;

  DashboardLayout get layout => _layout;
  bool get isEditing => _editing;

  void enterEditMode() {
    if (_editing) return;
    _editing = true;
    notifyListeners();
  }

  void exitEditMode() {
    if (!_editing) return;
    _editing = false;
    notifyListeners();
  }

  void remove(String itemId) {
    _layout = _layout.remove(itemId);
    notifyListeners();
  }

  /// Moves a widget to [index] in the new order (drag to reorder).
  void move(String itemId, int index) {
    _layout = _layout.move(itemId, index);
    notifyListeners();
  }

  void resize(String itemId, DashboardWidgetSize size) {
    _layout = _layout.resize(itemId, size);
    notifyListeners();
  }

  /// Adds a new placement of [widgetId]. The same widget can be added more
  /// than once.
  void addWidget(String widgetId, DashboardWidgetSize size) {
    String id;
    do {
      id = 'item_${++_nextId}';
    } while (_layout.items.any((i) => i.id == id));
    _layout = _layout.add(
      DashboardItem(id: id, widgetId: widgetId, size: size),
    );
    notifyListeners();
  }
}
