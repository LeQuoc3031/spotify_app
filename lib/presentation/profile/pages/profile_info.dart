// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/widget/account_info_widget.dart';
import 'package:spotify_app/presentation/profile/widget/infor_about_you_widget.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> with RouteAware {
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    print("User đã quay lại ProfileInfoPage - Đang làm mới dữ liệu...");
    // context.read<ProfileInfoCubit>().getUser();
  }

  @override
  void dispose() {
    //hủy đăng ký khi hủy widget
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Hàm xử lý chọn ảnh
  Future<void> _onPickImage(ImageSource source) async {
    try {
      // 1. Mở trình chọn ảnh của thiết bị
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500, // Giới hạn kích thước để upload nhanh hơn
        maxHeight: 500,
        imageQuality: 80, // Giảm chất lượng một chút để nén dung lượng
      );

      if (pickedFile != null) {
        // Đóng BottomSheet chọn nguồn ảnh
        if (!mounted) return;
        Navigator.pop(context);

        // 2. Gọi Cubit/Bloc để thực hiện logic upload
        // Giả sử bạn có UserCubit với hàm changeAvatar nhận File
        File image = File(pickedFile.path);
        context.read<ProfileInfoCubit>().updateAvatar(image);

        

        // --- LOGIC TEST NHANH KHI CHƯA CÓ CUBIT ---
        // Bạn có thể gọi trực tiếp service qua Service Locator 'sl'
        // sl<UserFirebaseService>()
        //     .uploadAndChangeAvatar(image)
        //     .then((url) {
        //       // Hiện SnackBar thành công
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Đã thêm ánh đại diện')),
        //       );
        //     })
        //     .catchError((e) {
        //       // Hiện thông báo lỗi
        //       ScaffoldMessenger.of(
        //         context,
        //       ).showSnackBar(SnackBar(content: Text(e.toString())));
        //     });
        // -------------------------------------------
      }
    } catch (e) {
      // Xử lý lỗi (ví dụ chưa cấp quyền)
      SnackBar(content: Text(e.toString()));
    }
  }

  // Hàm hiện BottomSheet chọn nguồn ảnh
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      routeSettings: const RouteSettings(name: '/profile-info'),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Cao vừa đủ
            children: [
              const Text(
                "Chọn ảnh đại diện từ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text("Thư viện ảnh"),
                onTap: () => _onPickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text("Máy ảnh (Chụp mới)"),
                onTap: () => _onPickImage(ImageSource.camera),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode
          ? AppColors.darkBackground
          : Colors.white,
      appBar: const BasicAppbar(
        title: Text(
          'Profile Info',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
              bloc: context.read<ProfileInfoCubit>(),
              builder: (context, state) {
                if (state is ProfileInfoLoading) {
                  return Container(
                    width: 60, // Tương đương radius * 2
                    height: 60,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(child: LoadingScreen()),
                  );
                }

                if (state is ProfileAvatarUploading ||
                    state is ProfileInfoLoaded) {
                  final user = (state is ProfileInfoLoaded)
                      ? state.userEntity
                      : (state as ProfileAvatarUploading).oldUser;
                  final isUploading = state is ProfileAvatarUploading;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              user.avatarUrl != null
                                  ? user.avatarUrl!
                                  : AppUrls.defaultImage,
                            ),
                          ),
                          color: AppColors.grey,
                        ),
                      ),

                      // Lớp phủ Loading khi đang upload
                      if (isUploading)
                        Container(
                          width: 60, // Tương đương radius * 2
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(
                              alpha: 0.5,
                            ), // Làm mờ ảnh cũ đi
                            shape: BoxShape.circle,
                          ),
                          child: const Center(child: LoadingScreen()),
                        ),
                    ],
                  );
                }
                if (state is ProfileInfoFailure) {
                  return Text("Lỗi: ${state.message}");
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _showPickerOptions,
              child: Container(
                height: 40,
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Đổi ảnh đại diện',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const InforAboutYouWidget(),

            const SizedBox(height: 20),
            const AccountInfoWidget(),
          ],
        ),
      ),
    );
  }

  Container accountInfo() {
    return Container();
  }
}
