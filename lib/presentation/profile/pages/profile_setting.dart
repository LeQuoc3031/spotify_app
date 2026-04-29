import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/presentation/auth/bloc/auth_cubit.dart';
import 'package:spotify_app/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';

class ProfileSettingPage extends StatelessWidget {
  const ProfileSettingPage({super.key});

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      routeSettings: const RouteSettings(name: '/setting'),
      builder: (context) {
        // Giả sử bạn đang dùng ThemeCubit để quản lý state của Theme
        // Nếu dùng Theme.of(context).brightness cũng được nhưng Cubit sẽ chuẩn hơn
        final currentTheme = Theme.of(context).brightness;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Để sheet cao vừa đủ nội dung
            children: [
              const Text(
                'Chọn giao diện',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Lựa chọn Chế độ sáng
              _buildThemeOption(
                context,
                title: "Chế độ sáng",
                isSelected: currentTheme == Brightness.light,
                onTap: () {
                  context.read<ThemeCubit>().updateTheme(ThemeMode.light);
                  // Logic đổi sang Light Mode ở đây
                  Navigator.pop(context);
                },
              ),

              // Lựa chọn Chế độ tối
              _buildThemeOption(
                context,
                title: "Chế độ tối",
                isSelected: currentTheme == Brightness.dark,
                onTap: () {
                  // Logic đổi sang Dark Mode ở đây
                  context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.green : null, // Đổi màu chữ nếu đang chọn
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      // Đây là phần dấu tick ở cuối hàng
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode
          ? AppColors.darkBackground
          : Colors.white,
      appBar: const BasicAppbar(
        title: Text('Setting', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Tài khoản',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile-info');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.lightBackground,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Thông tin cá nhân',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 16),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Hiển thị',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.darkGrey
                          : AppColors.lightBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _showThemeSelector(context),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text(
                                'Giao diện',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Text(
                                context.isDarkMode ? 'Dark' : 'Light',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            SizedBox(width: 10),
                            Text(
                              'Ngôn ngữ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 16),
                            SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () {
                  context.read<SongPlayerCubit>().resetPlayer();
                  context.read<AuthCubit>().logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signup-signin',
                    (route) => false,
                  );
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const SignupOrSigninPage(),
                  //   ),
                  //   (route) => false,
                  // );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.darkGrey
                        : AppColors.lightBackground,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Center(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
