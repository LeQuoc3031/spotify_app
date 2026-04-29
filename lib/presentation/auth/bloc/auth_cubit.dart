// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:spotify_app/data/models/auth/create_user_req.dart';
import 'package:spotify_app/data/models/auth/user.dart';
import 'package:spotify_app/domain/entities/auth/user.dart';
import 'package:spotify_app/domain/usecases/auth/signup_usecase.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_state.dart';
import 'package:spotify_app/service_locator.dart';

// class AuthCubit extends HydratedCubit<AuthState>{

//   AuthCubit() : super(AuthInitial());

//   void updatedUser(UserEntity userEntity){
//     emit(Authenticated(userEntity: userEntity));
//   }

//   void logout(){
//     emit(UnAuthenticated());
//   }

//   @override
//   AuthState? fromJson(Map<String, dynamic> json) {
//     try{
//       return Authenticated(userEntity: UserModel.fromJson(json['user']));
//     }catch (_){
//       return UnAuthenticated();
//     }
//   }

//   @override
//   Map<String, dynamic>? toJson(AuthState state) {
//     if(state is Authenticated){
//       return {'user': (state.userEntity as UserModel).toJson()};
//     }
//     return null;
//   }
// }

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  // Cập nhật thông tin user khi login thành công
  void updatedUser(UserEntity userEntity) {
    emit(Authenticated(userEntity: userEntity));
  }

  // Logout: Phải xóa cả ở Firebase và xóa State
  Future<void> logout() async {
    try {
      // 1. Xóa session trên Firebase
      await FirebaseAuth.instance.signOut();
      // 2. Emit trạng thái để Hydrated xóa cache hoặc ghi đè trạng thái UnAuthenticated
      emit(UnAuthenticated());
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      // Kiểm tra status được lưu trong máy
      final status = json['status'] as String?;
      if (status == 'authenticated' && json['user'] != null) {
        return Authenticated(userEntity: UserModel.fromJson(json['user']));
      }
      return UnAuthenticated();
    } catch (_) {
      return UnAuthenticated();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {
        'status': 'authenticated',
        'user': (state.userEntity as UserModel).toJson(),
      };
    }
    // QUAN TRỌNG: Trả về một Map cụ thể thay vì null để ghi đè dữ liệu cũ khi Logout
    return {'status': 'unauthenticated'};
  }

  // Trong SignupCubit
  Future<void> signup(CreateUserReq createUserReq) async {
    emit(SignupLoading());
    try {
      final result = await sl<SignupUseCase>().call(params: createUserReq);

      result.fold(
        (l) {
          // 'l' là message lỗi trả về từ Repository/Firebase
          emit(SignupFailure(errorMessage: l));
        },
        (r) {
          print('userEntity r: $r');
          emit(SignupSuccess(userEntity: r));
        },
      );
    } catch (e) {
      emit(SignupFailure(errorMessage: e.toString()));
    }
  }
}
