import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:spotify_app/core/configs/assets/app_vectors.dart';
import 'package:spotify_app/core/configs/theme/app_colors.dart';
import 'package:spotify_app/domain/entities/song/song.dart';

class FavoriteButton extends StatefulWidget {
  final SongEntity songEntity;
  final Function? function;
  const FavoriteButton({super.key, required this.songEntity, this.function});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FavoriteButtonCubit()..isFavorite(widget.songEntity.songId!),
      child: BlocBuilder<FavoriteButtonCubit, FavoriteButtonState>(
        builder: (context, state) {
          if (state is FavoriteButtonInitial) {
            return GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () async {
                await context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                  widget.songEntity.songId,
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
                    key: ValueKey<bool>(widget.songEntity.isFavorite!),
                    widget.songEntity.isFavorite!
                        ? AppVectors.heart
                        : AppVectors.heartRounded,
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            );
          }
          if (state is FavoriteButtonUpdated) {
            return GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: () {
                context.read<FavoriteButtonCubit>().favoriteButtonUpdated(
                  widget.songEntity.songId,
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
                    height: 24,
                    width: 24,
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
