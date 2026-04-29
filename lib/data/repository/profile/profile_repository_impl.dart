// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:spotify_app/data/sources/profile/profile_firebase_service.dart';
import 'package:spotify_app/domain/repository/profile/profile_repository.dart';
import 'package:spotify_app/service_locator.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<String> uploadAndChangeAvatar(File imageFile) async {
    return await sl<ProfileFirebaseService>().uploadAndChangeAvatar(imageFile);
  }

  @override
  Future<Either> updateUserInfo(Map<String, dynamic> data) async {
    try {
      await sl<ProfileFirebaseService>().updateUserInfo(data);
      return const Right('Cập nhật thông tin thành công');
    } catch (e) {
      print('updateUserInfo error: $e');
      return Left(e.toString());
    }
  }
}
