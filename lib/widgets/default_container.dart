import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DefaultContainer extends StatelessWidget {
  const DefaultContainer({
    Key? key,
    required this.title,
    this.actions = const [],
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  }) : super(key: key);

  final Text title;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    Widget leading = const SizedBox();
    if (canPop) leading = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: const BackButton(),
    );

    return Scaffold(
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              const Color(0xFF8C6988),
              const Color(0xFF5A5172),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.0, 1.0),
            stops: [0.0, 0.66, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        padding: const EdgeInsets.only(top: 40),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: canPop ? 0 : 24, right: 24),
                child: DefaultTextStyle(
                  style: Get.theme.primaryTextTheme.headline4!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Color(0xCCFFFFFF),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      leading,
                      Expanded(child: title),
                      ...actions,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
