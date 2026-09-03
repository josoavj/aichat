import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _userName = 'Utilisateur';
  String _userBio = 'Prêt à rester concentré';
  String? _photoPath;

  String get userName => _userName;
  String get userBio => _userBio;
  String? get photoPath => _photoPath;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('profile_name') ?? 'Utilisateur';
    _userBio = prefs.getString('profile_bio') ?? 'Prêt à rester concentré';
    _photoPath = prefs.getString('profile_photo');
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? bio, String? photo}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _userName = name;
      await prefs.setString('profile_name', name);
    }
    if (bio != null) {
      _userBio = bio;
      await prefs.setString('profile_bio', bio);
    }
    if (photo != null) {
      _photoPath = photo;
      await prefs.setString('profile_photo', photo);
    }
    notifyListeners();
  }
}
