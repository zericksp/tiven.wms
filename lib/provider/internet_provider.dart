import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider extends ChangeNotifier {
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  InternetProvider() {
    checkInternetConnection();
  }

 Future<void> checkInternetConnection() async {
    final results = await Connectivity().checkConnectivity();

    // If ANY of the results indicate no connection, set _hasInternet to false
    bool newStatus = !results.contains(ConnectivityResult.none);

    if (_hasInternet != newStatus) {
      _hasInternet = newStatus;
      notifyListeners();
    }
  }
}
