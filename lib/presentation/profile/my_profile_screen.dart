import 'dart:typed_data';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/domain/repositories/i_storage_repository.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/profile/bloc/my_profile_bloc.dart';
import 'package:messenger/presentation/profile/profile_bio_field.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with AutomaticKeepAliveClientMixin {
  // because we use it on main screen
  @override
  bool get wantKeepAlive => true;

  final _picker = ImagePicker();
  Uint8List? selectedImage;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => MyProfileBloc(
        myId: context.myId!,
        repository: context.read<IChatRepository>(),
        storageRepository: context.read<IStorageRepository>()
      )..add(MyProfileInit()),
      child: BlocBuilder<MyProfileBloc, MyProfileState>(
        builder: (context, state) {
          if (state is MyProfileInitial) {
            return Scaffold(
              appBar: AppBar(title: Text(context.l10n.myProfile)),
              body: CircularProgressIndicator(),
            );
          }
          if (state is MyProfileLoaded) {
            final user = state.user;
            final selectedImage = state.selectedImage;
            return Scaffold(
              appBar: AppBar(title: Text(state.user.displayName)),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Ink(
                          decoration: BoxDecoration(
                            color: context.colorScheme.primary,
                            shape: BoxShape.circle,
                            image: selectedImage != null
                                ? DecorationImage(
                                    image: MemoryImage(selectedImage),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: FastCachedImageProvider(
                                      state.user.photoUrl,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              final XFile? pickedFile = await _picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 60,
                                maxWidth: 400,
                                maxHeight: 400,
                              );
                              final Uint8List? imageBytes = await pickedFile
                                  ?.readAsBytes();
                              if (imageBytes != null && context.mounted) {
                                context.read<MyProfileBloc>().add(
                                  MyProfileImagePicked(imageBytes: imageBytes),
                                );
                              }
                            },
                            child: SizedBox(
                              width: 120,
                              height: 120,
                              child: selectedImage != null
                                  ? null
                                  : Icon(Icons.add, size: 60 / 2),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: TextStyle(fontSize: 28),
                            ),
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                color: context.colors.halfOpaqueText,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              context.l10n.online,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ProfileBioField(
                      initialBio: user.aboutMe ?? '',
                      onSave: (newBio) {
                        context.read<MyProfileBloc>().add(
                          MyProfileBioChanged(bio: newBio),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Placeholder();
          }
        },
      ),
    );
  }
}
