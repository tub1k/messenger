import 'package:equatable/equatable.dart';

class BaseUserModel extends Equatable {
  final String? uid;
  final String? photoUrl;
  final String? displayName;
  final String? username;

  BaseUserModel({this.uid, this.photoUrl, this.displayName, this.username});

  @override
  List<Object?> get props => [uid, photoUrl, displayName, username];
}