import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_relations_repository.dart';
import 'package:messenger/user_relations_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseRelationsRepository implements IRelationsRepository {
  final _firestore = FirebaseFirestore.instance;
  final IChatRepository _chatRepository;
  FirebaseRelationsRepository({
    required IChatRepository chatRepository,
  })  : _chatRepository = chatRepository;
  @override
  Stream<UserRelationsState> relationsStream(String myId) {
  final friendsStream = _firestore.collection('users').doc(myId).collection('friends').snapshots();
  final invitesStream = _firestore.collection('users').doc(myId).collection('invites').snapshots();

  return Rx.combineLatest2(friendsStream, invitesStream, (friendsSnap, invitesSnap) {
    final friendIds = friendsSnap.docs.map((doc) => doc.id).toSet();
    
    final received = <String>{};
    final sent = <String>{};
    
    for (var doc in invitesSnap.docs) {
      if (doc.data()['type'] == 'received') received.add(doc.id);
      if (doc.data()['type'] == 'sent') sent.add(doc.id);
    }

    return UserRelationsState(
      friendIds: friendIds,
      incomingInviteIds: received,
      outgoingInviteIds: sent,
      blockedIds: {}, // TODO: add blocked list to repo when its implemented
    );
  });
}
 @override
  Future<void> acceptFriendRequest(String uid, String myId) {
    // TODO: implement acceptFriendRequest
    throw UnimplementedError();
  }
  
  @override
  Future<void> sendFriendRequest(String uid, String myId) async {
    final batch = _firestore.batch();

    final receivedRef = _firestore.collection('users').doc(uid).collection('invites').doc(myId);
    final receivedMap = {
      'type' : 'received',
      'createdAt' : FieldValue.serverTimestamp(),
      'uid' : myId
    };

    final sentRef = _firestore.collection('users').doc(myId).collection('invites').doc(uid);
    final sentMap = {
      'type' : 'sent',
      'createdAt' : FieldValue.serverTimestamp(),
      'uid' : uid
    };

    batch.set(receivedRef, receivedMap);
    batch.set(sentRef, sentMap);

    await batch.commit();

    final users = await Future.wait([
      _chatRepository.getBaseUserByUID(uid),
      _chatRepository.getBaseUserByUID(myId),
    ]);

    final otherUser = users[0];
    final myUser = users[1];

    await _chatRepository.sendSafePush(targetFcmToken: otherUser.fcmToken, title: 'You got a friend request!', body: 'From ${myUser.displayName}', type: 'friendReq', id: '');
  }
} 