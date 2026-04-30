// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_app/common/helpers/format_duration.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/data/models/playlist/add_song_to_playlist_req.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/playlist/create_play_list_usecase.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_state.dart';
import 'package:spotify_app/presentation/song_player/widgets/lyric_view.dart';
import 'package:spotify_app/service_locator.dart';

class SongPlayerPage extends StatefulWidget {
  // final SongEntity songEntity;
  const SongPlayerPage({super.key});

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  double? dragValue;
  int _wordCount = 0;
  final int _maxWords = 100;
  TextEditingController textEditingController = TextEditingController();

  void showLyricsBottomSheet(BuildContext context, SongEntity songEntity) {
    // Lấy Cubit đang quản lý nhạc hiện tại
    final songPlayerCubit = context.read<SongPlayerCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép kéo lên toàn màn hình
      routeSettings: const RouteSettings(name: '/player'),
      // enableDrag: false,
      // backgroundColor: Colors.transparent,
      builder: (_) {
        // Cung cấp lại Cubit cũ cho giao diện mới
        return BlocProvider.value(
          value: songPlayerCubit,
          child: LyricsView(songEntity: songEntity), // Đây là UI Lyric của bạn
        );
      },
    );
  }

  void showAddPlaylistBottomSheet(BuildContext context, SongEntity songEntity) {
    final playListCubit = context.read<PlayListCubit>();
    context.read<PlayListCubit>().getPlayList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      routeSettings: const RouteSettings(name: '/player'),
      // backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: playListCubit,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                // Tổng chiều cao = Toàn màn hình - Tai thỏ - 40px
                height: MediaQuery.of(context).size.height - 40,
                // padding: const EdgeInsets.only(right: 20, left: 20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  // color: Color(0xff1C1B1B), // Màu nền tối của bạn
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thanh kéo (Handle bar) cho "sang"
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            "Chọn playlist",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.close, size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: const Text(
                        "Chọn playlist để thêm bài hát vào",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        showCreatePlaylistBottomSheet(context, songEntity);
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          // color: context.isDarkMode
                          //     ? Colors.grey[900]
                          //     : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              margin: const EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? AppColors.darkGrey
                                    : AppColors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : AppColors.darkGrey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tạo playlist',
                                  style: TextStyle(
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- DANH SÁCH PLAYLIST ---
                    Expanded(
                      child: BlocConsumer<PlayListCubit, PlayListState>(
                        listener: (context, state) {
                          if (state is AddSongToPlaylistSuccess) {
                            // Hiển thị SnackBar (Cách chuẩn của Flutter)
                            context.read<PlayListCubit>().getPlayList();
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          } else if (state is AddSongToPlaylistFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.errorMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is PlayListLoading) {
                            return const LoadingScreen();
                          }
                          if (state is PlayListLoaded) {
                            return ListView.builder(
                              itemCount: state.playLists.length,
                              itemBuilder: (context, index) {
                                final playlist = state.playLists[index];

                                return GestureDetector(
                                  onTap: () {
                                    context
                                        .read<PlayListCubit>()
                                        .addSongToPlaylist(
                                          params: AddSongToPlaylistReq(
                                            playlistId: playlist.playlistId,
                                            songId: songEntity.songId!,
                                          ),
                                        );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 55,
                                                  width: 55,
                                                  margin: const EdgeInsets.only(
                                                    left: 15,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: context.isDarkMode
                                                        ? AppColors.darkGrey
                                                        : AppColors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: SvgPicture.asset(
                                                      AppVectors.musicNote,
                                                      height: 30,
                                                      width: 30,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                            context.isDarkMode
                                                                ? Colors.grey
                                                                : AppColors
                                                                      .darkGrey,
                                                            BlendMode.srcIn,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      playlist.title,
                                                      style: TextStyle(
                                                        color:
                                                            context.isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${playlist.songs.length} bài hát',
                                                      style: TextStyle(
                                                        color:
                                                            context.isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                            child: Text("Không có playlist nào"),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showCreatePlaylistBottomSheet(
    BuildContext contexty,
    SongEntity songEntity,
  ) {
    // Lấy Cubit đang quản lý nhạc hiện tại

    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Cho phép kéo lên toàn màn hình
      routeSettings: const RouteSettings(name: '/player'),
      // enableDrag: false,
      // backgroundColor: Colors.transparent,
      builder: (_) {
        // Cung cấp lại Cubit cũ cho giao diện mới
        // return BlocProvider.value(
        //   value: songPlayerCubit,
        //   child: LyricsView(songEntity: songEntity), // Đây là UI Lyric của bạn
        // );
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.only(right: 20, left: 20, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          "Tạo playlist mới",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: textEditingController,
                      maxLines: 1,
                      onChanged: (value) {
                        setModalState(() {
                          // Logic đếm từ:
                          // 1. trim(): Xóa khoảng trắng thừa ở đầu và cuối.
                          // 2. split(RegExp(r'\s+')): Tách chuỗi bởi một hoặc nhiều khoảng trắng.
                          if (value.trim().isEmpty) {
                            _wordCount = 0;
                          } else {
                            _wordCount = value.replaceAll(' ', '').length;
                          }
                        });
                      },

                      decoration:
                          const InputDecoration(hintText: 'Nhập tên playlist')
                              .applyDefaults(
                                Theme.of(context).inputDecorationTheme,
                              )
                              .copyWith(
                                counterText: '$_wordCount/$_maxWords',
                                counterStyle: TextStyle(
                                  // Nếu quá 100 từ thì đổi màu đỏ để cảnh báo
                                  color: _wordCount > _maxWords
                                      ? Colors.red
                                      : Colors.grey,
                                  fontSize: 12,
                                ),
                                contentPadding: const EdgeInsets.all(20),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();

                        if (textEditingController.text.isNotEmpty) {
                          await sl<CreatePlayListUseCase>().call(
                            params: textEditingController.text,
                          );

                          // await sl<AddSongToPlaylistUseCase>().call(
                          //   params: AddSongToPlaylistReq(
                          //     songId: songEntity.songId!,
                          //     playlistId: textEditingController.text,
                          //   ),
                          // );
                          if (!context.mounted) return;
                          context.read<PlayListCubit>().getPlayList();

                          textEditingController.clear();
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: textEditingController.text.isNotEmpty
                            ? AppColors.primary
                            : AppColors.darkBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Tạo playlist'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text('Now playing', style: TextStyle(fontSize: 16)),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: BlocBuilder<SongPlayerCubit, SongPlayerState>(
        builder: (context, state) {
          print('state: $state');
          var duration = context.read<SongPlayerCubit>().songDuration;
          if (state is SongPlayerLoading || duration == Duration.zero) {
            return const Align(
              alignment: Alignment.center,
              child: LoadingScreen(),
            );
          }

          if (state is SongPlayerLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  _songCover(context, state),
                  const SizedBox(height: 20),

                  _songDetail(state),
                  const SizedBox(height: 30),

                  _songPlayer(context, state),
                  const SizedBox(height: 30),
                  _songLyric(context, state),
                ],
              ),
            );
          }

          return const Center(child: Text('Error'));
        },
      ),
    );
  }

  Widget _songLyric(BuildContext context, SongPlayerLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.person,
            color: context.isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () {},
        ),
        GestureDetector(
          onTap: () {
            context.read<SongPlayerCubit>().loadLyrics(
              '${AppUrls.lyricFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.lrc.txt?${AppUrls.mediaAlt}',
              state.songEntity!,
            );
            showLyricsBottomSheet(context, state.songEntity!);
          },
          child: Column(
            children: [
              Icon(
                Icons.keyboard_arrow_up,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              Text(
                "Lyrics",
                style: TextStyle(
                  color: context.isDarkMode
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.playlist_add,
            color: context.isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () {
            showAddPlaylistBottomSheet(context, state.songEntity!);
          },
        ),
      ],
    );
  }

  Widget _songCover(BuildContext context, SongPlayerLoaded state) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            '${AppUrls.coverFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.jpg?${AppUrls.mediaAlt}',
          ),
        ),
      ),
    );
  }

  Widget _songDetail(SongPlayerLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.songEntity!.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              state.songEntity!.artist,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
            ),
          ],
        ),

        FavoriteButton(songEntity: state.songEntity!),
      ],
    );
  }

  Widget _songPlayer(BuildContext context, SongPlayerLoaded state) {
    return Column(
      children: [
        Slider(
          padding: const EdgeInsets.all(0),
          value:
              dragValue ??
              context
                  .read<SongPlayerCubit>()
                  .songtPosition
                  .inSeconds
                  .toDouble(),
          min: 0.0,
          max: context
              .read<SongPlayerCubit>()
              .songDuration
              .inSeconds
              .toDouble(),
          onChanged: (value) {
            setState(() {
              dragValue = value; // Đang kéo thì giữ giá trị của tay người dùng
            });
          },
          onChangeEnd: (value) {
            context.read<SongPlayerCubit>().seek(
              Duration(seconds: value.toInt()),
            );
            setState(() {
              dragValue =
                  null; // Buông tay thì trả lại quyền điều khiển cho Cubit
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatDuration(
                dragValue != null
                    ? Duration(seconds: dragValue!.toInt())
                    : context.read<SongPlayerCubit>().songtPosition,
              ),
            ),

            Text(formatDuration(context.read<SongPlayerCubit>().songDuration)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                context.read<SongPlayerCubit>().repeateSong();
              },
              child: SvgPicture.asset(
                AppVectors.repeateIcon,
                colorFilter: context.read<SongPlayerCubit>().isRepeate
                    ? const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)
                    : ColorFilter.mode(
                        context.isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                height: 25,
                width: 25,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.skip_previous,
                color: context.isDarkMode ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: () => context.read<SongPlayerCubit>().previousSong(),
            ),
            GestureDetector(
              onTap: () {
                context.read<SongPlayerCubit>().playOrPauseSong(
                  state.songEntity!,
                );
                context.read<SongPlayerCubit>().loadLyrics(
                  '${AppUrls.lyricFirestorage}${state.songEntity?.artist} - ${state.songEntity?.title}.lrc.txt?${AppUrls.mediaAlt}',
                  state.songEntity!,
                );
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  state.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 30,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.skip_next,
                color: context.isDarkMode ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: () => context.read<SongPlayerCubit>().nextSong(),
            ),
            GestureDetector(
              onTap: () {
                context.read<SongPlayerCubit>().shuffleSong();
              },
              child: SvgPicture.asset(
                AppVectors.shuffleIcon,
                colorFilter: context.read<SongPlayerCubit>().isShuffle
                    ? const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)
                    : ColorFilter.mode(
                        context.isDarkMode ? Colors.white : Colors.black,
                        BlendMode.srcIn,
                      ),
                height: 25,
                width: 25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
