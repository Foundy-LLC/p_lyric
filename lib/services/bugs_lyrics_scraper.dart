import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:p_lyric/services/song_data_preprocessor.dart';

const String baseUrl = 'https://music.bugs.co.kr/track/';

String _getSearchPageUrl(String title, String artist) {
  title = title.replaceAll(" ", "%20");
  artist = "%2C%20" + artist.replaceAll(" ", "%20");

  String searchQuery = title + artist;

  print(searchQuery);

  return 'https://music.bugs.co.kr/search/integrated?q=$searchQuery';
}

Future<String> _getSongID(String searchedPage) async {
  String songID = "";

  try {
    final response = await http.get(
      Uri.parse(searchedPage),
    );
    dom.Document document = parser.parse(response.body);
    final elements = document.getElementsByClassName("check");

    if (elements.length == 0) return '곡 정보가 없습니다 😢';

    String songID = elements[1].children[0].attributes['value'].toString();

    print(songID);
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
    return (checkAge.contains("19세")) ? true : false;
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
    final lyricsContainer = document.getElementsByTagName('xmp');

    if (lyricsContainer.isEmpty)
      throw '가사를 찾을 수 없습니다\nTitle : $title\nArtist : $artist\n';

    final lyrics =
        lyricsContainer.first.innerHtml.toString().replaceAll("...*", "");

    return lyrics.trim();
  } catch (e) {
    return '🤔 노래 검색 에러\n$e';
  }
}

void main() async {
  final asdf = await getLyricsFromBugs("Stay", "The Kid Laroi");
  print(asdf);
}
