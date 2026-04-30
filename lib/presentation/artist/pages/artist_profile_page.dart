// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/helpers/is_dark_mode_ext.dart';
import 'package:spotify_app/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/domain/entities/artist/artist.dart';
import 'package:spotify_app/main.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_album_cubit.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_album_state.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_song_cubit.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_song_state.dart';
import 'package:spotify_app/presentation/song_player/bloc/song_player_cubit.dart';

class ArtistProfilePage extends StatefulWidget {
  final ArtistEntity artistEntity;
  const ArtistProfilePage({super.key, required this.artistEntity});

  @override
  State<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends State<ArtistProfilePage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    print("User đã quay lại ArtistProfilePage - Đang làm mới dữ liệu...");
    context.read<ArtistSongCubit>().getArtistSong(widget.artistEntity.id);
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
              ArtistSongCubit()..getArtistSong(widget.artistEntity.id),
        ),

        BlocProvider(
          create: (context) =>
              ArtistAlbumCubit()..getArtistAlbum(widget.artistEntity.id),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.isDarkMode
            ? Colors.black
            : Colors.white, 
        body: CustomScrollView(
          slivers: [
            // 1. SliverAppBar để chứa ảnh và các lớp phủ
            SliverAppBar(
              backgroundColor: Colors.transparent, // AppBar trong suốt
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(), // Xử lý quay lại
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {}, 
                ),
              ],
              // Đặt độ cao mong muốn cho khu vực ảnh
              expandedHeight: MediaQuery.of(context).size.height / 2.5,
              pinned: false, // Để nó cuộn đi khi vuốt lên
              // FlexibleSpaceBar là nơi chứa nội dung thay đổi theo độ mở
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    _profileImageWithCorners(context),

                    Container(
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
                            context.isDarkMode ? Colors.black : Colors.white,
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 25,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.artistEntity.name,
                            style: TextStyle(
                              color: context.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          BlocBuilder<ArtistSongCubit, ArtistSongState>(
                            builder: (context, state) {
                              if (state is ArtistSongLoaded) {
                                return Text(
                                  '${widget.artistEntity.totalAlbums.toInt()} Albums, ${state.songs.length} Songs',
                                  style: TextStyle(
                                    color: context.isDarkMode
                                        ? Colors.grey
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. PHẦN MÔ TẢ (Biến mất cùng ảnh)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(widget.artistEntity.description)],
                ),
              ),
            ),

            // 3. PHẦN ALBUM (Sẽ dính lại ở TOP)
            BlocBuilder<ArtistAlbumCubit, ArtistAlbumState>(
              builder: (context, state) {
                if (state is ArtistAlbumLoaded && state.albums.isNotEmpty) {
                  return SliverPersistentHeader(
                    pinned: true, // để nó ở yên trên top
                    delegate: _StickyAlbumDelegate(
                      child: Container(
                        color: context.isDarkMode ? Colors.black : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 50,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Albums',
                                style: TextStyle(
                                  color: context.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: _albums(
                                  widget.artistEntity,
                                ), 
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate("Songs"),
            ),

            // 4. DANH SÁCH BÀI HÁT 
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: BlocBuilder<ArtistSongCubit, ArtistSongState>(
                builder: (context, state) {
                  if (state is ArtistSongLoading) {
                    return const SliverToBoxAdapter(child: LoadingScreen());
                  }
                  if (state is ArtistSongLoaded) {
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

            const SliverToBoxAdapter(child: SizedBox(height: 200)),
          ],
        ),
      ),
    );
  }

  GestureDetector _songs(
    BuildContext context,
    ArtistSongLoaded state,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SongPlayerCubit>().loadSongs(
          state.songs,
          index,
          widget.artistEntity.id,
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const SongPlayerPage(),
        //   ),
        // ).then((value) {
        //   // print('state: $value');
        //   if (!context.mounted) return;
        //   context.read<ArtistSongCubit>().getArtistSong(artistEntity.id);
        // });
        Navigator.pushNamed(context, '/player');
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

  Widget _profileImageWithCorners(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Giữ nguyên bo góc dưới của bạn
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        image: DecorationImage(
          // Giữ nguyên logic lấy URL ảnh của bạn
          image: NetworkImage(
            '${AppUrls.artistFirestorage}${widget.artistEntity.name}.jpg?${AppUrls.mediaAlt}',
          ),
          fit: BoxFit.cover, // Đảm bảo ảnh lấp đầy không gian
        ),
      ),
    );
  }

  Widget _albums(ArtistEntity artistEntity) {
    return BlocBuilder<ArtistAlbumCubit, ArtistAlbumState>(
      builder: (context, state) {
        if (state is ArtistAlbumLoading) {
          return const LoadingScreen();
        }

        if (state is ArtistAlbumLoaded) {
          return ListView.separated(
            itemCount: state.albums.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         AlbumPage(albumEntity: state.albums[index]),
                //   ),
                // ).then((value) {
                //   if (!context.mounted) return;
                //   context.read<ArtistSongCubit>().getArtistSong(
                //     artistEntity.id,
                //   );
                // });

                Navigator.pushNamed(
                  context,
                  '/album',
                  arguments: state.albums[index],
                ).then((value) {
                  if (!context.mounted) return;
                  context.read<ArtistSongCubit>().getArtistSong(
                    artistEntity.id,
                  );
                });
              },
              child: SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        // color: Colors.blue,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              '${AppUrls.albumFirestorage}${state.albums[index].title}.jpg?${AppUrls.mediaAlt}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.albums[index].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }
}

class _StickyAlbumDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyAlbumDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(child: child);
  }

  @override
  double get maxExtent => 300.0; // Chiều cao tối đa của vùng Album
  @override
  double get minExtent => 300.0; // Chiều cao tối thiểu khi đã "dính"

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _StickyHeaderDelegate(this.title);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 10),
      color: context.isDarkMode ? Colors.black : Colors.white,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: context.isDarkMode ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 100.0; // Chiều cao của thanh tiêu đề
  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
