import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:spotify_app/domain/entities/album/album.dart';
import 'package:spotify_app/domain/usecases/album/delete_album_usecase.dart';
import 'package:spotify_app/domain/usecases/album/get_favorite_album_usecase.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_album_state.dart';
import 'package:spotify_app/service_locator.dart';

class FavoriteAlbumCubit extends Cubit<FavoriteAlbumState> {
  List<AlbumEntity> favoriteAlbum = [];
  FavoriteAlbumCubit() : super(FavoriteAlbumInitial()) {
    getFavoriteAlbum();
  }

  Future<void> getFavoriteAlbum() async {
    emit(FavoriteAlbumLoading());
    final result = await sl<GetFavoriteAlbumUseCase>().call();

    result.fold((l) => emit(FavoriteAlbumFailure()), (data) {
      if (!isClosed) {
        favoriteAlbum = data;
        emit(FavoriteAlbumLoaded(albums: favoriteAlbum));
      }
    });
  }

  Future<void> removeSong(List<String> selectedIds) async {
    for (var element in selectedIds) {
      favoriteAlbum.removeWhere((album) => album.albumFavoriteId == element);
    }
    await sl<DeleteAlbumUseCase>().call(params: selectedIds);

    emit(FavoriteAlbumLoaded(albums: favoriteAlbum));
  }
}
