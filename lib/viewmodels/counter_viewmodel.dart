import 'package:flutter/foundation.dart';
import '../models/counter_model.dart';

class CounterViewModel extends ChangeNotifier {
  CounterModel _model = CounterModel(value: 0);

  CounterModel get model => _model;
  int get count => _model.value;

  void increment() {
    _model = _model.copyWith(value: _model.value + 1);
    notifyListeners();
  }

  void decrement() {
    _model = _model.copyWith(value: _model.value - 1);
    notifyListeners();
  }

  void reset() {
    _model = CounterModel(value: 0);
    notifyListeners();
  }
}

