import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_lyric/services/melon_lyric_scraper.dart';
import 'package:p_lyric/views/setting_page.dart';
import 'package:p_lyric/widgets/default_container.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  String? lyrics;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() {});
    });
  }

  void _handleSearchButton() async {
    final result =
        await MelonLyricScraper.getLyrics(_textEditingController.text);
    setState(() {
      lyrics = result;
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
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: textTheme.subtitle1,
                        controller: _textEditingController,
                        onSubmitted: (_) => _handleSearchButton(),
                      ),
                    ),
                    TextButton(
                      onPressed: _textEditingController.text.isEmpty
                          ? null
                          : _handleSearchButton,
                      child: Text('검색'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    lyrics ?? "검색어를 입력하세요.",
                    style: textTheme.bodyText1!.copyWith(
                      color: Color(0xE6FFFFFF),
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
