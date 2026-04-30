// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/profile/widget/favorite_album_widget.dart';
import 'package:spotify_app/presentation/profile/widget/favorite_song_widget.dart';
import 'package:spotify_app/presentation/profile/widget/play_list_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    print("User đã quay lại ProfilePage - Đang làm mới dữ liệu...");

    context.read<ProfileInfoCubit>().getUser();
  }

  @override
  void dispose() {
    //hủy đăng ký khi hủy widget
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FavoriteSongCubit()..getFavoriteSong(),
        ),
        BlocProvider(create: (context) => ProfileInfoCubit()..getUser()),
      ],
      child: Scaffold(
        backgroundColor: context.isDarkMode
            ? AppColors.darkBackground
            : Colors.white,
        body: CustomScrollView(
          slivers: [
            // 1. SliverAppBar để chứa ảnh và các lớp phủ
            SliverAppBar(
              backgroundColor: Colors.transparent, // AppBar trong suốt
              elevation: 0,

              actions: _setting(context),
              // Đặt độ cao mong muốn cho khu vực ảnh
              expandedHeight: MediaQuery.of(context).size.height / 3.0,
              pinned: false, // Để nó cuộn đi khi vuốt lên
              // FlexibleSpaceBar là nơi chứa nội dung thay đổi theo độ mở
              flexibleSpace: FlexibleSpaceBar(
                background: _profileInfo(context),
              ),
            ),

            const FavoriteSongWidget(),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const PlayListWidget(),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const FavoriteAlbumWidget(),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _profileInfo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            context.isDarkMode ? AppColors.darkBackground : Colors.white,
          ],
        ),
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: SvgPicture.asset(AppVectors.topProfilePattern),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topPattern),
          ),
          BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
            bloc: context.read<ProfileInfoCubit>(),
            builder: (context, state) {
              if (state is ProfileInfoLoading) {
                return const LoadingScreen();
              }
              if (state is ProfileInfoLoaded) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(state.userEntity.avatarUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(state.userEntity.email!),
                    const SizedBox(height: 10),
                    Text(
                      state.userEntity.fullName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                );
              }

              if (state is ProfileInfoFailure) {
                return const Center(child: Text('Please try again'));
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _setting(BuildContext context) {
    return [
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/setting');
        },
        child: Icon(
          Icons.settings,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      ),

      Container(width: 20),
    ];
  }

//   List<Widget> _popUpMenu(BuildContext context) {
//     return [
//       PopupMenuButton<String>(
//         icon: Icon(
//           Icons.more_vert,
//           color: context.isDarkMode ? Colors.white : Colors.black,
//         ), // Icon ba chấm
//         color:
//             Colors.black, // Màu nền của popup (dark grey cho hợp tông Spotify)
//         onSelected: (value) {
//           if (value == 'mode') {
//             // Thực hiện logic đổi theme ở đây
//             print("Đổi chế độ sáng/tối");
//             if (context.isDarkMode) {
//               context.read<ThemeCubit>().updateTheme(ThemeMode.light);
//             } else {
//               context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
//             }
//           } else if (value == 'logout') {
//             // Thực hiện logic đăng xuất ở đây
//             context.read<AuthCubit>().logout();
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const SignupOrSigninPage(),
//               ),
//               (route) => false,
//             );
//             print("Đăng xuất");
//           }
//         },
//         itemBuilder: (BuildContext context) {
//           // Kiểm tra chế độ tối hiện tại của app

//           return [
//             PopupMenuItem<String>(
//               value: 'mode',
//               child: Row(
//                 children: [
//                   Icon(
//                     context.isDarkMode ? Icons.light_mode : Icons.dark_mode,
//                     color: Colors.white,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     context.isDarkMode ? 'Light Mode' : 'Dark Mode',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//             const PopupMenuItem<String>(
//               value: 'logout',
//               child: Row(
//                 children: [
//                   Icon(Icons.logout, color: Colors.redAccent),
//                   SizedBox(width: 10),
//                   Text('Logout', style: TextStyle(color: Colors.redAccent)),
//                 ],
//               ),
//             ),
//           ];
//         },
//       ),
//     ];
//   }
}
