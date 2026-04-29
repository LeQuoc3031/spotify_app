import 'dart:io';

import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<String> uploadAndChangeAvatar(File imageFile);
  Future<Either> updateUserInfo(Map<String, dynamic> data);
}
