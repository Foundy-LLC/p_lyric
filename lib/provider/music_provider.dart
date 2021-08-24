import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/services/melon_lyric_scraper.dart';

import 'utils/waiter.dart';

class MusicProvider extends GetxController {
  static const _channel =
      const MethodChannel('com.example.p_lyric/MusicProvider');

  /// 현재 재생되고 있는 트랙을 반환한다.
  NowPlayingTrack? get track => _track.value;
  Rx<NowPlayingTrack> _track = NowPlayingTrack.notPlaying.obs;

  /// 현재 재생되고 있는 트랙의 가사를 반환한다.
  String get lyric => _lyric;
  String _lyric = '';

  /// 음악 플레이어의 상태를 반환한다.
  NowPlayingState state = NowPlayingState.stopped;

  @override
  void onInit() {
    super.onInit();
    NowPlaying.instance.stream.listen(_listenTrackEvent);
    wait(_track, _updateLyric, time: const Duration(milliseconds: 1000));
  }

  void _updateLyric(NowPlayingTrack track) async {
    _lyric = await MelonLyricScraper.getLyrics(
      track.title ?? '',
      track.artist ?? '',
    );
    update();
  }

  void _listenTrackEvent(NowPlayingTrack newTrack) {
    bool updated = false;
    if (_track.value.title != newTrack.title) {
      _track.value = newTrack;
      updated = true;
    }

    if (newTrack.state != state) {
      state = newTrack.state;
      updated = true;
    }

    if (updated) update();
  }

  /// 음악 플레이어의 [state]를 고려하여 음악을 재생 혹은 정지한다.
  ///
  /// 플레이어가 음악을 재생중인 경우 정지하며, 정지되어 있는 경우 재생한다.
  Future<bool> playOrPause() async {
    bool result;
    try {
      switch (state) {
        case NowPlayingState.playing:
          result = await _channel.invokeMethod('pause'); // TODO: IOS 구현
          break;
        case NowPlayingState.paused:
        case NowPlayingState.stopped:
          result = await _channel.invokeMethod('play'); // TODO: IOS 구현
          break;
      }
    } on PlatformException catch (e) {
      print("Failed to control music: '${e.message}'.");
      result = false;
    }
    return result;
  }

  Future<bool> skipPrevious() async {
    return await _channel.invokeMethod('skipPrevious'); // TODO: IOS 구현
  }

  Future<bool> skipNext() async {
    return await _channel.invokeMethod('skipNext'); // TODO: IOS 구현
  }
}