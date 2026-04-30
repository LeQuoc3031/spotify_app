// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify_app/core/configs/constants/app_urls.dart';
import 'package:spotify_app/domain/entities/song/song.dart';
import 'package:spotify_app/domain/usecases/song/add_recently_played_usecase.dart';
import 'package:spotify_app/domain/usecases/song/get_news_songs_usecase.dart';
import 'package:spotify_app/presentation/home/bloc/new_songs_released_state.dart';
import 'package:spotify_app/service_locator.dart';

class NewSongsReleasedCubit extends Cubit<NewSongsReleasedState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  String currentPlayListId = '';
  List<SongEntity> songs = [];
  List<SongEntity> songsReleased = [];

  String? _lastSavedSongId;
  bool isPlaying = false;

  NewSongsReleasedCubit() : super(NewSongsReleasedInitial()) {
    getNewSongsReleased();
  }

  Future<void> getNewSongsReleased() async {
    if (isClosed) return;
    emit(NewSongsReleasedLoading());

    final returnedSongs = await sl<GetNewsSongsUseCase>().call();

    returnedSongs.fold((l) => emit(NewSongsReleasedError()), (data) {
      if (!isClosed) {
        songsReleased = data;
        loadSongs(songsReleased[0], 0, 'newSongsReleased');
        emit(NewSongsReleasedLoaded(songs: data));
      }
    });
  }

  Future<void> loadSongs(
    SongEntity song,
    int index,
    String newPlayListId,
  ) async {
    try {
      emit(NewSongsReleasedLoading());
      // Lưu bài hát hiện tại vào Recently Played ngay khi nhấn
      // Kiểm tra nếu id mới khác với id cũ thì mới load lại playlist
      bool isNewPlaylist = currentPlayListId != newPlayListId;

      if (isNewPlaylist) {
        songs = [song];
        currentPlayListId = newPlayListId;
        final url =
            '${AppUrls.songFirestorage}${song.artist} - ${song.title}.mp3?${AppUrls.mediaAlt}';
        // BIẾN ĐỔI LIST SANG AUDIO SOURCE CÓ CACHE
        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: true,
          children: songs.map((song) {
            // ĐÂY LÀ CHỖ CACHE:
            return AudioSource.uri(
              Uri.parse(url),
              tag: song, // Gắn kèm data bài hát vào tag để dùng sau này
            );
          }).toList(),
        );

        await audioPlayer.setAudioSource(
          playlist,
          initialIndex: index,
          initialPosition: Duration.zero,
        );
      } else {
        // Nếu cùng playlist, chỉ cần nhảy đến đúng vị trí bài hát đó
        await audioPlayer.seek(Duration.zero, index: index);
      }
      audioPlayer.pause();

      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          // 1. Quay về đầu bài hát
          audioPlayer.seek(Duration.zero);
          // 2. Dừng phát
          audioPlayer.pause();

          // 3. Emit lại state để UI cập nhật nút Play/Pause
          emit(NewSongsReleasedLoaded(songs: songs));
        }
      });

      emit(NewSongsReleasedLoaded(songs: songs));
    } catch (e) {
      if (isClosed) return;
      emit(NewSongsReleasedError());
    }
  }

  void playOrPauseSong(SongEntity songEntity) {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      _updateRecentlyPlayed(songEntity);
      audioPlayer.play();
    }
  }

  Future<void> _updateRecentlyPlayed(SongEntity song) async {
    // Nếu bài hát định lưu trùng với bài vừa lưu xong thì bỏ qua
    if (_lastSavedSongId == song.songId) return;
    print('save recently played');
    _lastSavedSongId = song.songId;
    await sl<AddRecentlyPlayedUseCase>().call(params: song);
  }
}
