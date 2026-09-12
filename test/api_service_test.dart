import 'package:flutter_test/flutter_test.dart';
import 'package:ai_test/services/api_service.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('isInitialized should be false initially', () {
      expect(apiService.isInitialized, false);
    });

    test('sendMessage should throw if not initialized', () async {
      expect(
        () => apiService.sendMessage('hello'),
        throwsA(isA<ApiServiceException>()),
      );
    });

    test('getHistory should return empty if not initialized', () {
      expect(apiService.getHistory(), isEmpty);
    });
  });
}
