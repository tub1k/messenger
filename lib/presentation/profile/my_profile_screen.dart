import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/domain/repositories/i_chat_repository.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/core/widgets/detailed_last_seen_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => MyProfileBloc(
        myId: context.myId!,
        repository: context.read<IChatRepository>(),
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
            return Scaffold(
              appBar: AppBar(title: Text(state.user.displayName)),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: user.photoUrl.length > 2
                              ? FastCachedImageProvider(user.photoUrl)
                              : null,
                          child:
                              (user.photoUrl.length <= 2) &&
                                  (user.displayName.isNotEmpty)
                              ? Text(
                                  user.displayName[0].toUpperCase(),
                                  style: TextStyle(fontSize: 50),
                                )
                              : null,
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
