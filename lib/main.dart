import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:p_lyric/themes.dart';
import 'package:p_lyric/views/home_page.dart';

void main() async {
  NowPlaying.instance.start();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final iconThemeData = const IconThemeData(color: Colors.white70);
    final cardShape = const RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(
        const Radius.circular(12.0),
      ),
    );

    final themeData = ThemeData(
      iconTheme: iconThemeData,
      primaryTextTheme: primaryTextTheme,
    );

    return GetMaterialApp(
      theme: themeData.copyWith(
        brightness: Brightness.light,
        colorScheme: lightColorScheme,
        textTheme: textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        cardTheme: CardTheme(color: const Color(0xe6ffffff), shape: cardShape),
        popupMenuTheme: PopupMenuThemeData(
          shape: cardShape,
          color: Colors.white,
        ),
      ),
      darkTheme: themeData.copyWith(
        brightness: Brightness.dark,
        colorScheme: darkColorScheme,
        textTheme: textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        cardTheme: CardTheme(color: const Color(0xe6121212), shape: cardShape),
        popupMenuTheme: PopupMenuThemeData(
          shape: cardShape,
          color: const Color(0xff121212),
        ),
      ),
      home: HomePage(),
    );
  }
}
