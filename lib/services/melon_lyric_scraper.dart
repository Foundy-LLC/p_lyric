import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:p_lyric/services/song_data_preprocessor.dart';

class MelonLyricScraper {
  // TODO(시현) : 아래의 `proxyUrl` 이 `web build`에서만 작동되는 문제 해결해야됨.
  // 다만 위 문제는 IP 차단 문제가 없으면 굳이 해결 안해도 되는 문제임.
  // static const String proxyUrl = "https://foundy-proxy.herokuapp.com";

  static const String baseUrl = 'https://www.melon.com/song/detail.htm?songId=';

  /// [title], [arist] 형식으로 검색 페이지의 URL을 얻는다.
  ///
  /// 중복된 노래 제목이 존재하므로 `제목, 가수명`으로 검색하는 것이다.
  /// (ex. 고백 - 10cm / 고백 - 뜨거운 감자)
  static String _getSearchPageUrl(String title, String artist) {
    String searchQuery;

    title = title.replaceAll(' ', '+');
    artist = "%2C+" + artist.replaceAll(' ', '+');
    searchQuery = title + artist;

    return 'https://www.melon.com/search/song/index.htm?q=$searchQuery&section=&searchGnbYn=Y&kkoSpl=N&kkoDpType=';
  }

  static String _parseHtmlString(String htmlString) {
    htmlString = htmlString.replaceAll('<br>', '\n');
    final document = parser.parse(htmlString);
    final String parsedString =
        parser.parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  // TODO(시현, 민성): 곡 정보를 어떻게 가공하냐에 따라 매개변수 searchedSongUrl을 `title, artist` 형태로 바꿀지 말지 결정
  static Future<String> _getSongID(String searchedSongUrl) async {
    String songID;

    try {
      final response = await http.get(
        Uri.parse(searchedSongUrl),
      );
      dom.Document document = parser.parse(response.body);
      final elements = document.getElementsByClassName('input_check');
      final lyricList = elements.map((element) {
        return element.attributes['value'];
      }).toList();
      if (lyricList.length < 2) {
        // 맨 위에 전체선택 체크박스 포함
        return '곡 정보가 없습니다 😢';
      }

      // 0번째 인덱스는 `모든 체크박스`의 값이다. 따라서 1번째 값을 이용한다.
      songID = lyricList[1] ?? '';
      return songID;
    } catch (e) {
      return '🤔 노래 검색 에러\n$e';
    }
  }

  static Future<String> getLyrics(String songTitle, String songArtist) async {
    if (songTitle == '' || songArtist == '') return "곡 정보가 없습니다 😢";

    String title = SongDataPreprocessor.filterArtist(songTitle);
    String artist = SongDataPreprocessor.filterArtist(songArtist);

    String searchPageUrl = _getSearchPageUrl(title, artist);
    String songID = await _getSongID(searchPageUrl);

    try {
      final response = await http.get(Uri.parse(baseUrl + songID));
      dom.Document document = parser.parse(response.body);
      final elements = document.getElementsByClassName('lyric');
      final lyricList =
          elements.map((element) => element.innerHtml).toList().map((e) {
        return _parseHtmlString(e);
      });

      if (lyricList.isEmpty)
        throw '가사를 찾을 수 없습니다\nTitle : $title\nArtist : $artist';

      return lyricList.join('\n');
    } catch (e) {
      return '🤔 노래 검색 에러\n$e';
    }
  }
}
