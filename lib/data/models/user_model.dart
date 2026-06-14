import 'package:equatable/equatable.dart';

class BaseUserModel extends Equatable {
  final String uid;
  final String photoUrl;
  final String displayName;
  final String username;
  final String? fcmToken;
  final DateTime lastSeen;
  final bool isOnline;

  const BaseUserModel({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.username,
    this.fcmToken,
    required this.lastSeen,
    required this.isOnline,
  });

  /// placeholder with '' values
  BaseUserModel.empty()
    : uid = '',
      photoUrl = '',
      displayName = '',
      username = '',
      fcmToken = '',
      lastSeen = DateTime(1970),
      isOnline = false;


  /// constructs a baseusermodel from data of a user document
  factory BaseUserModel.fromFirebase({required Map<String, dynamic> data}) {
    final model = BaseUserModel(
      username: data['username'],
      uid: data['uid'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      fcmToken: data['fcmToken'],
      lastSeen: data['lastSeen'] ?? DateTime(1970),
      isOnline: data['isOnline'] ?? false,
    );

    return model;
  }

  bool get isUsernameEqualToDisplayName {
    return displayName == username;
  }

  @override
  List<Object?> get props => [uid, photoUrl, displayName, username];
}
