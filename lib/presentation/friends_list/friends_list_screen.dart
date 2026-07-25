import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/presentation/core/extensions/content_extensions.dart';
import 'package:messenger/presentation/friends_list/friends_list_bloc.dart';
import 'package:messenger/user_relations_bloc.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

// because we use it in mainscaffold in pageview
class _FriendsListScreenState extends State<FriendsListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => FriendsListBloc(
        chatRepository: context.read<IChatRepository>(),
        relationsBloc: context.read<UserRelationsBloc>(),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(context.l10n.friends)),
        body: BlocConsumer<FriendsListBloc, FriendsListState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is FriendsListLoading) {
              return CircularProgressIndicator();
            }
            if (state is FriendsListLoaded) {

              return ListView.builder(
                itemCount: state.friends.length+state.incomingInvites.length+state.outgoingInvites.length+3,
                itemBuilder: (context, index) {
                  // TODO
                },
              );
            }
            else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
