import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/artist/get_artist_usecase.dart';
import 'package:spotify_app/presentation/artist/bloc/artist_list_state.dart';
import 'package:spotify_app/service_locator.dart';

class ArtistListCubit extends Cubit<ArtistListState> {
  ArtistListCubit() : super(ArtistListInitial());

  Future<void> getArtist() async {
    emit(ArtistListLoading());
    final artists = await sl<GetArtistsUseCase>().call();
    artists.fold((l) => emit(ArtistListLoadFailure()), (data) {
      if (!isClosed) {
        emit(ArtistListLoaded(artists: data));
      }
    });
  }
}
