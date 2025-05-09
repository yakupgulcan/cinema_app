import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CustomerProvider with ChangeNotifier {
  int? _customerID;
  final String _key = 'customer_id';

  CustomerProvider() {
    _loadCustomerID();
  }

  int? get customerID => _customerID;

  Future<void> setCustomerID(int? id) async {
    _customerID = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt(_key, id);
    } else {
      await prefs.remove(_key);
    }
    notifyListeners();
  }

  Future<void> clearCustomerID() async {
    await setCustomerID(null);
  }

  Future<void> _loadCustomerID() async {
    final prefs = await SharedPreferences.getInstance();
    _customerID = prefs.getInt(_key);
    notifyListeners();
  }
}