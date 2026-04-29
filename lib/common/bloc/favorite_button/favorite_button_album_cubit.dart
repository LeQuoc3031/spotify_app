import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/common/bloc/favorite_button/favorite_button_album_state.dart';
import 'package:spotify_app/domain/usecases/album/add_or_remove_favorite_album_usecase.dart';
import 'package:spotify_app/domain/usecases/album/is_favorite_album_usecase.dart';
import 'package:spotify_app/service_locator.dart';

class FavoriteButtonAlbumCubit extends Cubit<FavoriteButtonAlbumState> {
  FavoriteButtonAlbumCubit() : super(FavoriteButtonAlbumInitial());

  Future<void> favoriteButtonAlbumUpdated(String? albumId) async {
    final result = await sl<AddOrRemoveFavoriteAlbumUseCase>().call(
      params: albumId,
    );

    result.fold((l) {}, (isFavorite) {
      if (!isClosed) {
        emit(FavoriteButtonAlbumUpdated(isFavorite: isFavorite));
      }
    });
  }

  Future<void> isFavorite(String albumId) async {
    // Gọi UseCase để check trong danh sách Favorite của User trên Firebase
    final result = await sl<IsFavoriteAlbumUseCase>().call(params: albumId);

    // Phát ra state để UI hiển thị đúng màu icon ngay lập tức
    if (!isClosed) {
      emit(FavoriteButtonAlbumUpdated(isFavorite: result));
    }
  }
}
