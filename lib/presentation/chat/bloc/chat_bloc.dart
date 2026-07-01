import 'dart:typed_data';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_image_repository.dart';
import 'package:messenger/data/repository/i_storage_repository.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IChatRepository _repository;
  final IStorageRepository _storageRepository;
  final IImageRepository _imageRepository;
  final String myId;
  final ChatModel chat;

  List<Uint8List> _localPickedImages = [];

  ChatBloc({
    required IChatRepository repository,
    required this.myId,
    required this.chat,
    required IStorageRepository storageRepository,
    required IImageRepository imageRepository,
  }) : _imageRepository = imageRepository,
       _storageRepository = storageRepository,
       _repository = repository,
       super(ChatInitial()) {
    final String chatId = chat.chatId;
    on<ChatEvent>((event, emit) {});

    List<MessageModel> _mergeMessages({
      required List<MessageModel> liveMessages,
      required List<MessageModel> existingMessages,
    }) {
      final Map<String, MessageModel> merged = {};

      for (var msg in existingMessages) {
        merged[msg.id] = msg;
      }
      for (var msg in liveMessages) {
        merged[msg.id] = msg;
      }

      final result = merged.values.toList();
      result.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return result;
    }

    on<ChatStarted>((event, emit) async {
      await emit.forEach(
        _repository.getMessages(chatId),
        onData: (newMessages) {
          final curState = state;

          if (curState is ChatLoaded) {
            final List<MessageModel> updatedMessages = _mergeMessages(
              liveMessages: newMessages,
              existingMessages: curState.messages,
            );

            return curState.copyWith(
              messages: updatedMessages,
              images: [..._localPickedImages],
            );
          }
          return ChatLoaded(
            messages: newMessages,
            images: [..._localPickedImages],
          );
        },
        onError: (error, _) {
          final curState = state; 
          final currentMessages = curState is ChatLoaded ? curState.messages : const <MessageModel>[];
          return ChatLoaded(
            messages: currentMessages,
            errorText: error.toString(),
            images: [..._localPickedImages],
            isLoadingMore: curState is ChatLoaded ? curState.isLoadingMore : false,
            hasReachedMax: curState is ChatLoaded ? curState.hasReachedMax : false,
          );
        },
      );
    });


    on<ChatMessageSent>((event, emit) async {
      final currentState = state;
      if (currentState is! ChatLoaded) return;

      final imagesToUpload = List<Uint8List>.from(_localPickedImages);
      var type = event.messageType;

      if (type == MessageType.text && imagesToUpload.isNotEmpty) {
        type = MessageType.image;
      }

      final uniqueMessageId = const Uuid().v4();

      final optimisticMessage = MessageModel(
        id: uniqueMessageId,
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

      try {
        final messageId = await _repository.sendMessage(
          messageId: uniqueMessageId,
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
        _localPickedImages.clear();

        final latestState = state;
        if (latestState is ChatLoaded) {
          emit(latestState.copyWith(images: const []));
        }
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
        emit(
          ChatLoaded(
            messages: currentMessages,
            images: _localPickedImages,
            errorText: "loading_started",
          ),
        );
        await _imageRepository.saveImageToGallery(event.imageUrl);
        emit(
          ChatLoaded(
            messages: currentMessages,
            images: _localPickedImages,
            errorText: "loading_success",
          ),
        );
      } catch (e) {
        emit(
          ChatLoaded(
            messages: currentMessages,
            images: _localPickedImages,
            errorText: e.toString(),
          ),
        );
      }
    });

    on<ChatLoadMoreMessages>((event, emit) async {
      final curState = state;
      if (curState is! ChatLoaded) return;
      if (curState.isLoadingMore || curState.hasReachedMax) return;
      final currentMessages = (state as ChatLoaded).messages;
      if (currentMessages.lastOrNull == null) return;
      emit(curState.copyWith(isLoadingMore: true));
      try {
        final newMessages = await _repository.loadOlderMessages(
          chatId: chatId,
          beforeTimestamp: currentMessages.lastOrNull!.timestamp,
          limit: 30,
        );
        if (newMessages.isEmpty || newMessages.length < 30) {
          emit(
            curState.copyWith(
              messages: [...currentMessages, ...newMessages],
              isLoadingMore: false,
              hasReachedMax: true,
            ),
          );
        } else {
          emit(
            curState.copyWith(
              messages: [...currentMessages, ...newMessages],
              isLoadingMore: false,
            ),
          );
        }
      } catch (e) {
        emit(curState.copyWith(isLoadingMore: false, errorText: e.toString()));
      }
    }, transformer: throttleDroppable(const Duration(seconds: 2)));
  }
}

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) =>
      droppable<E>().call(events.throttle(duration), mapper);
}

