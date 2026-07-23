import 'package:messenger/user_relations_bloc.dart';

abstract class IRelationsRepository {
  /// used for getting friend/invite/block lists live 
  Stream<UserRelationsState> relationsStream(String myId);

  Future<void> sendFriendRequest(String uid, String myId);

  Future<void> acceptFriendRequest(String uid, String myId);

  Future<void> recallFriendRequest(String uid, String myId);

  Future<void> removeFriend(String uid, String myId);

  Future<void> declineFriendRequest(String uid, String myId);
}
