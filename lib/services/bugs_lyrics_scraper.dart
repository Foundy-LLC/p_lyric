import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:p_lyric/services/song_data_preprocessor.dart';

const String baseUrl = 'https://music.bugs.co.kr/track/';

String _getSearchPageUrl(String title, String artist) {
  String searchQuery;

  artist = "%2C" + artist;
  searchQuery = title + artist;

  return 'https://music.bugs.co.kr/search/integrated?q=$searchQuery';
}

Future<String> _getSongID(String searchedPage) async {
  String songID;

  try {
    final response = await http.get(
      Uri.parse(searchedPage),
    );
    dom.Document document = parser.parse(response.body);
    final elements = document.getElementsByClassName('check');
    final songList = elements.map((element) {
      return element.attributes['value'];
    }).toList();
    if (songList.length < 2) {
      // 맨 위에 전체선택 체크박스 포함
      return '곡 정보가 없습니다 😢';
    }

    // 0번째 인덱스는 `모든 체크박스`의 값이다. 따라서 1번째 값을 이용한다.
    songID = songList[1] ?? '';
    return songID;
  } catch (e) {
    return '🤔 노래 검색 에러\n$e';
  }
}

Future<bool> isExplicitSong(String songID) async {
  try {
    final response = await http.get(Uri.parse(baseUrl + songID));
    dom.Document document = parser.parse(response.body);
    String checkAge =
        document.getElementsByClassName('certificationGuide').first.innerHtml;

    return (checkAge.contains("19금")) ? true : false;
  } catch (e) {
    return false;
  }
}

Future<String> getLyricsFromBugs(String songTitle, String songArtist) async {
  if (songTitle == '' || songArtist == '') return "곡 정보가 없습니다 😢";

  String title = SongDataPreprocessor.filterArtist(songTitle);
  String artist = SongDataPreprocessor.filterArtist(songArtist);

  String searchPageUrl = _getSearchPageUrl(title, artist);
  String songID = await _getSongID(searchPageUrl);
  bool isExplicit = await isExplicitSong(songID);

  try {
    if (isExplicit) throw "성인인증이 필요한 곡입니다";

    final response = await http.get(Uri.parse(baseUrl + songID));
    dom.Document document = parser.parse(response.body);
    final lyrics = document.getElementsByTagName('xmp').first.innerHtml;

    if (lyrics.isEmpty)
      throw '가사를 찾을 수 없습니다\nTitle : $title\nArtist : $artist\n';

    return lyrics;
  } catch (e) {
    return '🤔 노래 검색 에러\n$e';
  }
}
