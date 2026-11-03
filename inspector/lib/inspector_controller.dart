import 'package:flutter/material.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/mock/mock_repository.dart';

import 'device/device_spec.dart';
import 'inspect/inspection.dart';
import 'scenes.dart';

enum InspectorMode { interact, inspect }

/// What the Inspector shows: scene, device, theme, language and data of the
/// app, the mode, and the element picked.
class InspectorController extends ChangeNotifier {
  InspectorController() {
    _restart();
  }

  Scene _scene = sceneGroups.first.scenes.first;
  DeviceSpec _device = DeviceSpec.all.first;
  bool _dark = false;
  Locale _locale = const Locale('en');
  bool _newUser = false;
  InspectorMode _mode = InspectorMode.inspect;
  bool _pickComponents = false;
  double? _zoom;
  int _generation = 0;
  late AppState _app;

  InspectedNode? _selected;
  InspectedNode? _hovered;

  Scene get scene => _scene;
  DeviceSpec get device => _device;
  bool get dark => _dark;
  Locale get locale => _locale;
  bool get newUser => _newUser;
  InspectorMode get mode => _mode;
  bool get pickComponents => _pickComponents;

  /// Scale of the phone; null fits it in the window (never above 100%).
  double? get zoom => _zoom;
  AppState get app => _app;

  /// Changes when the app is built again from scratch.
  int get generation => _generation;

  InspectedNode? get selected => _selected;
  InspectedNode? get hovered => _hovered;

  /// A fresh app on the scene, with the current theme, language and data.
  void _restart() {
    _app = AppState(repository: _newUser ? MockRepository.newUser() : null)
      ..setDarkMode(_dark)
      ..setLocale(_locale);
    _scene.prepare(_app);
    _generation++;
    _selected = null;
    _hovered = null;
  }

  void openScene(Scene scene) {
    _scene = scene;
    _restart();
    notifyListeners();
  }

  /// Opens the scene again, from its first state.
  void reload() {
    _restart();
    notifyListeners();
  }

  void setNewUser(bool value) {
    if (value == _newUser) return;
    _newUser = value;
    _restart();
    notifyListeners();
  }

  void setDevice(DeviceSpec device) {
    if (device == _device) return;
    _device = device;
    _clearPick();
    notifyListeners();
  }

  /// Theme and language change in place: the app keeps where it is.
  void setDark(bool value) {
    _dark = value;
    _app.setDarkMode(value);
    _clearPick();
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    _app.setLocale(locale);
    _clearPick();
    notifyListeners();
  }

  void setMode(InspectorMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _clearPick();
    notifyListeners();
  }

  void setPickComponents(bool value) {
    if (value == _pickComponents) return;
    _pickComponents = value;
    notifyListeners();
  }

  void setZoom(double? zoom) {
    if (zoom == _zoom) return;
    _zoom = zoom;
    notifyListeners();
  }

  void select(InspectedNode? node) {
    if (node == _selected) return;
    _selected = node;
    notifyListeners();
  }

  /// Only the measures show the hovered box, and they repaint every frame:
  /// no need to rebuild the page.
  void hover(InspectedNode? node) => _hovered = node;

  void _clearPick() {
    _selected = null;
    _hovered = null;
  }

  @override
  void dispose() {
    _app.dispose();
    super.dispose();
  }
}
