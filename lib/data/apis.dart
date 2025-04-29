import 'dart:convert';
import 'dart:developer';

import 'package:attendance_system/core/commons/device_details.dart';
import 'package:attendance_system/core/commons/secure_storage.dart';
import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:http/http.dart' as http;

class Apis {
  static Future<bool> registerDeviceIfNot() async {
    if (await SecureStorage.instance.deviceIdentifier != null) return true;

    try {
      final deviceDetails = await DeviceDetails.instance.currentDetails;
      final response = await http.post(
          Uri.parse('http://192.168.0.5:8000/api/device/register'),
          headers: deviceDetails);
      if (response.statusCode == 200) {
        final deviceToken = json.decode(response.body)['device_token'];
        if (deviceToken == null) return false;
        await SecureStorage.instance.setDeviceIdentifier(deviceToken);
        return true;
      }
    } catch (ex) {
      log(ex.toString(), name: 'REGISTER_DEVICE_ISSUE');
      return false;
    }

    return false;
  }

  static Future<bool?> isDeviceApproved() async {
    try {
      String? deviceToken = await SecureStorage.instance.deviceIdentifier;
      final response = await http.get(
          Uri.parse('http://192.168.0.5:8000/api/device/status'),
          headers: {
            'platform': DeviceDetails.instance.platform,
            'device_token': deviceToken!,
          });
      if (response.statusCode == 200) {
        String? deviceStatus = json.decode(response.body)['status'];
        if (deviceStatus == null) return null;
        await SecureStorage.instance.setDeviceStatus(deviceStatus);
        return deviceStatus.toLowerCase() == 'approved';
      }
    } catch (ex) {
      log(ex.toString(), name: 'IS_DEVICE_APPROVED_ISSUE');
      return null;
    }
    return null;
  }

  static Future<List<Employee>?> getFaceEmbeddings(String? appIdentifier) async {
    try {
      final deviceDetails = await DeviceDetails.instance.currentDetails;
      final response = await http.get(
          Uri.parse('http://192.168.0.5:8000/api/employee/face/metadata/all'),
          headers: deviceDetails);
      var body = json.decode(response.body);
      if(body['data'] == null) return null;
      return List<Employee>.from(body["data"]!.map((x) => Employee.fromJson(x)));
    } catch (ex) {
      log(ex.toString(), name: 'GET_FACE_EMBEDDINGS_ISSUE');
      return null;
    }
  }
}
