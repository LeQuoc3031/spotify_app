import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_album_cubit.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_album_state.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/album/album.dart';

class FavoriteButtonAlbum extends StatefulWidget {
  final AlbumEntity albumEntity;
  final Function? function;
  const FavoriteButtonAlbum({super.key, required this.albumEntity, this.function});

  @override
  State<FavoriteButtonAlbum> createState() => _FavoriteButtonAlbumState();
}

class _FavoriteButtonAlbumState extends State<FavoriteButtonAlbum> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoriteButtonAlbumCubit()..isFavorite(widget.albumEntity.albumId!),
      child: BlocBuilder<FavoriteButtonAlbumCubit, FavoriteButtonAlbumState>(
        builder: (context, state) {
          if (state is FavoriteButtonAlbumInitial) {
            return GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () async {
                await context.read<FavoriteButtonAlbumCubit>().favoriteButtonAlbumUpdated(
                  widget.albumEntity.albumId,
                );
                if (widget.function != null) {
                  widget.function!();
                }
              },
              child: AnimatedScale(
                scale: _isPressed ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: SvgPicture.asset(
                    key: ValueKey<bool>(widget.albumEntity.isFavorite!),
                    widget.albumEntity.isFavorite!
                        ? AppVectors.heart
                        : AppVectors.heartRounded,
                    height: 26,
                    width: 26,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }
          if (state is FavoriteButtonAlbumUpdated) {
            return GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                context.read<FavoriteButtonAlbumCubit>().favoriteButtonAlbumUpdated(
                  widget.albumEntity.albumId,
                );
                if (widget.function != null) {
                  widget.function!();
                }
              },
              child: AnimatedScale(
                scale: _isPressed ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: SvgPicture.asset(
                    key: ValueKey<bool>(state.isFavorite),
                    state.isFavorite
                        ? AppVectors.heart
                        : AppVectors.heartRounded,
                    height: 26,
                    width: 26,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
