import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/provider/music_provider.dart';
import 'package:p_lyric/views/setting_page.dart';
import 'package:p_lyric/widgets/default_bottom_sheet.dart';
import 'package:p_lyric/widgets/default_container.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButton);

    NowPlaying.instance.isEnabled().then((bool isEnabled) async {
      if (!isEnabled) {
        await Get.bottomSheet(
          const _PermissionBottomSheet(),
          isDismissible: false,
        );
      }
    });
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
          const SizedBox(height: 22),
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
                        if (musicProvider.track != null) {
                          final title = musicProvider.track!.title;

                          if (title == null) return Text("검색 결과가 없습니다.");

                          if (musicProvider.lyric.isNotEmpty) {
                            _scrollController.jumpTo(0.0);
                            return Text(musicProvider.lyric);
                          }
                          return Center(child: CircularProgressIndicator());
                        }
                        return Text("검색어를 입력하세요.");
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
        builder: (_, showButton, child) =>
            showButton ? child! : const SizedBox(),
      ),
    );
  }
}

class _PermissionBottomSheet extends StatefulWidget {
  const _PermissionBottomSheet({Key? key}) : super(key: key);

  @override
  _PermissionBottomSheetState createState() => _PermissionBottomSheetState();
}

class _PermissionBottomSheetState extends State<_PermissionBottomSheet>
    with WidgetsBindingObserver {
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_inProgress) {
          if (await NowPlaying.instance.isEnabled()) {
            Get.back();
            Get.showSnackbar(GetBar(
              message: '권한 허용됨',
              duration: const Duration(seconds: 3),
            ));
          }
          _inProgress = false;
        }
        break;
      default:
    }
  }

  void _onPressedSkip() async {
    Get.back();
    Get.showSnackbar(GetBar(
      message: '설정에서 권한을 설정할 수 있습니다.',
      duration: const Duration(seconds: 3),
    ));
  }

  void _onPressedOk() async {
    _inProgress = true;
    await NowPlaying.instance.requestPermissions(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;

    return DefaultBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PLyric 앱의 알림 접근 권한을 허용해주세요.',
            style: textTheme.headline5!.copyWith(height: 1.4),
          ),
          const SizedBox(height: 8.0),
          Text(
            '현재 재생중인 음악 정보를 얻기 위해 필요합니다.',
            style: textTheme.bodyText2!
                .copyWith(color: Color(0xb3000000), height: 1.6),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _onPressedSkip,
                child: Text(
                  '건너뛰기',
                  style: textTheme.button!.copyWith(
                    color: colorScheme.secondaryVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              TextButton(
                onPressed: _onPressedOk,
                child: Text(
                  '설정하기',
                  style: textTheme.button!.copyWith(
                    color: colorScheme.primaryVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
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
                      musicProvider.track?.title ?? '재생중인 음악 없음',
                      style: textTheme.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GetBuilder<MusicProvider>(
                    builder: (musicProvider) => Text(
                      musicProvider.track?.artist ?? '노래를 재생하면 가사가 업데이트됩니다.',
                      style: textTheme.subtitle2!.copyWith(
                        color: Get.isDarkMode ? Colors.white54 : Colors.black54,
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
        final image = musicProvider.track?.image;
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
        color: Get.isDarkMode ? Colors.white : Colors.black,
      ),
      child: GetBuilder<MusicProvider>(
        builder: (musicProvider) {
          switch (musicProvider.state) {
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
