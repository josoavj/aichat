import 'package:ai_test/services/api_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Injecter le mock dans ApiManager
    ApiManager.storage = mockStorage;
  });

  group('ApiManager - Validation', () {
    test('isValidApiKey should return false for empty key', () {
      expect(ApiManager.isValidApiKey(''), isFalse);
    });

    test('isValidApiKey should return false for short key', () {
      expect(ApiManager.isValidApiKey('abc'), isFalse);
    });

    test('isValidApiKey should return false for invalid characters', () {
      expect(ApiManager.isValidApiKey('key_with_special_@_char'), isFalse);
    });

    test('isValidApiKey should return true for valid key', () {
      expect(ApiManager.isValidApiKey('a' * 20), isTrue);
      expect(ApiManager.isValidApiKey('valid-key-with-123456'), isTrue);
    });
  });

  group('ApiManager - Operations', () {
    const testKey = 'this-is-a-valid-api-key-123';

    test('saveApiKey should call storage.write when key is valid', () async {
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await ApiManager.saveApiKey(testKey);

      verify(() => mockStorage.write(
            key: 'gemini_api_key',
            value: testKey,
          )).called(1);
    });

    test('saveApiKey should throw ApiManagerException when key is invalid', () async {
      expect(
        () => ApiManager.saveApiKey('short'),
        throwsA(isA<ApiManagerException>()),
      );
    });

    test('getApiKey should return value from storage', () async {
      when(() => mockStorage.read(key: 'gemini_api_key'))
          .thenAnswer((_) async => testKey);

      final result = await ApiManager.getApiKey();

      expect(result, equals(testKey));
      verify(() => mockStorage.read(key: 'gemini_api_key')).called(1);
    });

    test('deleteApiKey should call storage.delete', () async {
      when(() => mockStorage.delete(key: 'gemini_api_key'))
          .thenAnswer((_) async {});

      await ApiManager.deleteApiKey();

      verify(() => mockStorage.delete(key: 'gemini_api_key')).called(1);
    });
  });
}
