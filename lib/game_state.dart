import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  int materiaPrima = 0, wip = 0, productoTerminado = 0, certificacion = 0;
  Map<String, dynamic>? seed;
  DateTime? lastInterstitialAt;
  bool interstitialShownOnce = false;

  Future<void> loadSeed() async {
    final raw = await rootBundle.loadString('assets/seed/logistica.json');
    seed = jsonDecode(raw);
    notifyListeners();
  }

  void addMateriaPrima(int n) { materiaPrima += n; notifyListeners(); }
  void addWip(int n) { wip += n; notifyListeners(); }
  void addProductoTerminado(int n) { productoTerminado += n; notifyListeners(); }
  void addCertificacion(int n) { certificacion += n; notifyListeners(); }

  bool canShowInterstitial() {
    if (interstitialShownOnce) return false;
    if (lastInterstitialAt == null) return true;
    return DateTime.now().difference(lastInterstitialAt!).inMinutes >= 10;
  }

  void markInterstitialShown() {
    lastInterstitialAt = DateTime.now();
    interstitialShownOnce = true;
    notifyListeners();
  }
}
