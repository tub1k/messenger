import 'package:equatable/equatable.dart';

class BaseUserModel extends Equatable {
  final String uid;
  final String? photoUrl;
  final String? displayName;
  final String? username;

  const BaseUserModel({
    required this.uid,
    this.photoUrl,
    this.displayName,
    this.username,
  });

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
