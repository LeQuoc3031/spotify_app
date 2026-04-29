import 'package:dartz/dartz.dart';
import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/profile/profile_repository.dart';
import 'package:spotify_app/service_locator.dart';

class UpdateProfileInfoUseCase implements Usecase<Either, Map<String, dynamic>> {
  @override
  Future<Either> call({Map<String, dynamic>? params}) async {
    return await sl<ProfileRepository>().updateUserInfo(params!);
  }
}