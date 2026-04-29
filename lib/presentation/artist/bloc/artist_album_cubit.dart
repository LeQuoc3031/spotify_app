import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_album_usecase.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_album_state.dart';
import 'package:spotify_app/service_locator.dart';

class ArtistAlbumCubit extends Cubit<ArtistAlbumState> {
  ArtistAlbumCubit() : super(ArtistAlbumInitial());

  Future<void> getArtistAlbum(String artistId) async {
    emit(ArtistAlbumLoading());
    final albums = await sl<GetArtistAlbumUseCase>().call(params: artistId);
    albums.fold((l) => emit(ArtistAlbumFailure()), (data) {
      if (!isClosed) {
        emit(ArtistAlbumLoaded(albums: data));
      }
    });
  }
}
