import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_song_usecase.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_song_state.dart';
import 'package:spotify_app/service_locator.dart';

class ArtistSongCubit extends Cubit<ArtistSongState> {
  ArtistSongCubit() : super(ArtistSongInitial());

  Future<void> getArtistSong(String artistId) async {
    if (!isClosed) {
      emit(ArtistSongLoading());
    }
    final songs = await sl<GetArtistSongUseCase>().call(params: artistId);
    songs.fold((l) => emit(ArtistSongFailure()), (data) {
      if (!isClosed) {
        emit(ArtistSongLoaded(songs: data));
      }
    });
  }
}
