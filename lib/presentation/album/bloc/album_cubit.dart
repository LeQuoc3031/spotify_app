import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/album/get_album_song_usecase.dart';
import 'package:spotify_app/presentation/album/bloc/album_state.dart';
import 'package:spotify_app/service_locator.dart';

class AlbumCubit extends Cubit<AlbumState> {
  AlbumCubit() : super(AlbumInitial());

  Future<void> getAlbumSongs(String albumId) async {
    emit(AlbumLoading());
    final albums = await sl<GetAlbumSongUseCase>().call(params: albumId);
    albums.fold((l) => emit(AlbumLoadFailure()), (data) {
      if (!isClosed) {
        emit(AlbumLoaded(songs: data));
      }
    });
  }
}
