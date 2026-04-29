import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/widgets/appbar/app_bar.dart';
import 'package:spotify_app/common/widgets/loading/loading_screen.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/artist/artist.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_list_cubit.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_list_state.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_search_cubit.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_search_state.dart';

class ArtistListPage extends StatelessWidget {
  const ArtistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: const BasicAppbar(
          title: Text('Artists', style: TextStyle(fontSize: 16)),
          searchIcon: false,
          isBack: false,
        ),
        body: BlocProvider(
          create: (context) => ArtistListCubit()..getArtist(),
          child: BlocBuilder<ArtistListCubit, ArtistListState>(
            builder: (context, state) {
              if (state is ArtistListLoading) {
                return const LoadingScreen();
              }

              if (state is ArtistListLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _searchBar(context),
                      const SizedBox(height: 40),

                      Expanded(child: _buildArtistsGrid(state.artists)),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Error'));
            },
          ),
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      controller: context.read<ArtistSearchCubit>().artistSearchController,
      onChanged: (value) {
        // Mỗi khi người dùng gõ 1 ký tự, hàm này sẽ chạy
        context.read<ArtistSearchCubit>().searchArtist(value);
      },
      // keyboardType: TextInputType.text,
      decoration:
          const InputDecoration(
                hintText: "Tìm nghệ sĩ yêu thích ...",
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

  Widget _buildArtistsGrid(List<ArtistEntity> artists) {
    return BlocBuilder<ArtistSearchCubit, ArtistSearchState>(
      builder: (context, state) {
        if (state is ArtistSearchLoading) {
          return const LoadingScreen();
        }
        if (state is ArtistSearchLoaded) {
          return GridView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Cột
              crossAxisSpacing: 20, // Khoảng cách ngang giữa các mục
              mainAxisSpacing: 20, // Khoảng cách dọc giữa các mục
              // Tỷ lệ khung hình của mỗi mục (Chiều rộng / Chiều cao).
              // 0.8 giúp mục cao hơn một chút so với rộng, để tên có không gian.
              childAspectRatio: 0.6,
            ),
            itemCount: state.artists.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         ArtistProfilePage(artistEntity: state.artists[index]),
                  //   ),
                  // );
                  Navigator.pushNamed(
                    context,
                    '/artist',
                    arguments: state.artists[index],
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              '${AppUrls.artistFirestorage}${state.artists[index].name}.jpg?${AppUrls.mediaAlt}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      state.artists[index].nameVie,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 Cột
            crossAxisSpacing: 20, // Khoảng cách ngang giữa các mục
            mainAxisSpacing: 20, // Khoảng cách dọc giữa các mục
            // Tỷ lệ khung hình của mỗi mục (Chiều rộng / Chiều cao).
            // 0.8 giúp mục cao hơn một chút so với rộng, để tên có không gian.
            childAspectRatio: 0.6,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         ArtistProfilePage(artistEntity: artists[index]),
                //   ),
                // );
                Navigator.pushNamed(
                  context,
                  '/artist',
                  arguments: artists[index],
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            '${AppUrls.artistFirestorage}${artists[index].name}.jpg?${AppUrls.mediaAlt}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    artists[index].nameVie,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
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
}
