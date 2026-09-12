import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProfileProvider', () {
    late ProfileProvider profileProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      profileProvider = ProfileProvider();
    });

    test('Initial state should be default values', () async {
      // Need to wait for initialize inside the constructor or call loadProfile
      await profileProvider.loadProfile();
      expect(profileProvider.userName, 'Utilisateur');
      expect(profileProvider.userBio, 'Prêt à rester concentré');
    });

    test('updateProfile should update state and save to prefs', () async {
      await profileProvider.updateProfile(name: 'New Name', bio: 'New Bio');
      
      expect(profileProvider.userName, 'New Name');
      expect(profileProvider.userBio, 'New Bio');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('profile_name'), 'New Name');
      expect(prefs.getString('profile_bio'), 'New Bio');
    });
  });
}
