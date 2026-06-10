import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/models/message_model.dart';
import 'package:messenger/presentation/chat/bloc/chat_bloc.dart';
import 'package:messenger/presentation/core/widgets/relative_time_text.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryScreen extends StatefulWidget {
  final List<String> imageUrls;
  final MessageModel msg;
  final int initialIndex;
  const GalleryScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.msg,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.msg.sender.displayName),
            RelativeTimeText(dateTime: widget.msg.timestamp),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChatBloc>().add(
                ChatDownloadImage(imageUrl: (widget.imageUrls[_currentIndex])),
              );
            },
            icon: Icon(Icons.download),
          ),
        ],
        backgroundColor: Colors.black38,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        pageController: _pageController,
        onPageChanged: (index) {
          _currentIndex = index;
        },
        builder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          final cont = PhotoViewComputedScale.contained;

          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            initialScale: cont,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            maxScale: cont * 2.5,
            minScale: cont,
            filterQuality: FilterQuality.high,
          );
        },
        loadingBuilder: (context, event) =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
