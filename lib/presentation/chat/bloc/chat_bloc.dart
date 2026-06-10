import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_image_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;
  final IStorageRepository _storageRepository;
  final IImageRepository _imageRepository;
  final String myId;
  final String chatId;
  final ChatModel chat;

  List<Uint8List> _localPickedImages = [];

  ChatBloc({
    required IChatRepository repository,
    required this.myId,
    required this.chatId,
    required this.chat,
    required IStorageRepository storageRepository, required IImageRepository imageRepository,
  }) : _imageRepository = imageRepository, _storageRepository = storageRepository,
       _repository = repository,
       super(ChatInitial()) {
    on<ChatEvent>((event, emit) {});

    on<ChatStarted>((event, emit) async {
      await emit.forEach(
        _repository.getMessages(chatId),
        onData: (messages) {
          return ChatLoaded(
            messages: messages,
            images: [..._localPickedImages],
          );
        },
        onError: (error, _) {
          return ChatLoaded(
            messages: const [],
            errorText: error.toString(),
            images: [..._localPickedImages],
          );
        },
      );
    });

    on<ChatMessageSent>((event, emit) async {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      // ФИКС 2: Изолируем байты для отправки, чтобы избежать гонки потоков
      final imagesToUpload = List<Uint8List>.from(_localPickedImages);
      var type = event.messageType;

      if (type == MessageType.text && imagesToUpload.isNotEmpty) {
        type = MessageType.image;
      }

      final optimisticMessage = MessageModel(
        id: DateTime.now().toString(),
        text: event.text,
        senderId: myId,
        timestamp: DateTime.now(),
        type: type,
        isPending: true,
        optimisticImages: imagesToUpload,
        sender: await _repository.getBaseUserByUID(myId),
      );

      emit(
        ChatLoaded(
          messages: [optimisticMessage] + currentState.messages,
          images: [..._localPickedImages],
        ),
      );
      _localPickedImages.clear();

      try {
        final messageId = await _repository.sendMessage(
          chatId: chatId,
          text: event.text,
          senderId: myId,
          type: type,
          imageAmount: imagesToUpload.length,
          chat: chat,
        );

        await Future.wait(
          imagesToUpload.asMap().entries.map((entry) async {
            return await _storageRepository.uploadImage(
              entry.value,
              'chatMedia',
              'public/$chatId/$messageId/${entry.key}.png',
            );
          }).toList(),
        );

        emit(ChatLoaded(messages: currentState.messages, images: const []));
      } catch (e) {
        emit(
          ChatLoaded(
            messages: currentState.messages,
            images: [..._localPickedImages],
            errorText: e.toString(),
          ),
        );
      }
    });

    on<ChatAddImage>((event, emit) {
      List<MessageModel> currentMessages = [];
      _localPickedImages.addAll(event.images);

      if (state is ChatLoaded) {
        currentMessages = (state as ChatLoaded).messages;
      }
      emit(
        ChatLoaded(messages: currentMessages, images: [..._localPickedImages]),
      );
    });

    on<ChatDownloadImage>((event, emit) async {
      List<MessageModel> currentMessages = [];
      if (state is ChatLoaded) {
        currentMessages = (state as ChatLoaded).messages;
      }
      try {
        emit(ChatLoaded(messages: currentMessages, images: _localPickedImages, errorText: "loading_started"));
        await _imageRepository.saveImageToGallery(event.imageUrl);
        emit(ChatLoaded(messages: currentMessages, images: _localPickedImages, errorText: "loading_success"));
      } catch (e) {
        emit(ChatLoaded(messages: currentMessages, images: _localPickedImages, errorText: e.toString()));
      }
    });
  }
}
