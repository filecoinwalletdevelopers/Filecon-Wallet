import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:fil/common/global.dart';
import 'package:fil/index.dart';

Future initDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    var info = await deviceInfoPlugin.androidInfo;
    Global.uuid = info.androidId;
    Global.platform = 'android';
    Global.os = info.version.baseOS;
  } else {
    var info = await deviceInfoPlugin.iosInfo;
    Global.uuid = info.identifierForVendor;
    Global.platform = 'ios';
    Global.os = info.systemVersion.toString();
  }
}
