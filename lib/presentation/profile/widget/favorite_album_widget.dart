// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_album_cubit.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_album_state.dart';

class FavoriteAlbumWidget extends StatefulWidget {
  const FavoriteAlbumWidget({super.key});

  @override
  State<FavoriteAlbumWidget> createState() => _FavoriteAlbumWidgetState();
}

class _FavoriteAlbumWidgetState extends State<FavoriteAlbumWidget>
    with RouteAware {
  Set<String> _selectedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void initState() {
    context.read<FavoriteAlbumCubit>().getFavoriteAlbum();
    super.initState();
  }

  @override
  void didPopNext() {
    // print("User đã quay lại ProfilePage - Đang làm mới dữ liệu...");
    context.read<FavoriteAlbumCubit>().getFavoriteAlbum();
    _selectedIds = {};
  }

  @override
  void dispose() {
    //hủy đăng ký khi hủy widget
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void showDeletePlaylistBottomSheet(BuildContext context) {
    context
        .read<FavoriteAlbumCubit>()
        .getFavoriteAlbum(); // Đang làm mới dữ liệu...>
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
                          "Chọn album",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            print("Close");
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                  ),
                  // --- PHẦN CHỌN TẤT CẢ ---
                  BlocBuilder<FavoriteAlbumCubit, FavoriteAlbumState>(
                    builder: (context, state) {
                      print(state);
                      if (state is FavoriteAlbumLoaded) {
                        bool isAllSelected =
                            _selectedIds.length == state.albums.length &&
                            state.albums.isNotEmpty;

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
                                      _selectedIds = state.albums
                                          .map((e) => e.albumFavoriteId!)
                                          .toSet();
                                    } else {
                                      _selectedIds.clear();
                                    }
                                  });
                                },
                              ),
                              _selectedIds.length == state.albums.length
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
                    child: BlocBuilder<FavoriteAlbumCubit, FavoriteAlbumState>(
                      builder: (context, state) {
                        if (state is FavoriteAlbumLoading) {
                          return const LoadingScreen();
                        }
                        if (state is FavoriteAlbumLoaded) {
                          return ListView.builder(
                            itemCount: state.albums.length,
                            itemBuilder: (context, index) {
                              final album = state.albums[index];
                              final isSelected = _selectedIds.contains(
                                album.albumFavoriteId,
                              );

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      _selectedIds.remove(
                                        album.albumFavoriteId,
                                      );
                                    } else {
                                      _selectedIds.add(album.albumFavoriteId!);
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
                                                album.albumFavoriteId!,
                                              );
                                            } else {
                                              _selectedIds.remove(
                                                album.albumFavoriteId,
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
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      '${AppUrls.albumFirestorage}${album.title}.jpg?${AppUrls.mediaAlt}',
                                                    ),
                                                    fit: BoxFit.cover,
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
                                                    album.titleVie,
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
                                                    album.artistVie,
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
                                  // await sl<DeletePlayListUseCase>().call(
                                  //   params: _selectedIds.toList(),
                                  // );
                                  // context
                                  //     .read<PlayListCubit>()
                                  //     .deletePlaylist(
                                  //       selectedIds: _selectedIds.toList(),
                                  //     );

                                  context.read<FavoriteAlbumCubit>().removeSong(
                                    _selectedIds.toList(),
                                  );
                                  print('_selectedIds: $_selectedIds');
                                  _selectedIds.clear();
                                  if (!context.mounted) return;
                                  // setModalState(() {
                                  // context.read<PlayListCubit>().getPlayList();
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
      create: (context) => FavoriteAlbumCubit()..getFavoriteAlbum(),
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
            child: BlocBuilder<FavoriteAlbumCubit, FavoriteAlbumState>(
              bloc: context.read<FavoriteAlbumCubit>(),
              builder: (context, state) {
                if (state is FavoriteAlbumLoading) {
                  return const SizedBox(height: 80, child: LoadingScreen());
                }
                if (state is FavoriteAlbumLoaded && state.albums.isNotEmpty) {
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
                              'Album yêu thích (${state.albums.length})',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : AppColors.darkGrey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDeletePlaylistBottomSheet(context);
                              },
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
                      ),

                      Column(
                        children: state.albums.map((e) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/album',
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
                                  const SizedBox(width: 15),
                                  Container(
                                    height: 55,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          '${AppUrls.albumFirestorage}${e.title}.jpg?${AppUrls.mediaAlt}',
                                        ),
                                        fit: BoxFit.cover,
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
                                        e.titleVie,
                                        style: TextStyle(
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        e.artistVie,
                                        style: TextStyle(
                                          color: context.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
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
                            'Album yêu thích (0)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.isDarkMode
                                  ? Colors.white
                                  : AppColors.darkGrey,
                            ),
                          ),
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
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.darkGrey
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          AppVectors.alertSquare,
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
                    const SizedBox(height: 10),
                    Text(
                      'Không có dữ liệu!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: context.isDarkMode
                            ? Colors.white
                            : AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Khám phá và lưu những album bạn thích',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.isDarkMode
                            ? Colors.grey
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
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
