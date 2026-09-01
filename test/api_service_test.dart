import 'package:ai_test/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mocktail/mocktail.dart';

class MockGenerativeModel extends Mock implements GenerativeModel {}
class MockChatSession extends Mock implements ChatSession {}
class MockGenerateContentResponse extends Mock implements GenerateContentResponse {}
class MockCandidate extends Mock implements Candidate {}
class MockContent extends Mock implements Content {}

void main() {
  late ApiService apiService;
  late MockGenerativeModel mockModel;
  late MockChatSession mockChat;

  setUp(() {
    apiService = ApiService();
    mockModel = MockGenerativeModel();
    mockChat = MockChatSession();
    
    // Note: Dans une application réelle, on pourrait injecter le modèle dans ApiService.
    // Pour ce test, on va tester la logique métier de validation.
  });

  group('ApiService - Initialisation', () {
    test('isInitialized should be false by default', () {
      expect(apiService.isInitialized, isFalse);
    });

    test('initialize should set isInitialized to true', () {
      apiService.initialize('dummy-key');
      expect(apiService.isInitialized, isTrue);
    });
  });

  group('ApiService - sendMessage validation', () {
    test('sendMessage should throw if not initialized', () async {
      expect(
        () => apiService.sendMessage('hello'),
        throwsA(isA<ApiServiceException>().having((e) => e.message, 'message', contains('non initialisé'))),
      );
    });

    test('sendMessage should throw if message is empty', () async {
      apiService.initialize('dummy-key');
      expect(
        () => apiService.sendMessage('  '),
        throwsA(isA<ApiServiceException>().having((e) => e.message, 'message', contains('ne peut pas être vide'))),
      );
    });
  });
}
