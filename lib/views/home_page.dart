import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/provider/playing_music_provider.dart';
import 'package:p_lyric/views/setting_page.dart';
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

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.offset + _scrollTolerance >=
              _scrollController.position.maxScrollExtent) {
        _isReachedEnd.value = true;
      } else {
        _isReachedEnd.value = false;
      }
    });

    // TODO(민성): 설정 화면 혹은 다이어로그 띄워서 사용자에게 권한에 대해 설명하기
    NowPlaying.instance.isEnabled().then((bool isEnabled) async {
      if (!isEnabled) {
        final granted = await NowPlaying.instance.requestPermissions();

        Get.showSnackbar(GetBar(
          message: granted ? '권한이 허용됨' : '권한이 허용되지 않음',
          duration: const Duration(seconds: 3),
        ));
      }
    });
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
            child: _CardView(),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: DefaultTextStyle(
                    style: textTheme.bodyText1!.copyWith(
                      color: Color(0xE6FFFFFF),
                    ),
                    child: GetBuilder<PlayingMusicProvider>(
                      init: PlayingMusicProvider(),
                      builder: (musicProvider) {
                        if (musicProvider.track != null) {
                          final title = musicProvider.track!.title;

                          if (title == null) return Text("검색 결과가 없습니다.");

                          if (musicProvider.lyric.isNotEmpty) {
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
          valueListenable: _isReachedEnd,
          builder: (context, isReachedEnd, button) {
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
          }),
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GetBuilder<PlayingMusicProvider>(
          init: PlayingMusicProvider(),
          builder: (musicProvider) {
            final track = musicProvider.track;
            final icon = track?.image;
            final title = track?.title ?? '재생중인 음악 없음';
            final artist = track?.artist ?? '노래를 재생하면 가사가 업데이트됩니다.';

            return Row(
              children: [
                ClipRRect(
                  // TODO(민성): 재생 및 다음곡 버튼 구현
                  borderRadius: BorderRadius.circular(1000.0),
                  child: icon == null
                      ? const SizedBox(height: 72, width: 72)
                      : Image(image: icon, height: 72, width: 72),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.subtitle1!.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artist,
                        style: textTheme.subtitle2!.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
