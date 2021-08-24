import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/services/melon_lyric_scraper.dart';

import 'utils/waiter.dart';

class PlayingMusicProvider extends GetxController {
  PlayingMusicProvider();

  Rx<NowPlayingTrack> _track = NowPlayingTrack.notPlaying.obs;
  NowPlayingTrack? get track => _track.value;

  String _lyric = '';
  String get lyric => _lyric;

  @override
  void onInit() {
    super.onInit();
    NowPlaying.instance.stream.listen(_listenTrackEvent);
    wait(_track, _updateLyric, time: const Duration(milliseconds: 1000));
  }

  void _updateLyric(NowPlayingTrack track) async {
    _lyric = await MelonLyricScraper.getLyrics(
        track.title ?? '', track.artist ?? '');
    update();
  }

  void _listenTrackEvent(NowPlayingTrack newTrack) {
    if (newTrack.isPlaying && _track.value.title != newTrack.title) {
      _track.value = newTrack;
      update();
    }
  }
}
