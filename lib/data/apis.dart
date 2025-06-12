import 'dart:convert';
import 'dart:developer';

import 'package:attendance_system/core/commons/device_details.dart';
import 'package:attendance_system/core/commons/secure_storage.dart';
import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:attendance_system/features/attendance/domain/models/shift.dart';
import 'package:attendance_system/features/attendance/domain/models/site.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Apis {
  // static const BASE_URL = 'http://192.168.0.2:8000/api';
  static const BASE_URL = 'https://gsa.ezonedigital.com/api';

  static Future<bool> registerDeviceIfNot() async {
    if (await SecureStorage.instance.deviceIdentifier != null) return true;

    try {
      final deviceDetails = await DeviceDetails.instance.currentDetails;
      final response = await http.post(Uri.parse('$BASE_URL/device/register'),
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
      final response =
          await http.get(Uri.parse('${BASE_URL}/device/status'), headers: {
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


  static Future<Shift?> getAssignedShift(int shiftID) async {
    try {
      final response = await http.get(Uri.parse('${BASE_URL}/shifts/$shiftID'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return Shift.fromJson(json.decode(response.body));
      }

      return null;
    } catch (ex) {
      log(ex.toString(), name: 'GET_ASSIGNED_SHIFT_ISSUE');
      return null;
    }
  }

  static Future<Site?> getSiteRadius(int empId) async {
    try {
      final response =
          await http.get(Uri.parse('${BASE_URL}/employee/$empId/site-radius'));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        log('${json.decode(response.body)['site']}', name: 'SITE');
        return Site.fromJson(json.decode(response.body)['site']);
      }
      return null;
    } on FormatException catch (ex) {
      log(ex.toString(), name: 'GET_SITE_RADIUS_ISSUE');
      return null;
    }
  }

  static Future<bool?> takeAttendance(
      DateTime? clockInTime, DateTime? clockOutTime, int empId) async {
    try {
      var data = jsonEncode({
        'clock_in': clockInTime != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(clockInTime)
            : null,
        'clock_out': clockOutTime != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss').format(clockOutTime)
            : null,
      });
      log(data, name: 'TAKE_ATTENDANCE_DATA');
      final response = await http.post(
          Uri.parse('$BASE_URL/employee/$empId/attendance-take'),
          headers: {"Accept": "application/json", 'Content-Type': 'application/json'},
          body: data);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        if (clockInTime != null) {
          return Employee.fromJson(json.decode(response.body)['employee'])
                  .clockInTime !=
              null;
        } else {
          return Employee.fromJson(json.decode(response.body)['employee'])
                  .clockOutTime !=
              null;
        }
      }
      return null;
    } catch (ex) {
      log(ex.toString(), name: 'TAKE_ATTENDANCE_ISSUE');
      return null;
    }
  }

  static Future<List<Employee>?> employees(
      {String search = '', int? page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$BASE_URL/employee/all?search=$search&page=$page&limit=$limit'),
      );
      if (response.statusCode == 200) {
        return List<Employee>.from(json
            .decode(response.body)['employees']!
            .map((e) => Employee.fromJson(e)));
      }
    } catch (ex) {
      log(ex.toString(), name: 'EMPLOYEES_ISSUE');
      return null;
    }

    return null;
  }
}
