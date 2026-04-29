// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/usecases/playlist/create_play_list_usecase.dart';
import 'package:spotify_app/domain/usecases/playlist/delete_play_list_usecase.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/play_list_state.dart';
import 'package:spotify_app/service_locator.dart';

class PlayListWidget extends StatefulWidget {
  const PlayListWidget({super.key});

  @override
  State<PlayListWidget> createState() => _PlayListWidgetState();
}

class _PlayListWidgetState extends State<PlayListWidget> with RouteAware {
  int _wordCount = 0;
  final int _maxWords = 100;
  TextEditingController textEditingController = TextEditingController();
  Set<String> _selectedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    context.read<PlayListCubit>().getPlayList();
  }

  @override
  void didPopNext() {
    print("User đã quay lại ProfilePage - Đang làm mới dữ liệu...");
    context.read<PlayListCubit>().getPlayList();
    _selectedIds = {};
  }

  @override
  void dispose() {
    //hủy đăng ký khi hủy widget
    routeObserver.unsubscribe(this);
    textEditingController.dispose();

    super.dispose();
  }

  void showCreatePlaylistBottomSheet(BuildContext contexty) {
    // Lấy Cubit đang quản lý nhạc hiện tại
    final playListCubit = context.read<PlayListCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Cho phép kéo lên toàn màn hình
      // enableDrag: false,
      // backgroundColor: Colors.transparent,
      builder: (_) {
        // Cung cấp lại Cubit cũ cho giao diện mới
        // return BlocProvider.value(
        //   value: songPlayerCubit,
        //   child: LyricsView(songEntity: songEntity), // Đây là UI Lyric của bạn
        // );
        return BlocProvider.value(
          value: playListCubit,
          child: StatefulBuilder(
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

                            if (!context.mounted) return;
                            // context.read<PlayListCubit>().getPlayList();

                            textEditingController.clear();
                            Navigator.of(context).pop();
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
          ),
        );
      },
    );
  }

  void showDeletePlaylistBottomSheet(BuildContext context) {
    PlayListCubit().getPlayList();
    // final playListcubit = context.read<PlayListCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (_) {
        // Lấy chiều cao của phần tai thỏ (Status Bar)
        final double statusBarHeight = MediaQuery.of(context).padding.top;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              // Tổng chiều cao = Toàn màn hình - Tai thỏ - 40px
              height: MediaQuery.of(context).size.height - statusBarHeight,
              // padding: const EdgeInsets.only(right: 20, left: 20),
              width: double.infinity,
              decoration: const BoxDecoration(
                // color: Color(0xff1C1B1B), // Màu nền tối của bạn
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // Thanh kéo (Handle bar) cho "sang"
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
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
                  // --- PHẦN CHỌN TẤT CẢ ---
                  BlocBuilder<PlayListCubit, PlayListState>(
                    builder: (context, state) {
                      print(state);
                      if (state is PlayListLoaded) {
                        bool isAllSelected =
                            _selectedIds.length == state.playLists.length &&
                            state.playLists.isNotEmpty;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isAllSelected,
                                activeColor: Colors.green,
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      // Thêm tất cả ID vào Set
                                      _selectedIds = state.playLists
                                          .map((e) => e.playlistId)
                                          .toSet();
                                    } else {
                                      _selectedIds.clear();
                                    }
                                  });
                                },
                              ),
                              _selectedIds.length == state.playLists.length
                                  ? Text("Bỏ chọn (${_selectedIds.length})")
                                  : Text(
                                      "Chọn tất cả (${_selectedIds.length})",
                                    ),
                            ],
                          ),
                        );

                        // CheckboxListTile(
                        //   title: Text(
                        //     "Chọn tất cả (${_selectedIds.length})",
                        //     style: const TextStyle(color: Colors.white),
                        //   ),
                        //   value: isAllSelected,
                        //   activeColor: Colors.green,
                        //   onChanged: (val) {
                        //     setModalState(() {
                        //       if (val == true) {
                        //         // Thêm tất cả ID vào Set
                        //         _selectedIds = state.playLists
                        //             .map((e) => e.playlistId)
                        //             .toSet();
                        //       } else {
                        //         _selectedIds.clear();
                        //       }
                        //     });
                        //   },
                        // );
                      }
                      return const SizedBox();
                    },
                  ),

                  // --- DANH SÁCH PLAYLIST ---
                  Expanded(
                    child: BlocBuilder<PlayListCubit, PlayListState>(
                      builder: (context, state) {
                        if (state is PlayListLoading) {
                          return const LoadingScreen();
                        }
                        if (state is PlayListLoaded) {
                          return ListView.builder(
                            itemCount: state.playLists.length,
                            itemBuilder: (context, index) {
                              final playlist = state.playLists[index];
                              final isSelected = _selectedIds.contains(
                                playlist.playlistId,
                              );

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      _selectedIds.remove(playlist.playlistId);
                                    } else {
                                      _selectedIds.add(playlist.playlistId);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: Colors.green,
                                        onChanged: (val) {
                                          setModalState(() {
                                            if (val == true) {
                                              _selectedIds.add(
                                                playlist.playlistId,
                                              );
                                            } else {
                                              _selectedIds.remove(
                                                playlist.playlistId,
                                              );
                                            }
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 80,
                                          decoration: BoxDecoration(
                                            // color: context.isDarkMode
                                            //     ? Colors.grey[900]
                                            //     : AppColors.lightBackground,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                                      BorderRadius.circular(10),
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
                                                      color: context.isDarkMode
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
                                                      color: context.isDarkMode
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
                              // CheckboxListTile(
                              //   title: Text(
                              //     playlist.title,
                              //     style: const TextStyle(color: Colors.white),
                              //   ),
                              //   // secondary: Image.network(playlist.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
                              //   value: isSelected,
                              //   activeColor: Colors.green,
                              //   onChanged: (val) {
                              //     setModalState(() {
                              //       if (val == true) {
                              //         _selectedIds.add(playlist.playlistId);
                              //       } else {
                              //         _selectedIds.remove(playlist.playlistId);
                              //       }
                              //     });
                              //   },
                              // );
                            },
                          );
                        }
                        return const Center(
                          child: Text("Không có playlist nào"),
                        );
                      },
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (_selectedIds.isEmpty) return;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Xóa playlist"),
                            content: const Text(
                              "Bạn có chắc muốn xoá playlist đã chọn?",
                            ),
                            actions: [
                              TextButton(
                                child: const Text("Huỷ"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text("Xóa"),
                                onPressed: () async {
                                  await sl<DeletePlayListUseCase>().call(
                                    params: _selectedIds.toList(),
                                  );
                                  // context
                                  //     .read<PlayListCubit>()
                                  //     .deletePlaylist(
                                  //       selectedIds: _selectedIds.toList(),
                                  //     );
                                  _selectedIds.clear();
                                  if (!context.mounted) return;
                                  // setModalState(() {
                                  context.read<PlayListCubit>().getPlayList();
                                  // });

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      color: context.isDarkMode
                          ? AppColors.darkGrey
                          : Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete,
                            size: 30,
                            color: context.isDarkMode
                                ? _selectedIds.isNotEmpty
                                      ? Colors.white
                                      : Colors.grey
                                : _selectedIds.isNotEmpty
                                ? Colors.black
                                : Colors.grey[400],
                          ),
                          const Text(
                            'Xóa',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayListCubit()..getPlayList(),
      child: SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.grey[900]
                  : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: BlocBuilder<PlayListCubit, PlayListState>(
              bloc: context.read<PlayListCubit>(),
              builder: (context, state) {
                if (state is PlayListLoading) {
                  return const SizedBox(height: 80, child: LoadingScreen());
                }
                if (state is PlayListLoaded && state.playLists.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          left: 15,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Playlist Đã Tạo (${state.playLists.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : AppColors.darkGrey,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      showCreatePlaylistBottomSheet(context),
                                  child: Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: context.isDarkMode
                                        ? Colors.grey
                                        : AppColors.darkGrey,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 15),

                                GestureDetector(
                                  onTap: () =>
                                      showDeletePlaylistBottomSheet(context),
                                  child: SvgPicture.asset(
                                    AppVectors.checkList,
                                    height: 20,
                                    width: 20,
                                    colorFilter: ColorFilter.mode(
                                      context.isDarkMode
                                          ? Colors.grey
                                          : AppColors.darkGrey,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Column(
                        children: state.playLists.map((e) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/playlist',
                                arguments: e,
                              );
                            },
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? Colors.grey[900]
                                    : AppColors.lightBackground,
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
                                      child: SvgPicture.asset(
                                        AppVectors.musicNote,
                                        height: 30,
                                        width: 30,
                                        colorFilter: ColorFilter.mode(
                                          context.isDarkMode
                                              ? Colors.grey
                                              : AppColors.darkGrey,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        e.title,
                                        style: TextStyle(
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${e.songs.length} bài hát',
                                        style: TextStyle(
                                          color: context.isDarkMode
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
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 15,
                        right: 15,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Playlist Đã Tạo (0)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : AppColors.darkGrey,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    showCreatePlaylistBottomSheet(context),
                                child: Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: context.isDarkMode
                                      ? Colors.grey
                                      : AppColors.darkGrey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),

                              SvgPicture.asset(
                                AppVectors.checkList,
                                height: 20,
                                width: 20,
                                colorFilter: ColorFilter.mode(
                                  context.isDarkMode
                                      ? Colors.grey
                                      : AppColors.darkGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showCreatePlaylistBottomSheet(context);
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? Colors.grey[900]
                              : AppColors.lightBackground,
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
                                Text(
                                  'Tạo playlist của riêng bạn',
                                  style: TextStyle(
                                    color: context.isDarkMode
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
