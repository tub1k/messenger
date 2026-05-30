import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';

class MockChatRepository extends Mock implements IChatRepository {}
class MockStorageRepository extends Mock implements IStorageRepository {}

void main() {
  late MockChatRepository mockRepository;
  late ChatBloc chatBloc;
  late MockStorageRepository mockStorageRepository;
  final myId = 'exampleid';
  final chatId = 'sigmachat';

  setUpAll(() {
    registerFallbackValue(MessageType.unknown);
  });

  setUp(() {
    mockRepository = MockChatRepository();
    mockStorageRepository = MockStorageRepository();
    chatBloc = ChatBloc(repository: mockRepository, myId: myId, chatId: chatId, storageRepository: mockStorageRepository);
  });

  tearDown(() {
    chatBloc.close();
  });

  blocTest<ChatBloc, ChatState>(
    'Проверим, что сообщения моментально отображаются в Optimistic UI',
    build: () {
      when(
        () => mockRepository.sendMessage(
          chatId: any(named: 'chatId'),
          text: any(named: 'text'),
          senderId: any(named: 'senderId'),
          type: any(named: 'type'),
        ),
      ).thenAnswer((_) => Future.value());

      return chatBloc;
    },

    seed: () => ChatLoaded(messages: const [], images: const []),

    act: (bloc) => bloc.add(
      const ChatMessageSent('Тестовый привет', messageType: MessageType.text),
    ),

    expect: () => [
      isA<ChatLoaded>().having(
        (state) => state.messages.first.text,
        'текст сообщения',
        'Тестовый привет',
      ),
    ],
  );
}
