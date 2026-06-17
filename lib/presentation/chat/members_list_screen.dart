import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/chat_model.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/chat/gallery_screen.dart';

class MembersListScreen extends StatelessWidget {
  final ChatModel chat;
  final ChatBloc chatBloc;
  const MembersListScreen({super.key, required this.chat, required this.chatBloc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent,), // for back button
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: double.infinity, height: 50,),
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: chatBloc,
                      child: GalleryScreen(
                        imageUrls: [chat.photoUrl],
                        initialIndex: 0,
                        chat: chat,
                      ),
                    ),
                  ),
                );
              },
              child: Hero(
                tag: chat.photoUrl,
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage: chat.photoUrl.length > 2
                      ? FastCachedImageProvider(chat.photoUrl)
                      : null,
                  child: chat.photoUrl.length <= 2
                      ? Text(chat.chatName[0].toUpperCase())
                      : null,
                ),
              ),),
              const SizedBox(height: 10),
              Text(chat.chatName, style: TextStyle(fontSize: 20),),
              const SizedBox(height: 10),
        ],
      ),
    );
  }
}
