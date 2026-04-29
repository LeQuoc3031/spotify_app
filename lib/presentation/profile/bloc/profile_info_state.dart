import 'package:spotify_app/domain/entities/auth/user.dart';

abstract class ProfileInfoState {}

class ProfileInfoInitial extends ProfileInfoState {}

class ProfileInfoLoading extends ProfileInfoState {}

class ProfileInfoLoaded extends ProfileInfoState {
  final UserEntity userEntity;

  ProfileInfoLoaded({required this.userEntity});
}

class ProfileAvatarUploading extends ProfileInfoState {
  final UserEntity oldUser;
  ProfileAvatarUploading({required this.oldUser});
}

class ProfileInfoFailure extends ProfileInfoState {
  final String message;
  ProfileInfoFailure({ required this.message});
}


class ProfileUpdating extends ProfileInfoState {}

class ProfileUpdatedSuccess extends ProfileInfoState {}

class ProfileUpdatedFailure extends ProfileInfoState {
  final String errorMessage;
  ProfileUpdatedFailure({required this.errorMessage});
}