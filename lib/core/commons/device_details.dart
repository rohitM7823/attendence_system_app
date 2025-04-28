import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

class DeviceDetails {
  DeviceDetails._();

  static DeviceDetails? _instance;

  static DeviceDetails get instance {
    _instance ??= DeviceDetails._();

    return _instance!;
  }

  AndroidDeviceInfo? androidDeviceInfo;
  IosDeviceInfo? iosDeviceInfo;

  Future<void> init() async {
    if(Platform.isAndroid) androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
    if(Platform.isIOS) iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
  }

  Future<String?> get getDeviceID async =>
      await MobileDeviceIdentifier().getDeviceId();

  String? get getDeviceName =>
      Platform.isAndroid ? androidDeviceInfo?.name : iosDeviceInfo?.name;

  String? get getDeviceModel {
    return Platform.isAndroid ? androidDeviceInfo?.model : iosDeviceInfo?.model;
  }

  String? get getDeviceOSVersion {
    return Platform.isAndroid
        ? androidDeviceInfo?.version.release
        : iosDeviceInfo?.systemVersion;
  }

  String? get getRealDeviceID {
    return Platform.isAndroid
        ? androidDeviceInfo?.id
        : iosDeviceInfo?.identifierForVendor;
  }

  String get platform => Platform.isAndroid ? 'android' : 'ios';

  Future<Map<String, String>> get currentDetails async {
    final deviceID = await DeviceDetails.instance.getDeviceID;
    return {
      r'device_Id': deviceID!,
      r'platform': platform,
      r'device_name': DeviceDetails.instance.getDeviceName!,
      r'device_model': DeviceDetails.instance.getDeviceModel!,
      r'device_os_version': DeviceDetails.instance.getDeviceOSVersion!,
      r'real_id': DeviceDetails.instance.getRealDeviceID!
    };
  }
}
