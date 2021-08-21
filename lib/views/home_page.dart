import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/provider/playing_music_provider.dart';
import 'package:p_lyric/views/setting_page.dart';
import 'package:p_lyric/widgets/default_container.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

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
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [],
        ),
      ),
    );
  }
}
