import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/provider/music_provider.dart';
import 'package:p_lyric/provider/permission_provider.dart';
import 'package:p_lyric/views/setting_page.dart';
import 'package:p_lyric/widgets/default_container.dart';
import 'package:p_lyric/widgets/subtitle.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _scrollTolerance = 4.0;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isReachedEnd = ValueNotifier(false);
  final ValueNotifier<bool> _showButton = ValueNotifier(false);
  String? _currentLyrics;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButton);

    Get.put(PermissionProvider());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButton() {
    if (!_scrollController.hasClients) {
      _isReachedEnd.value = false;
      _showButton.value = false;
      return;
    }

    _isReachedEnd.value = (_scrollController.offset + _scrollTolerance >=
            _scrollController.position.maxScrollExtent)
        ? true
        : false;
    _showButton.value =
        _scrollController.position.maxScrollExtent == 0.0 ? false : true;
  }

  void _handleScrollButtonTap({bool toBottom = true}) {
    _scrollController.animateTo(
      toBottom ? _scrollController.position.maxScrollExtent : 0.0,
      duration: kThemeChangeDuration,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;

    return DefaultContainer(
      title: const Text('PLyric'),
      actions: [
        PopupMenuButton<Widget>(
          onSelected: (widget) {
            Get.to(widget);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: const SettingPage(),
              child: const Text('설정'),
            ),
          ],
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const _CardView(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 12.0),
            child: const SubTitle('가사'),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: DefaultTextStyle(
                    style: textTheme.bodyText1!.copyWith(
                      color: Color(0xE6FFFFFF),
                      height: 1.8,
                    ),
                    child: GetBuilder<MusicProvider>(
                      builder: (musicProvider) {
                        final track = musicProvider.track;
                        bool areLyricsUpdated = false;
                        // 가사가 수정된 경우
                        if (_currentLyrics == null ||
                            _currentLyrics != musicProvider.lyric) {
                          _currentLyrics = musicProvider.lyric;
                          areLyricsUpdated = true;
                        }
                        if (areLyricsUpdated) {
                          if (_scrollController.position.hasViewportDimension)
                            _scrollController.jumpTo(0.0);
                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                            if (mounted) _updateScrollButton();
                          });
                        }
                        // 음악 정보가 없으면 빈 위젯을 반환한다.
                        if (track.title == null || track.artist == null)
                          return const Text('');

                        return musicProvider.areLyricsUpdating
                            ? Center(child: CircularProgressIndicator())
                            : Text(musicProvider.lyric);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showButton,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isReachedEnd,
          builder: (_, isReachedEnd, button) {
            return FloatingActionButton(
              mini: true,
              onPressed: () => _handleScrollButtonTap(toBottom: !isReachedEnd),
              child: AnimatedSwitcher(
                duration: kThemeChangeDuration,
                child: Icon(
                  isReachedEnd ? Icons.arrow_upward : Icons.arrow_downward,
                  key: ValueKey(isReachedEnd),
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
        builder: (_, showButton, child) => AnimatedSwitcher(
          duration: kThemeChangeDuration,
          child: showButton ? child! : const SizedBox(),
        ),
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: const _AlbumCoverImage(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  GetBuilder<MusicProvider>(
                    builder: (musicProvider) => Text(
                      musicProvider.track.title ?? '재생중인 음악 없음',
                      style: textTheme.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GetBuilder<MusicProvider>(
                    builder: (musicProvider) => Text(
                      musicProvider.track.artist ?? '노래를 재생하면 가사가 업데이트됩니다.',
                      style: textTheme.subtitle2!.copyWith(
                        color: context.isDarkMode
                            ? Colors.white54
                            : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const _ControlBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCoverImage extends StatelessWidget {
  const _AlbumCoverImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageDiameter = 88.0;

    return GetBuilder<MusicProvider>(
      init: MusicProvider(),
      builder: (musicProvider) {
        final image = musicProvider.track.image;
        final hasImage = image != null;

        return AnimatedContainer(
          duration: kThemeChangeDuration,
          curve: Curves.easeOut,
          margin: EdgeInsets.only(right: hasImage ? 16.0 : 0.0),
          height: imageDiameter,
          width: hasImage ? imageDiameter : 0.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(1000.0),
            child: AnimatedSwitcher(
              duration: kThemeChangeDuration,
              child: hasImage
                  ? Image(
                      image: image!,
                      height: imageDiameter,
                      width: imageDiameter,
                    )
                  : const SizedBox(),
            ),
          ),
        );
      },
    );
  }
}

class _ControlBar extends StatefulWidget {
  const _ControlBar({Key? key}) : super(key: key);

  @override
  _ControlBarState createState() => _ControlBarState();
}

class _ControlBarState extends State<_ControlBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: kThemeChangeDuration,
      reverseDuration: kThemeChangeDuration,
    );

    _animation = CurvedAnimation(
      parent: Tween(begin: 0.0, end: 1.0).animate(_controller),
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: context.isDarkMode ? Colors.white : Colors.black,
      ),
      child: GetBuilder<MusicProvider>(
        builder: (musicProvider) {
          switch (musicProvider.trackState) {
            case NowPlayingState.playing:
              _controller.forward();
              break;
            case NowPlayingState.paused:
            case NowPlayingState.stopped:
              _controller.reverse();
              break;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: musicProvider.skipToPrevious,
                iconSize: 32,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: musicProvider.playOrPause,
                iconSize: 40,
                padding: EdgeInsets.zero,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _animation,
                ),
              ),
              IconButton(
                onPressed: musicProvider.skipToNext,
                iconSize: 32,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.skip_next),
              ),
            ],
          );
        },
      ),
    );
  }
}
