import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/button/basic_app_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/ultils/args/status_args.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePassword> {
  final _oldPassCon = TextEditingController();
  final _newPassCon = TextEditingController();
  final _confirmPassCon = TextEditingController();

  bool _showOldPass = true;
  bool _showNewPass = true;
  bool _showConfirmPass = true;

  bool _isLengthValid = false;
  bool _isComplexValid = false;
  String? _oldPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  void _validatePassword(String value) {
    setState(() {
      _isLengthValid = value.length >= 6 && value.length <= 20;
      _isComplexValid =
          RegExp(r'[A-Za-z]').hasMatch(value) &&
          RegExp(r'[0-9]').hasMatch(value) &&
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  bool _isPasswordMatch = true; // Thêm biến này để kiểm tra khớp mật khẩu
  bool _isNewPasswordMatch = true;
  void _validateConfirmPassword(String value) {
    setState(() {
      if (_confirmPassCon.text.isEmpty) {
        setState(() {
          _confirmPasswordError = 'Vui lòng nhập xác nhận mật khẩu';
        });
      } else {
        setState(() {
          _confirmPasswordError = null;
        });
      }

      _isPasswordMatch = value == _newPassCon.text;
    });
  }


  void showLoadingProgress(BuildContext context) {
    showDialog(
      context: context,
      routeSettings: const RouteSettings(name: '/change-password'),
      barrierDismissible: false, // Không cho phép nhấn ra ngoài để đóng
      builder: (context) => const LoadingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Điều kiện để nút sáng: đúng độ dài, đúng định dạng, khớp mật khẩu và mật khẩu cũ không trống
    bool canSubmit =
        _isLengthValid &&
        _isComplexValid &&
        _isPasswordMatch &&
        _newPassCon.text.isNotEmpty &&
        _oldPassCon.text.isNotEmpty;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: BlocListener<ProfileInfoCubit, ProfileInfoState>(
        listener: (context, state) {
          if (state is ProfileUpdating) {
            showLoadingProgress(context);
          }
          if (state is ProfileUpdatedSuccess) {
            Navigator.pop(context);
            // Nếu thành công thì vẫn chuyển sang màn hình thông báo thành công
            Navigator.pushNamed(
              context,
              '/status',
              arguments: StatusArgs(isSuccess: true, message: null),
            );
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => const StatusPage(isSuccess: true),
            //   ),
            // );
          } else if (state is ProfileUpdatedFailure) {
            Navigator.pop(context);
            // Nếu lỗi là do sai mật khẩu cũ, cập nhật biến lỗi để hiển thị tại chỗ
            if (state.errorMessage == "Mật khẩu cũ không chính xác") {
              setState(() {
                _oldPasswordError = state.errorMessage;
              });
            } else {
              // Các lỗi khác (mạng, hệ thống...) thì mới chuyển sang trang lỗi
              Navigator.pushNamed(
                context,
                '/status',
                arguments: StatusArgs(
                  isSuccess: false,
                  message: state.errorMessage,
                ),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) =>
              //         StatusPage(isSuccess: false, message: state.errorMessage),
              //   ),
              // );
            }
          }
        },
        child: Scaffold(
          backgroundColor: context.isDarkMode
              ? AppColors.darkBackground
              : Colors.white,
          appBar: const BasicAppbar(
            title: Text(
              'Đổi mật khẩu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            // Dùng để không bị đè khi hiện bàn phím
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mật khẩu cũ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),
                _buildPasswordField(
                  _oldPassCon,
                  "Mật khẩu cũ",
                  _showOldPass,
                  () {
                    setState(() => _showOldPass = !_showOldPass);
                  },
                  () {
                    setState(() => _oldPassCon.clear());
                  },
                  onChanged: (val) {
                    if (_oldPassCon.text.isEmpty) {
                      setState(() {
                        _oldPasswordError = "Vui lòng nhập mật khẩu cũ";
                      });
                    } else {
                      setState(() {
                        _oldPasswordError = null;
                      });
                    }
                    // if (_oldPasswordError != null) {
                    //   setState(() {
                    //     _oldPasswordError =
                    //         null; // Xóa lỗi khi người dùng bắt đầu nhập lại
                    //   });
                    // }
                  },
                ),
                if (_oldPasswordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _oldPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                const Text(
                  'Tạo mật khẩu mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                _buildPasswordField(
                  _newPassCon,
                  "Mật khẩu mới",
                  _showNewPass,
                  () {
                    setState(() => _showNewPass = !_showNewPass);
                  },
                  () {
                    setState(() => _newPassCon.clear());
                  },
                  onChanged: (val) {
                    if (_newPassCon.text.isEmpty) {
                      setState(() {
                        _newPasswordError = "Vui lòng nhập mật khẩu mới";
                      });
                    } else {
                      setState(() {
                        _newPasswordError = null;
                      });
                    }
                    // if (_newPasswordError != null) {
                    //   setState(() {
                    //     _newPasswordError =
                    //         null; // Xóa lỗi khi người dùng bắt đầu nhập lại
                    //   });
                    // }
                    if (_oldPassCon.text == _newPassCon.text) {
                      setState(() {
                        _isNewPasswordMatch = false;
                      });
                    } else {
                      setState(() {
                        _isNewPasswordMatch = true;
                      });
                    }

                    _validatePassword(val);
                    _validateConfirmPassword(
                      _confirmPassCon.text,
                    ); // Kiểm tra lại khớp khi đổi pass mới
                  },
                ),
                if (_newPasswordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _newPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                if (!_isNewPasswordMatch && _newPassCon.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      "Mật khẩu mới không được trùng với mật khẩu cũ",
                      style: TextStyle(color: Colors.red[400], fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Mật khẩu của bạn phải gồm:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                _buildConditionRow("Từ 6 đến 20 ký tự", _isLengthValid),
                const SizedBox(height: 8),
                _buildConditionRow(
                  "Bao gồm chữ cái, số và ký tự đặc biệt",
                  _isComplexValid,
                ),
                const SizedBox(height: 15),
                _buildPasswordField(
                  _confirmPassCon,
                  "Xác nhận mật khẩu mới",
                  _showConfirmPass,
                  () {
                    setState(() => _showConfirmPass = !_showConfirmPass);
                  },
                  () {
                    setState(() => _confirmPassCon.clear());
                  },
                  onChanged: _validateConfirmPassword,
                ),
                if (_confirmPasswordError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      _confirmPasswordError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                // Dòng thông báo không khớp (Hiển thị ngay khi gõ sai)
                if (!_isPasswordMatch && _confirmPassCon.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      "Mật khẩu và xác nhận mật khẩu không khớp",
                      style: TextStyle(color: Colors.red[400], fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 40),
                BasicAppButton(
                  title: "Xác nhận",
                  // Nút chỉ nhấn được khi tất cả điều kiện đúng
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() {
                      _oldPasswordError = null;
                      _newPasswordError = null;
                      _confirmPasswordError = null;
                    });
                    if (_oldPassCon.text.isEmpty ||
                        _newPassCon.text.isEmpty ||
                        _confirmPassCon.text.isEmpty) {
                      setState(() {
                        _oldPasswordError = "Vui lòng nhập mật khẩu cũ";
                        _newPasswordError = "Vui lòng nhập mật khẩu mới";
                        _confirmPasswordError =
                            "Vui lòng nhập xác nhận mật khẩu";
                      });
                      return;
                    }
                    if (canSubmit) {
                      context.read<ProfileInfoCubit>().changePassword(
                        oldPass: _oldPassCon.text,
                        newPass: _newPassCon.text,
                      );
                    }
                  },
                ),

                // BlocConsumer<UserCubit, UserState>(
                //   listener: (context, state) {
                //     if (state is UserUpdateSuccess) {
                //       // Chuyển sang màn hình thành công
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => const StatusPage(isSuccess: true),
                //         ),
                //       );
                //     } else if (state is UserFailure) {
                //       // Chuyển sang màn hình báo lỗi với thông báo từ Cubit
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => StatusPage(
                //             isSuccess: false,
                //             message: state
                //                 .errorMessage, // Sẽ nhận "Mật khẩu cũ không chính xác"
                //           ),
                //         ),
                //       );
                //     }
                //   },
                //   builder: (context, state) {
                //     return BasicAppButton(
                //       title: "Xác nhận",
                //       // Nút chỉ nhấn được khi tất cả điều kiện đúng
                //       onPressed: canSubmit
                //           ? () {
                //               context.read<UserCubit>().changePassword(
                //                 oldPass: _oldPassCon.text,
                //                 newPass: _newPassCon.text,
                //               );
                //             }
                //           : null,
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConditionRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 18,
          color: isValid ? const Color(0xff42C83C) : Colors.grey,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: isValid
                ? context.isDarkMode
                      ? Colors.white
                      : Colors.black
                : Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool isObscure, // Nhận vào biến riêng
    VoidCallback onToggleObscure, // Nhận vào hàm để toggle
    VoidCallback onToggleClean, {
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16),
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration:
          InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onToggleClean,
                  child: const Icon(Icons.close, color: Colors.grey, size: 16),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ).copyWith(
            contentPadding: const EdgeInsets.all(20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
    );
  }
}
