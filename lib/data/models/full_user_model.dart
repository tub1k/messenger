import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FullUserModel extends Equatable {
  final String uid;
  final String photoUrl;
  final String displayName;
  final String username;
  final String? fcmToken;
  final DateTime lastSeen;
  final bool isOnline;
  final String? aboutMe;
  final List<Map<String, dynamic>> invites;

  const FullUserModel({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.username,
    this.fcmToken,
    required this.lastSeen,
    required this.isOnline,
    this.aboutMe,
    required this.invites,
  });

  /// placeholder with '' values
  FullUserModel.empty()
    : uid = '',
      photoUrl = '',
      displayName = '',
      username = '',
      fcmToken = '',
      lastSeen = DateTime(1970),
      isOnline = false,
      aboutMe = null,
      invites = [];


  /// constructs a baseusermodel from data of a user document
  factory FullUserModel.fromFirebase({required Map<String, dynamic> data}) {
    final model = FullUserModel(
      username: data['username'],
      uid: data['uid'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      fcmToken: data['fcmToken'],
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate() ?? DateTime(1970),
      isOnline: data['isOnline'] ?? false,
      aboutMe: data['aboutMe'],
      invites: [] // TODO
    );

    return model;
  }

  bool get isUsernameEqualToDisplayName {
    return displayName == username;
  }

  @override
  List<Object?> get props => [uid, photoUrl, displayName, username];
}
