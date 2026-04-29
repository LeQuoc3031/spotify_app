import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_app/domain/usecases/song/get_recently_played_usecase.dart';
import 'package:spotify_app/presentation/home/bloc/recently_played_state.dart';
import 'package:spotify_app/service_locator.dart';

class RecentlyPlayedCubit extends Cubit<RecentlyPlayedState> {
  RecentlyPlayedCubit() : super(RecentlyPlayedInitial());

  Future<void> getRecentlyPlayed() async {
    emit(RecentlyPlayedLoading());
    await Future.delayed(const Duration(seconds: 2));
    final returnedSongs = await sl<GetRecentlyPlayedUseCase>().call();

    returnedSongs.fold((l) => emit(RecentlyPlayedLoadFailure()), (data) {
      if (!isClosed) {
        emit(RecentlyPlayedLoaded(songs: data));
      }
    });
  }
}
