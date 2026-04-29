import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:spotify_app/domain/usecases/song/add_or_remove_favorite_song_usecase.dart';
import 'package:spotify_app/domain/usecases/song/is_favorite_song_usecase.dart';
import 'package:spotify_app/service_locator.dart';

class FavoriteButtonCubit extends Cubit<FavoriteButtonState> {
  FavoriteButtonCubit() : super(FavoriteButtonInitial());

  Future<void> favoriteButtonUpdated(String? songId) async {
    final result = await sl<AddOrRemoveFavoriteSongUseCase>().call(
      params: songId,
    );

    result.fold((l) {}, (isFavorite) {
      if (!isClosed) {
        emit(FavoriteButtonUpdated(isFavorite: isFavorite));
      }
    });
  }

  Future<void> isFavorite(String songId) async {
    // Gọi UseCase để check trong danh sách Favorite của User trên Firebase
    final result = await sl<IsFavoriteSongUseCase>().call(params: songId);

    // Phát ra state để UI hiển thị đúng màu icon ngay lập tức
    if (!isClosed) {
      emit(FavoriteButtonUpdated(isFavorite: result));
    }
  }
}
