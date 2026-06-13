part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {}

class ChatInitial extends ChatState {
  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String? errorText;
  final List<Uint8List> images;
  final bool isLoadingMore;
  final bool hasReachedMax;

  ChatLoaded({required this.messages, this.errorText, required this.images, this.isLoadingMore = false, this.hasReachedMax = false});

  ChatLoaded copyWith({
    List<MessageModel>? messages,
    String? errorText,
    List<Uint8List>? images,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      errorText: errorText ?? this.errorText,
      images: images ?? this.images,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
  
  @override
  List<Object?> get props => [messages, errorText, images.length, images.hashCode];
}