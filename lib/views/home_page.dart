import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_lyric/servies/melon_lyric_scraper.dart';
import 'package:p_lyric/views/setting_page.dart';
import 'package:p_lyric/widgets/default_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _scrollTolerance = 4.0;

  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isReachedEnd = ValueNotifier(false);
  String? lyrics;

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.offset + _scrollTolerance >=
              _scrollController.position.maxScrollExtent) {
        _isReachedEnd.value = true;
      } else {
        _isReachedEnd.value = false;
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSearchButton() async {
    final result =
        await MelonLyricScraper.searchLyric(_textEditingController.text);
    setState(() {
      lyrics = result;
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
              controller: _scrollController,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder<bool>(
          valueListenable: _isReachedEnd,
          builder: (context, isReachedEnd, button) {
            return FloatingActionButton(
              mini: true,
              onPressed: () =>
                  _handleScrollButtonTap(toBottom: !isReachedEnd),
              child: AnimatedSwitcher(
                duration: kThemeChangeDuration,
                child:  Icon(
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
