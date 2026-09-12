import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

final sessionInvalidatorProvider = ChangeNotifierProvider<SessionInvalidator>(
  (ref) => SessionInvalidator(),
);

class SessionInvalidator extends ChangeNotifier {
  void invalidate() => notifyListeners();
}
