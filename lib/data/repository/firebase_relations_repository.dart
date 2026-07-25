import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:messenger/data/repository/i_chat_repository.dart';
import 'package:messenger/data/repository/i_relations_repository.dart';
import 'package:messenger/user_relations_bloc.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseRelationsRepository implements IRelationsRepository {
  final _firestore = FirebaseFirestore.instance;
  final IChatRepository _chatRepository;
  FirebaseRelationsRepository({required IChatRepository chatRepository})
    : _chatRepository = chatRepository;
  @override
  Stream<UserRelationsState> relationsStream(String myId) {
    final friendsStream = _firestore
        .collection('users')
        .doc(myId)
        .collection('friends')
        .snapshots()
        .doOnError((e, stack) => log('FRIENDS STREAM: $e'));
    final invitesStream = _firestore
        .collection('users')
        .doc(myId)
        .collection('invites')
        .snapshots()
        .doOnError((e, stack) => log('INVITES STREAM: $e'));

    return Rx.combineLatest2(friendsStream, invitesStream, (
      friendsSnap,
      invitesSnap,
    ) {
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
    }).doOnError((e, stack) => log('INVITES+FRIENDS STREAM: $e'));
  }

  @override
  Future<void> acceptFriendRequest(String uid, String myId) async {
    final batch = _firestore.batch();
    // received - in YOUR invites, as you received it
    final receivedRef = _firestore
        .collection('users')
        .doc(myId)
        .collection('invites')
        .doc(uid);
    // sent - in other person invites
    final sentRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(myId);

    final requestSnapshot = await receivedRef.get();
    final requestData = requestSnapshot.data();

    if (requestData != null) {
      if (requestData['type'] == 'received' && requestData['uid'] == uid) {
        batch.delete(receivedRef);
        batch.delete(sentRef);

        final myFriendsRef = _firestore
            .collection('users')
            .doc(myId)
            .collection('friends')
            .doc(uid);
        final myFriendsData = {
          'createdAt': FieldValue.serverTimestamp(),
          'uid': uid,
        };

        final otherFriendsRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('friends')
            .doc(myId);
        final otherFriendsData = {
          'createdAt': FieldValue.serverTimestamp(),
          'uid': myId,
        };

        batch.set(myFriendsRef, myFriendsData);
        batch.set(otherFriendsRef, otherFriendsData);
        await batch.commit();

        // notif
        final users = await Future.wait([
          _chatRepository.getBaseUserByUID(uid),
          _chatRepository.getBaseUserByUID(myId),
        ]);

        final otherUser = users[0];
        final myUser = users[1];

        await _chatRepository.sendSafePush(
          targetFcmToken: otherUser.fcmToken,
          title: 'New friend!',
          body: 'You and ${myUser.displayName} are now friends',
          type: 'newFriend',
          id: '',
        );
      } else {
        throw 'invalid_request';
      }
    } else {
      throw 'invalid_request';
    }
  }

  @override
  Future<void> sendFriendRequest(String uid, String myId) async {
    final existingInvite = await _firestore
    .collection('users')
    .doc(myId)
    .collection('invites')
    .doc(uid)
    .get();

    if (existingInvite.exists && existingInvite.data()?['type'] == 'received') {
      return acceptFriendRequest(uid, myId);
    }
    
    final batch = _firestore.batch();

    final receivedRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(myId);
    final receivedMap = {
      'type': 'received',
      'createdAt': FieldValue.serverTimestamp(),
      'uid': myId,
    };

    final sentRef = _firestore
        .collection('users')
        .doc(myId)
        .collection('invites')
        .doc(uid);
    final sentMap = {
      'type': 'sent',
      'createdAt': FieldValue.serverTimestamp(),
      'uid': uid,
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

    await _chatRepository.sendSafePush(
      targetFcmToken: otherUser.fcmToken,
      title: 'You got a friend request!',
      body: 'From ${myUser.displayName}',
      type: 'friendReq',
      id: '',
    );
  }

  @override
  Future<void> recallFriendRequest(String uid, String myId) async {
    final sentRef = _firestore
        .collection('users')
        .doc(myId)
        .collection('invites')
        .doc(uid);
    final receivedRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(myId);

    final sentSnapshot = await sentRef.get();
    final sentData = sentSnapshot.data();
    if (sentData != null) {
      if (sentData['type'] == 'sent') {
        final batch = _firestore.batch();
        batch.delete(sentRef);
        batch.delete(receivedRef);
        await batch.commit();
      }
    }
  }

  @override
  Future<void> removeFriend(String uid, String myId) async {
     final otherRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(myId);

    final myRef = _firestore
        .collection('users')
        .doc(myId)
        .collection('friends')
        .doc(uid);

    final batch = _firestore.batch();
    batch.delete(otherRef);
    batch.delete(myRef);
    await batch.commit();
  }

  @override
  Future<void> declineFriendRequest(String uid, String myId) async {
    final batch = _firestore.batch();
    // received - in YOUR invites, as you received it
    final receivedRef = _firestore
        .collection('users')
        .doc(myId)
        .collection('invites')
        .doc(uid);
    // sent - in other person invites
    final sentRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('invites')
        .doc(myId);

    final requestSnapshot = await receivedRef.get();
    final requestData = requestSnapshot.data();

    if (requestData != null) {
      if (requestData['type'] == 'received' && requestData['uid'] == uid) {
        batch.delete(receivedRef);
        batch.delete(sentRef);
        await batch.commit();
      } else {
        throw 'invalid_request';
      }
    } else {
      throw 'invalid_request';
    }
  }
}
