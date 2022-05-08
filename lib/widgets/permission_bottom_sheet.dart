import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p_lyric/provider/permission_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'default_bottom_sheet.dart';
import 'default_snack_bar.dart';

class PermissionBottomSheet extends StatefulWidget {
  const PermissionBottomSheet({Key? key}) : super(key: key);

  @override
  _PermissionBottomSheetState createState() => _PermissionBottomSheetState();
}

class _PermissionBottomSheetState extends State<PermissionBottomSheet> {
  @override
  void initState() {
    super.initState();
    Get.find<PermissionProvider>()
        .addListener(_permissionListener, doRefresh: false);
  }

  @override
  void dispose() {
    Get.find<PermissionProvider>().removeListener(_permissionListener);
    super.dispose();
  }

  void _permissionListener() async {
    if (Get.find<PermissionProvider>().hasAll) {
      await _setSharedPrefsTrue();
      Get.back();
      showSnackBar('권한 허용됨');
    }
  }

  Future<void> _setSharedPrefsTrue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PermissionProvider.alreadyRequestedKey, true);
  }

  void _onPressedSkip() async {
    await _setSharedPrefsTrue();
    Get.back();
    showSnackBar('설정에서 권한을 설정할 수 있습니다.');
  }

  void _onPressedOk() async {
    final permissionHandler = Get.find<PermissionProvider>();

    permissionHandler.requestNotificationAccess();
    await permissionHandler.requestSystemOverlayWindow();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;
    final bodyStyle = textTheme.bodyText2!.copyWith(
      height: 1.6,
      color: context.isDarkMode ? Colors.white70 : const Color(0xb3000000),
    );
    final accentColor =
        context.isDarkMode ? colorScheme.primary : colorScheme.primaryContainer;

    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: DefaultBottomSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PLyric 앱의 권한들을 허용해주세요.',
              style: textTheme.headline5!.copyWith(height: 1.4),
            ),
            const SizedBox(height: 8.0),
            Text(
              '•알림 접근 허용: 현재 재생중인 음악 정보를 얻기 위해 필요합니다.',
              style: bodyStyle,
            ),
            const SizedBox(height: 8.0),
            Text(
              '•다른 앱 위에 표시: 가사 창을 다른 앱 위에 띄우기 위해 필요합니다.',
              style: bodyStyle,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _onPressedSkip,
                  child: Text(
                    '건너뛰기',
                    style: textTheme.button!.copyWith(color: accentColor),
                  ),
                ),
                const SizedBox(width: 16.0),
                TextButton(
                  onPressed: _onPressedOk,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(accentColor),
                  ),
                  child: Text(
                    '설정하기',
                    style: textTheme.button!.copyWith(
                      color: context.isDarkMode ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
