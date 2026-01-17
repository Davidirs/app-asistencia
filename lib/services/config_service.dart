import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  // Singleton pattern
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // ValueNotifiers for reactive updates
  final ValueNotifier<Color> primaryColor =
      ValueNotifier(const Color(0xFFE87C1E));
  final ValueNotifier<Color> secondaryColor =
      ValueNotifier(const Color(0xFF2979FF));

  // Default URL
  String _apiUrl = 'https://api-springboot-hdye.onrender.com';
  String get apiUrl => _apiUrl;

  // Keys for SharedPreferences
  static const String _keyApiUrl = 'config_api_url';
  static const String _keyPrimaryColor = 'config_primary_color';
  static const String _keySecondaryColor = 'config_secondary_color';

  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();

    // Load URL
    _apiUrl = prefs.getString(_keyApiUrl) ?? _apiUrl;

    // Load Colors
    final int? primaryValue = prefs.getInt(_keyPrimaryColor);
    if (primaryValue != null) {
      primaryColor.value = Color(primaryValue);
    }

    final int? secondaryValue = prefs.getInt(_keySecondaryColor);
    if (secondaryValue != null) {
      secondaryColor.value = Color(secondaryValue);
    }
  }

  Future<void> fetchRemoteConfig() async {
    try {
      print("Fetching remote config...");
      final firestore = FirebaseFirestore.instance;

      // 1. Fetch API URL
      final apiDoc = await firestore.collection('ajustes').doc('api').get();
      if (apiDoc.exists && apiDoc.data() != null) {
        final data = apiDoc.data()!;
        if (data.containsKey('url')) {
          _apiUrl = data['url'];
          await _saveString(_keyApiUrl, _apiUrl);
          print("Updated API URL: $_apiUrl");
        }
      }

      // 2. Fetch App Colors
      final appDoc = await firestore.collection('ajustes').doc('app').get();
      if (appDoc.exists && appDoc.data() != null) {
        final data = appDoc.data()!;
        bool colorsChanged = false;

        if (data.containsKey('primaryColor')) {
          String hex = data['primaryColor'].toString();
          // Ensure format is valid (e.g. "E87C1E" or "#E87C1E")
          hex = hex.replaceAll('#', '');
          if (hex.length == 6) {
            final color = Color(int.parse('0xFF$hex'));
            if (color.value != primaryColor.value.value) {
              primaryColor.value = color;
              await _saveInt(_keyPrimaryColor, color.value);
              colorsChanged = true;
            }
          }
        }

        if (data.containsKey('secondaryColor')) {
          String hex = data['secondaryColor'].toString();
          hex = hex.replaceAll('#', '');
          if (hex.length == 6) {
            final color = Color(int.parse('0xFF$hex'));
            if (color.value != secondaryColor.value.value) {
              secondaryColor.value = color;
              await _saveInt(_keySecondaryColor, color.value);
              colorsChanged = true;
            }
          }
        }

        if (colorsChanged) {
          print(
              "Updated App Colors: Primary=${primaryColor.value}, Secondary=${secondaryColor.value}");
        }
      }
    } catch (e) {
      print("Error fetching remote config: $e");
    }
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}
