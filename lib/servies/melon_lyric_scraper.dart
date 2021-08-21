import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class MelonLyricScraper {
  static const String baseUrl = 'https://www.melon.com/song/detail.htm?songId=';

  static String _getSearchUrl(String title) {
    title = title.replaceAll(' ', '+');
    return 'https://www.melon.com/search/song/index.htm?q=$title&section=&searchGnbYn=Y&kkoSpl=N&kkoDpType=';
  }

  static String _parseHtmlString(String htmlString) {
    htmlString = htmlString.replaceAll('<br>', '\n');
    final document = parser.parse(htmlString);
    final String parsedString =
        parser.parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  static Future<String> searchLyric(String content) async {
    String songId;
    try {
      final response = await http.get(Uri.parse(_getSearchUrl(content)));
      dom.Document document = parser.parse(response.body);
      // 체크박스를 통해 음악의 id를 받아온다.
      final elements = document.getElementsByClassName('input_check');
      final lyricList = elements.map((element) {
        return element.attributes['value'];
      }).toList();
      if (lyricList.length < 2) {
        print('Empty search result');
        return '';
      }
      // 0번째 인덱스는 "모든 체크박스"의 값이다. 따라서 1번째 값을 이용한다.
      songId = lyricList[1] ?? '';
    } catch (e) {
      print('Fail to search song: $e');
      return '';
    }

    try {
      final response = await http.get(Uri.parse(baseUrl + songId));
      dom.Document document = parser.parse(response.body);
      final elements = document.getElementsByClassName('lyric');
      final lyricList =
      elements.map((element) => element.innerHtml).toList().map((e) {
        return _parseHtmlString(e);
      });

      if (lyricList.isEmpty) throw 'null';

      return lyricList.join('\n');
    } catch (e) {
      print('Fail to search lyrics: $e');
    }
    return '';
  }
}
