import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button_album.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/album/album.dart';
import 'package:spotify_app/presentation/album/bloc/album_cubit.dart';
import 'package:spotify_app/presentation/album/bloc/album_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';

class AlbumPage extends StatefulWidget {
  final AlbumEntity albumEntity;
  const AlbumPage({super.key, required this.albumEntity});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  var st = SongPlayerCubit();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AlbumCubit()..getAlbumSongs(widget.albumEntity.albumId!),
      child: Scaffold(
        backgroundColor: context.isDarkMode
            ? Colors.black
            : Colors.white, // Đặt nền đen sâu
        body: CustomScrollView(
          slivers: [
            // 1. SliverAppBar mới, chứa tất cả thông tin header
            SliverAppBar(
              expandedHeight: 450, // Chiều cao tối đa để chứa ảnh và nút
              backgroundColor: context.isDarkMode
                  ? Colors.black
                  : Colors.white, // AppBar trong suốt
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ), // Nút back
                onPressed: () =>
                    Navigator.of(context).pop(), // Xử lý sự kiện back
              ),
              actions: [],
              // flexibleSpace là nơi Flutter tự động xử lý hiệu ứng "mờ dần"
              flexibleSpace: FlexibleSpaceBar(
                // Tiêu đề nhỏ hiện ra khi app bar bị thu nhỏ
                // title: const Text(
                //   'Album detail',
                //   style: TextStyle(color: Colors.white, fontSize: 16),
                // ),
                centerTitle: true,
                // Đặt tất cả phần background được làm mờ vào đây
                background: _buildBlurredAlbumHeader(
                  context,
                  widget.albumEntity,
                ),
                // collapseMode.fade: phần header sẽ mờ dần khi kéo lên
                collapseMode: CollapseMode.parallax,
              ),
            ),

            // 2. PHẦN DANH SÁCH BÀI HÁT (Lướt thoải mái)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: BlocBuilder<AlbumCubit, AlbumState>(
                builder: (context, state) {
                  if (state is AlbumLoading) {
                    return const SliverToBoxAdapter(
                      child: LoadingScreen()
                    );
                  }
                  if (state is AlbumLoaded) {
                    return SliverList.separated(
                      // Hàm trả về Widget từng bài hát
                      itemBuilder: (context, index) =>
                          _songs(context, state, index),
                      itemCount: state.songs.length,
                      separatorBuilder: (context, index) {
                        // Khoảng cách giữa các bài hát (không xuất hiện sau item cuối cùng)
                        return const SizedBox(height: 20);
                      },
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 300)),
          ],
        ),
      ),
    );
  }

  GestureDetector _songs(BuildContext context, AlbumLoaded state, int index) {
    return GestureDetector(
      onTap: () {
        context.read<SongPlayerCubit>().loadSongs(
          state.songs,
          index,
          'allSong',
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const SongPlayerPage()),
        // ).then((value) {
        //   // print('state: $value');
        //   if (!context.mounted) return;
        //   context.read<AlbumCubit>().getAlbumSongs(widget.albumEntity.albumId!);
        // });

        Navigator.pushNamed(context, '/player').then((value) {
          // print('state: $value');
          if (!context.mounted) return;
          context.read<AlbumCubit>().getAlbumSongs(widget.albumEntity.albumId!);
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(
                      '${AppUrls.coverFirestorage}${state.songs[index].artist} - ${state.songs[index].title}.jpg?${AppUrls.mediaAlt}',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.songs[index].title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    state.songs[index].artist,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Row(
            children: [
              Text(state.songs[index].duration.toString().replaceAll('.', ':')),
              const SizedBox(width: 20),
              FavoriteButton(songEntity: state.songs[index]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredAlbumHeader(
    BuildContext context,
    AlbumEntity albumEntity,
  ) {
    return Stack(
      children: [
        // 1. Ảnh nền Full màn hình được làm mờ (Giống logic của bạn)
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                '${AppUrls.albumFirestorage}${albumEntity.title}.jpg?${AppUrls.mediaAlt}',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Độ mờ
            child: Container(
              color: context.isDarkMode
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.4), // Nền đen (0.4),
            ), // Lớp phủ tối
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                context.isDarkMode ? Colors.black : Colors.white,
              ],
            ),
          ),
        ),

        // 2. PHẦN NỘI DUNG HEADER NẰM TRÊN CÙNG
        Positioned(
          top: 80, // Cách AppBar một khoảng
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            children: [
              // Ảnh album chính và bo góc
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  image: DecorationImage(
                    image: NetworkImage(
                      '${AppUrls.albumFirestorage}${albumEntity.title}.jpg?${AppUrls.mediaAlt}',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
              ),

              // Tên nghệ sĩ và Album
              // HÀNG NÚT: Favorite, Comment, Shuffle
            ],
          ),
        ),
        Positioned(
          top: 300,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Album',
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${albumEntity.titleVie} (${albumEntity.title})',
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  albumEntity.artist,
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SvgPicture.asset(
                        //   AppVectors.heart,
                        //   colorFilter: ColorFilter.mode(
                        //     context.isDarkMode ? Colors.white : Colors.black,
                        //     BlendMode.srcIn,
                        //   ),
                        //   height: 26,
                        //   width: 26,
                        // ),
                        FavoriteButtonAlbum(albumEntity: albumEntity),
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          AppVectors.chatIcon,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
                        const SizedBox(width: 20),
                        SvgPicture.asset(
                          AppVectors.shareIcon,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),

                    BlocBuilder<AlbumCubit, AlbumState>(
                      builder: (context, state) {
                        if (state is AlbumLoaded) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<SongPlayerCubit>().loadSongs(
                                    state.songs,
                                    Random().nextInt(state.songs.length),
                                    // Random().nextInt(state.songs.length),
                                    'shuffleSong',
                                  );

                                  context.read<SongPlayerCubit>().shuffleSong();

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context.read<AlbumCubit>().getAlbumSongs(
                                      widget.albumEntity.albumId!,
                                    );
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: context.isDarkMode
                                        ? AppColors.darkGrey
                                        : AppColors.grey,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      AppVectors.shuffleIcon,
                                      colorFilter: ColorFilter.mode(
                                        context.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 20,
                                      width: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: ()  {
                                   context
                                      .read<SongPlayerCubit>()
                                      .loadSongs(
                                        state.songs,
                                        0,
                                        // Random().nextInt(state.songs.length),
                                        'allSong',
                                      );

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context.read<AlbumCubit>().getAlbumSongs(
                                      widget.albumEntity.albumId!,
                                    );
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      const Icon(Icons.play_arrow),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Text(
                                          'Tất cả',
                                          style: TextStyle(
                                            color: context.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.grey,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppVectors.shuffleIcon,
                                  colorFilter: ColorFilter.mode(
                                    context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  const Icon(Icons.play_arrow),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      'Tất cả',
                                      style: TextStyle(
                                        color: context.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
