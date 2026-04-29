import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/song/get_news_songs_usecase.dart';
import 'package:spotify_app/presentation/home/bloc/news_songs_state.dart';
import 'package:spotify_app/service_locator.dart';

class NewsSongsCubit extends Cubit<NewsSongsState> {
  NewsSongsCubit() : super(NewsSongsInitial());

  Future<void> getNewsSongs() async {
    emit(NewsSongsLoading());

    final returnedSongs = await sl<GetNewsSongsUseCase>().call();

    returnedSongs.fold((l) => emit(NewsSongsLoadFailure()), (data) {
      if (!isClosed) {
        emit(NewsSongsLoaded(songs: data));
      }
    });
  }
}
