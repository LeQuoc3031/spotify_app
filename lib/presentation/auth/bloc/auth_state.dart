import 'package:spotify_app/domain/entities/auth/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity userEntity;

  Authenticated({required this.userEntity});
}

class UnAuthenticated extends AuthState {}

class SignupLoading extends AuthState {}

class SignupSuccess extends AuthState {
  final UserEntity userEntity;

  SignupSuccess({required this.userEntity});
}

class SignupFailure extends AuthState {
  final String errorMessage;
  SignupFailure({required this.errorMessage});
}
