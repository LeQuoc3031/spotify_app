// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/data/models/playlist/remove_song_from_playlist_req.dart';
import 'package:spotify_app/domain/entities/playlist/play_list.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_state.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';
import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';

class PlayListSongPage extends StatefulWidget {
  final PlayListEntity playlistEntity;
  const PlayListSongPage({super.key, required this.playlistEntity});

  @override
  State<PlayListSongPage> createState() => _PlayListSongPageState();
}

class _PlayListSongPageState extends State<PlayListSongPage> with RouteAware {
  List<SongEntity> songList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    context.read<PlayListCubit>().getSongInPlayList(widget.playlistEntity);
    super.initState();
  }

  @override
  void didPopNext() {
    print("User đã quay lại PlayListSongPage - Đang làm mới dữ liệu...");
    // context.read<PlayListCubit>().getSongInPlayList(widget.playlistEntity);
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
          create: (context) =>
              PlayListCubit()..getSongInPlayList(widget.playlistEntity),
        ),
        BlocProvider(create: (context) => ProfileInfoCubit()..getUser()),
      ],
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
                icon: Icon(
                  Icons.arrow_back,
                  color: context.isDarkMode ? Colors.white : Colors.black,
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
                background: _buildBlurredAlbumHeader(context),
                // collapseMode.fade: phần header sẽ mờ dần khi kéo lên
                collapseMode: CollapseMode.parallax,
              ),
            ),

            // 2. PHẦN DANH SÁCH BÀI HÁT (Lướt thoải mái)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: BlocBuilder<PlayListCubit, PlayListState>(
                bloc: context.read<PlayListCubit>(),
                builder: (context, state) {
                  print('state ==> $state');
                  if (state is LoadingSongInPlayList) {
                    return const SliverToBoxAdapter(child: LoadingScreen());
                  }
                  if (state is LoadedSongInPlayList) {
                    print('state ==> ${state.songs.length}');
                    return state.songs.isEmpty
                        ? const SliverToBoxAdapter(child: SizedBox())
                        : SliverList.separated(
                            // Hàm trả về Widget từng bài hát
                            itemBuilder: (context, index) => Slidable(
                              key: ValueKey(state.songs[index].songId),
                              // Cấu hình phía bên phải (vuốt từ phải sang trái)
                              endActionPane: ActionPane(
                                // Motion: Cách các nút xuất hiện (ScrollMotion, BehindMotion, DrawerMotion...)
                                motion: const ScrollMotion(),

                                // Tỷ lệ chiếm dụng màn hình (ví dụ: 0.25 là 25% chiều rộng)
                                // Điều này giúp nút không chiếm hết UI và không tự lướt đi hết
                                extentRatio: 0.25,

                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      // Logic xoá bài hát ở đây
                                      // context
                                      //     .read<PlayListCubit>()
                                      //     .removeSongFromPlaylist(
                                      //       playlistId: currentPlaylistId,
                                      //       songId: song.songId,
                                      //     );
                                      //  context
                                      //               .read<PlayListCubit>()
                                      //               .removeSongFromPlaylist(
                                      //                 req: RemoveSongFromPlaylistReq(
                                      //                   playlistId: widget
                                      //                       .playlistEntity
                                      //                       .playlistId,
                                      //                   songId: state
                                      //                       .songs[index]
                                      //                       .songId!,
                                      //                 ),
                                      //                 playlistEntity:
                                      //                     widget.playlistEntity,
                                      //               );

                                      showDialog(
                                        context: context,
                                        routeSettings: const RouteSettings(
                                          name: '/playlist',
                                        ),
                                        builder: (context) => AlertDialog(
                                          title: const Text("Xác nhận"),
                                          content: const Text(
                                            "Bạn có muốn xoá bài hát này khỏi playlist?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Hủy"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                context
                                                    .read<PlayListCubit>()
                                                    .removeSongFromPlaylist(
                                                      req:
                                                          RemoveSongFromPlaylistReq(
                                                            playlistId: widget
                                                                .playlistEntity
                                                                .playlistId,
                                                            songId: state
                                                                .songs[index]
                                                                .songId!,
                                                          ),
                                                      // playlistEntity:
                                                      //     widget.playlistEntity,
                                                    );
                                                //  sl<
                                                //       RemoveSongFromPlaylistUseCase
                                                //     >()
                                                //     .call(
                                                //       params:
                                                //           RemoveSongFromPlaylistReq(
                                                //             playlistId: widget
                                                //                 .playlistEntity
                                                //                 .playlistId,
                                                //             songId: state
                                                //                 .songs[index]
                                                //                 .songId!,
                                                //           ),
                                                //     );
                                                // if (!context.mounted) return;

                                                // context
                                                //     .read<PlayListCubit>()
                                                //     .getSongInPlayList(
                                                //       widget.playlistEntity.copyWith(
                                                //         playlistId: widget
                                                //             .playlistEntity
                                                //             .playlistId,
                                                //         songs:
                                                //             widget
                                                //                 .playlistEntity
                                                //                 .songs
                                                //               ..remove(
                                                //                 state
                                                //                     .songs[index]
                                                //                     .songId,
                                                //               ),
                                                //       ),
                                                //     );

                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Xoá"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },

                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Xoá',
                                    // borderRadius: BorderRadius.circular(8), // Nếu bạn muốn nút bo góc
                                  ),
                                ],
                              ),
                              child: _songs(context, state, index),
                            ),
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

  GestureDetector _songs(
    BuildContext context,
    LoadedSongInPlayList state,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SongPlayerCubit>().loadSongs(
          state.songs,
          index,
          'allSong${widget.playlistEntity.playlistId}',
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
          context.read<PlayListCubit>().getSongInPlayList(
            widget.playlistEntity,
          );
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

  Widget _buildBlurredAlbumHeader(BuildContext context) {
    return Stack(
      children: [
        BlocBuilder<PlayListCubit, PlayListState>(
          bloc: context.read<PlayListCubit>(),
          builder: (context, state) {
            if (state is LoadedSongInPlayList && state.songs.isNotEmpty) {
              final songEntity = state.songs.first;
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      '${AppUrls.coverFirestorage}${songEntity.artist} - ${songEntity.title}.jpg?${AppUrls.mediaAlt}',
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
              );
            }
            return Container(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter,
              //     colors: [
              //       context.isDarkMode ? Colors.grey : Colors.white,
              //       Colors.transparent,
              //     ],
              //   ),
              // ),
            );
          },
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
              BlocBuilder<PlayListCubit, PlayListState>(
                bloc: context.read<PlayListCubit>(),
                builder: (context, state) {
                  if (state is LoadedSongInPlayList && state.songs.isNotEmpty) {
                    final songEntity = state.songs.first;
                    return Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            '${AppUrls.coverFirestorage}${songEntity.artist} - ${songEntity.title}.jpg?${AppUrls.mediaAlt}',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black45,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.darkGrey
                          : AppColors.grey,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black45,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        AppVectors.musicNote,
                        height: 80,
                        width: 80,
                        colorFilter: ColorFilter.mode(
                          context.isDarkMode ? Colors.grey : AppColors.darkGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              ),
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
                  'Playlist',
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.playlistEntity.title,
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                BlocBuilder<ProfileInfoCubit, ProfileInfoState>(
                  builder: (context, state) {
                    if (state is ProfileInfoLoading) {
                      //Dùng để tránh UI bị giật giật Khi tên user chưa loading xong
                      return Container(height: 20);
                    }
                    if (state is ProfileInfoLoaded) {
                      return SizedBox(
                        height: 20,
                        child: Text(
                          '${state.userEntity.fullName}',
                          style: TextStyle(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppVectors.heart,
                          colorFilter: ColorFilter.mode(
                            context.isDarkMode ? Colors.white : Colors.black,
                            BlendMode.srcIn,
                          ),
                          height: 26,
                          width: 26,
                        ),
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

                    BlocBuilder<PlayListCubit, PlayListState>(
                      builder: (context, state) {
                        if (state is LoadedSongInPlayList) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  context.read<SongPlayerCubit>().loadSongs(
                                    state.songs,
                                    Random().nextInt(state.songs.length),
                                    'shuffleSong${widget.playlistEntity.playlistId}',
                                  );

                                  context.read<SongPlayerCubit>().shuffleSong();

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context
                                        .read<PlayListCubit>()
                                        .getSongInPlayList(
                                          widget.playlistEntity,
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
                                onTap: () {
                                  context.read<SongPlayerCubit>().loadSongs(
                                    state.songs,
                                    0,
                                    // Random().nextInt(state.songs.length),
                                    'allSong${widget.playlistEntity.playlistId}',
                                  );

                                  if (!context.mounted) return;
                                  Navigator.pushNamed(context, '/player').then((
                                    value,
                                  ) {
                                    // print('state: $value');
                                    if (!context.mounted) return;
                                    context
                                        .read<PlayListCubit>()
                                        .getSongInPlayList(
                                          widget.playlistEntity,
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
