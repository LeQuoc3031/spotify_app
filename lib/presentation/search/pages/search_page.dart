// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/search/bloc/search_list_cubit.dart';
import 'package:spotify_app/presentation/search/bloc/search_list_state.dart';
import 'package:spotify_app/presentation/search/bloc/search_cubit.dart';
import 'package:spotify_app/presentation/search/widgets/search_song_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    print("User đã quay lại SearchPage - Đang làm mới dữ liệu...");
    context.read<SearchSongCubit>().searchSong(
      context.read<SearchSongCubit>().searchId,
    );
  }
  
  // @override
  // void initState() {
  //   print('SearchPage initState');
  //   context.read<SearchSongCubit>().loadInitialSongs();
  //   super.initState();
  // }

  @override
  void dispose() {
    //hủy đăng ký khi hủy widget
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: const BasicAppbar(
          title: Text('Search', style: TextStyle(fontSize: 16)),
          searchIcon: false,
          isBack: false,
        ),
        body: BlocProvider(
          create: (context) => SearchListCubit()..getPlayList(),
          child: BlocBuilder<SearchListCubit, SearchListState>(
            builder: (context, state) {
              if (state is SearchListLoading) {
                return const LoadingScreen();
              }
              if (state is SearchListLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _searchBar(context),
                      const SizedBox(height: 40),

                      SearchSongList(
                        songs: state.songs,
                        isFetchingMore: state.isFetchingMore,
                        hasMore: state.hasMore,
                      ),

                      // _buildSongGrid(),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    Timer? debounce;

    return TextField(
      controller: context.read<SearchSongCubit>().searchController,
      onChanged: (value) {
        // Mỗi khi người dùng gõ 1 ký tự, hàm này sẽ lưu ký tự vào searchId
        context.read<SearchSongCubit>().searchId = value;
        if (debounce?.isActive ?? false) {
          debounce?.cancel();
        }
        debounce = Timer(const Duration(milliseconds: 500), () {
          // Chỉ khi người dùng ngừng gõ 0.5s mới thực hiện tìm kiếm
          context.read<SearchSongCubit>().searchSong(value);
        });
      },
      // keyboardType: TextInputType.text,
      decoration:
          const InputDecoration(
                hintText: "Tìm bài hát ...",
                prefixIcon: Icon(Icons.search),
              )
              .applyDefaults(Theme.of(context).inputDecorationTheme)
              .copyWith(
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

//   Widget _song(List<SongEntity> songs) {
//     return BlocBuilder<SearchSongCubit, SearchSongState>(
//       builder: (context, state) {
//         if (state is SearchSongLoading) {
//           return const LoadingScreen();
//         }
//         if (state is SearchSongLoaded) {
//           return Expanded(
//             child: ListView.separated(
//               shrinkWrap: true, // Nhớ dùng cái này vì đang trong Column
//               physics: const NeverScrollableScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     context.read<SongPlayerCubit>().loadSongs(
//                       state.songs,
//                       index,
//                       context.read<SearchSongCubit>().searchId,
//                     );
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SongPlayerPage(),
//                       ),
//                     ).then((value) {
//                       if (!context.mounted) return;
//                       context.read<SearchListCubit>().getPlayList();
//                     });
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             height: 45,
//                             width: 45,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: context.isDarkMode
//                                   ? AppColors.darkGrey
//                                   : const Color(0xFFE6E6E6),
//                             ),
//                             child: Icon(
//                               Icons.play_arrow_rounded,
//                               color: context.isDarkMode
//                                   ? const Color(0xFF959595)
//                                   : const Color(0xFF555555),
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 state.songs[index].titleVie,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 state.songs[index].artistVie,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Text(
//                             state.songs[index].duration.toString().replaceAll(
//                               '.',
//                               ':',
//                             ),
//                           ),
//                           const SizedBox(width: 20),
//                           FavoriteButton(songEntity: state.songs[index]),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//               separatorBuilder: (context, index) => const SizedBox(height: 20),
//               itemCount: state.songs.length,
//             ),
//           );
//         }
//         return Expanded(
//           child: ListView.separated(
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               return GestureDetector(
//                 onTap: () {
//                   context.read<SongPlayerCubit>().loadSongs(songs, index, '');
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SongPlayerPage(),
//                     ),
//                   ).then((value) {
//                     // print('state: $value');
//                     if (!context.mounted) return;
//                     context.read<SearchListCubit>().getPlayList();
//                   });
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           height: 45,
//                           width: 45,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: context.isDarkMode
//                                 ? AppColors.darkGrey
//                                 : const Color(0xFFE6E6E6),
//                           ),
//                           child: Icon(
//                             Icons.play_arrow_rounded,
//                             color: context.isDarkMode
//                                 ? const Color(0xFF959595)
//                                 : const Color(0xFF555555),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               songs[index].titleVie,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               songs[index].artistVie,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Text(
//                           songs[index].duration.toString().replaceAll('.', ':'),
//                         ),
//                         const SizedBox(width: 20),
//                         FavoriteButton(songEntity: songs[index]),
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) => const SizedBox(height: 20),
//             itemCount: songs.length,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildSongGrid() {
//     return Expanded(
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2, // 2 Cột
//           crossAxisSpacing: 20, // Khoảng cách ngang giữa các mục
//           mainAxisSpacing: 20, // Khoảng cách dọc giữa các mục
//           // Tỷ lệ khung hình của mỗi mục (Chiều rộng / Chiều cao).
//           // 0.8 giúp mục cao hơn một chút so với rộng, để tên có không gian.
//           childAspectRatio: 1,
//         ),
//         itemCount: 10,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               // Navigator.push(
//               //   context,
//               //   MaterialPageRoute(
//               //     builder: (context) =>
//               //         ArtistProfilePage(artistEntity: state.artists[index]),
//               //   ),
//               // );
//             },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           image: const DecorationImage(
//                             image: NetworkImage(
//                               '${AppUrls.coverFirestorage}Zhao Fang Jing - Hua Yi Shan.jpg?${AppUrls.mediaAlt}',
//                             ),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       Container(
//                         width: double.infinity,
//                         height: double.infinity,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           // color: Colors.black.withValues(alpha: 0.5),
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.transparent,
//                               context.isDarkMode
//                                   ? Colors.black
//                                   : Colors.white54,
//                             ],
//                           ),
//                         ),
//                         child: const Align(
//                           alignment: Alignment.bottomCenter,
//                           child: Text(
//                             'Hoa Sơn Diệc',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(5),
//                         width: double.infinity,
//                         child: SvgPicture.asset(
//                           alignment: Alignment.topRight,
//                           AppVectors.heart,
//                           height: 24,
//                           width: 24,
//                           colorFilter: const ColorFilter.mode(
//                             AppColors.primary,
//                             BlendMode.srcIn,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // const SizedBox(height: 5),
//                 // const Text(
//                 //   'Triệu Phương Tịnh',
//                 //   style: TextStyle(
//                 //     fontSize: 16,
//                 //     fontWeight: FontWeight.w500,
//                 //     overflow: TextOverflow.ellipsis,
//                 //   ),
//                 // ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
}
