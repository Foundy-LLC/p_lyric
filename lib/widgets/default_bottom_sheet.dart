import 'package:flutter/material.dart';

class DefaultBottomSheet extends StatelessWidget {
  const DefaultBottomSheet({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: child,
    );
  }
}
