import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/user_model.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';

class MyProfileEvent {}

class MyProfileInit extends MyProfileEvent {}

class MyProfileBioChanged extends MyProfileEvent {
  final String bio;

  MyProfileBioChanged({required this.bio});
}

class MyProfileImagePicked extends MyProfileEvent {
  final Uint8List imageBytes;

  MyProfileImagePicked({required this.imageBytes});
}

class MyProfileState {}

class MyProfileInitial extends MyProfileState {}

class MyProfileLoaded extends MyProfileState {
  final BaseUserModel user;
  final Uint8List? selectedImage;
  final bool isUploadingImage;

  MyProfileLoaded({required this.user, this.selectedImage, this.isUploadingImage = false});

  MyProfileLoaded copyWith({
    BaseUserModel? user,
    Uint8List? selectedImage,
    bool? isUploadingImage,
  }) {
    return MyProfileLoaded(
      user: user ?? this.user,
      selectedImage: selectedImage ?? this.selectedImage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage
    );
  }
}

class MyProfileBloc extends Bloc<MyProfileEvent, MyProfileState> {
  final String myId;
  final IChatRepository repository;
  final IStorageRepository storageRepository;
  MyProfileBloc({required this.myId, required this.repository, required this.storageRepository}) : super(MyProfileInitial()) {
    on<MyProfileInit>((event, emit) async {
      final user = await repository.getBaseUserByUID(myId);
      emit(MyProfileLoaded(user: user));
    });
    on<MyProfileBioChanged>((event, emit) {
      repository.changeBio(event.bio, myId);
    });
    on<MyProfileImagePicked>((event, emit) async {
      var curState = state;
      if (curState is MyProfileLoaded) {
        emit(curState.copyWith(selectedImage: event.imageBytes, isUploadingImage: true));
        try {
          await storageRepository.uploadImage(event.imageBytes, 'userAvatars', 'public/$myId/avatar.png');
          final url = await storageRepository.getProfilePhotoUrl(myId);
          await repository.changeUserAvatarUrl(url, myId);
        } catch (e) {
          // TODO
        }
        curState = state;
        if (curState is MyProfileLoaded) {
          emit(curState.copyWith(isUploadingImage: false));
        }
      }
    });
  }
}