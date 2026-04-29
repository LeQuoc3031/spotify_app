import 'dart:io';

import 'package:spotify_app/core/usecase/usecase.dart';
import 'package:spotify_app/domain/repository/profile/profile_repository.dart';
import 'package:spotify_app/service_locator.dart';

class UploadAndChangeAvatarUseCase implements Usecase<String, File> {
  @override
  Future<String> call({File? params}) async {
    return await sl<ProfileRepository>().uploadAndChangeAvatar(params!);
  }
}
