import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/get_favorite_songs_usecase.dart';
import 'package:spotify_app/presentation/profile/bloc/favorite_song_state.dart';
import 'package:spotify_app/service_locator.dart';

class FavoriteSongCubit extends Cubit<FavoriteSongState> {
  FavoriteSongCubit() : super(FavoriteSongInitial()) {
    // getFavoriteSong();
  }

  List<SongEntity> favoriteSongs = [];
  Future<void> getFavoriteSong() async {
    emit(FavoriteSongLoading());
    final result = await sl<GetFavoriteSongsUseCase>().call();

    result.fold(
      (l) {
        if (!isClosed) {
          emit(FavoriteSongFailure());
        }
      },
      (r) {
        favoriteSongs = r;
        if (!isClosed) {
          emit(FavoriteSongLoaded(favoriteSongs: favoriteSongs));
        }
      },
    );
  }

  void removeSong(int index)  {
    favoriteSongs.removeAt(index);
    emit(FavoriteSongLoaded(favoriteSongs: favoriteSongs));
  }
}
