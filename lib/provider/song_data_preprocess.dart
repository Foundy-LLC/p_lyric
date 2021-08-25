class SongDataPreprocess {
  static RegExp _korean = new RegExp(r"^[가-힣 ]*$");
  static RegExp _english = new RegExp(r"^[a-zA-Z ]*$");

  static bool _isStartWithKorean(String title) {
    bool ret;
    ret = _korean.hasMatch(title.split("")[0]) ? true : false;

    return ret;
  }

  /// 영어와 한국어가 섞여 있을 경우, 첫 단어를 기준으로 그에 맞는 언어로만 구성된 `String` 을 리턴
  static String _divideLanguage(String target, bool isKorean) {
    String korExtract = "";
    String engExtract = "";

    List<String> words = target.split("");

    for (int i = 0; i < words.length; i++) {
      if (words[i] == "  ") {
        korExtract += words[i];
        engExtract += words[i];
        continue;
      }

      if (_korean.hasMatch(words[i]))
        korExtract += words[i];
      else
        engExtract += words[i];
    }

    return isKorean ? korExtract : engExtract;
  }

  static String filterSongTitle(String title) {
    String filteredTitle = "";

    filteredTitle = title.split("(피처링")[0];

    // 제목에 영어와 한국어 모두 포함되어있을 때
    if (!_korean.hasMatch(filteredTitle) && !_english.hasMatch(filteredTitle)) {
      bool isKorean = _isStartWithKorean(title);
      filteredTitle = _divideLanguage(title, isKorean);
    }

    return filteredTitle;
  }

  /// `filterArtist` 는 멜론 검색에 최적화 된 가수명 필터링 함수이다.
  /// 따라서 멜론에서 검색될 수 있는 정보만 필터링해온다.
  static String filterArtist(String artist) {
    String filteredArtist = "";

    filteredArtist = artist.split(", ")[0];
    filteredArtist = filteredArtist.split(" 및")[0]; // `및` 이 들어가 있는 가수명은 필터링한다.
    filteredArtist = filteredArtist.split("(")[0]; // 괄호안에 가수의 영문을 써놓는 경우 제외시킨다.

    // 위 필터링 과정을 거쳐도 남아있는 영문과 한글이 혼용되있는 경우를 필터링한다.
    if (!_korean.hasMatch(filteredArtist) &&
        !_english.hasMatch(filteredArtist)) {
      bool isKorean = _isStartWithKorean(filteredArtist);
      filteredArtist = _divideLanguage(filteredArtist, isKorean);
    }

    return filteredArtist;
  }
}
