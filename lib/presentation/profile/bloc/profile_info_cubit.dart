// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/auth/get_user_usecase.dart';
import 'package:spotify_app/domain/usecases/profile/update_profile_info_usecase.dart';
import 'package:spotify_app/domain/usecases/profile/upload_and_change_avatar_usecase.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/service_locator.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit() : super(ProfileInfoInitial()) {
    // getUser();
  }

  Future<void> getUser() async {
    emit(ProfileInfoLoading());
    final user = await sl<GetUserUseCase>().call();

    user.fold(
      (l) {
        print('l: $l');
        if (!isClosed) {
          emit(ProfileInfoFailure(message: l.toString()));
        }
      },
      (userEntity) {
        if (!isClosed) {
          emit(ProfileInfoLoaded(userEntity: userEntity));
        }
      },
    );
  }

  // Hàm upload avatar
  Future<void> updateAvatar(File imageFile) async {
    final currentState = state;

    // Nếu đang có dữ liệu user, chuyển sang state Uploading nhưng vẫn giữ data cũ
    if (currentState is ProfileInfoLoaded) {
      emit(ProfileAvatarUploading(oldUser: currentState.userEntity));
    }

    try {
      // Gọi repository để upload (hàm này trả về URL ảnh mới)
      final String newAvatarUrl = await sl<UploadAndChangeAvatarUseCase>().call(
        params: imageFile,
      );

      // Sau khi upload thành công, lấy lại thông tin user mới hoặc update thủ công
      final updatedUser = (currentState as ProfileInfoLoaded).userEntity
          .copyWith(avatarUrl: newAvatarUrl);

      emit(ProfileInfoLoaded(userEntity: updatedUser));
    } catch (e) {
      print('updateAvatar error: $e');
      emit(ProfileInfoFailure(message: e.toString()));
    }
  }

  Future<void> updateUserInfo({
    String? displayName,
    String? bio,
    String? gender,
    String? dob,
    String? phone,
  }) async {
    emit(ProfileUpdating());

    // Tạo Map chứa các giá trị không null
    final Map<String, dynamic> updateData = {};
    if (displayName != null) updateData['fullName'] = displayName;
    if (bio != null) updateData['biography'] = bio;
    if (gender != null) updateData['gender'] = gender;
    if (dob != null) updateData['birthday'] = dob;
    if (phone != null) updateData['phone'] = phone;

    if (updateData.isEmpty) {
      emit(ProfileUpdatedSuccess());
      return;
    }

    // Gọi UseCase thông qua Service Locator (sl)
    final result = await sl<UpdateProfileInfoUseCase>().call(
      params: updateData,
    );

    result.fold(
      (l) {
        emit(ProfileUpdatedFailure(errorMessage: l));
      },
      (r) async {
        // Sau khi update thành công trên Firebase, hãy fetch lại data mới nhất
        await getUser();
        emit(ProfileUpdatedSuccess());
      },
    );
  }

  // Trong UserCubit
  Future<void> changePassword({
    required String oldPass,
    required String newPass,
  }) async {
    emit(ProfileUpdating());
    try {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPass,
      );

      // Xác thực lại với mật khẩu cũ
      await user.reauthenticateWithCredential(cred);
      // Đổi mật khẩu mới
      await user.updatePassword(newPass);

      emit(ProfileUpdatedSuccess());
    } on FirebaseAuthException catch (e) {
      String error = "Đã có lỗi xảy ra";
      // Kiểm tra mã lỗi từ Firebase
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        error = "Mật khẩu cũ không chính xác";
      }
      print("error: $error");
      emit(ProfileUpdatedFailure(errorMessage: error));
    } catch (e) {
      print('changePassword error: $e');
      emit(ProfileUpdatedFailure(errorMessage: e.toString()));
    }
  }
}
