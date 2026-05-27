import 'package:equatable/equatable.dart';

class BaseUserModel extends Equatable {
  final String uid;
  final String photoUrl;
  final String displayName;
  final String username;

  const BaseUserModel({
    required this.uid,
    required this.photoUrl,
    required this.displayName,
    required this.username,
  });

  /// placeholder with '' values
  const BaseUserModel.empty()
    : uid = '',
      photoUrl = '',
      displayName = '',
      username = '';

  /// constructs a baseusermodel from data of a user document
  factory BaseUserModel.fromFirebase({required Map<String, dynamic> data}) {
    final model = BaseUserModel(
      username: data['username'],
      uid: data['uid'],
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
    );

    return model;
  }

  bool get isUsernameEqualToDisplayName {
    return displayName == username;
  }

  @override
  List<Object?> get props => [uid, photoUrl, displayName, username];
}
