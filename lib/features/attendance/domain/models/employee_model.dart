import 'package:attendance_system/features/attendance/domain/models/shift.dart';

class Employee {
  final int? id;
  final String? name;
  final String? empId;
  final String? address;
  final String? token;
  final String? accountNumber;
  final String? siteName;
  final Map<String, dynamic>? location;
  final DateTime? clockInTime;
  final DateTime? clockOutTime;
  final String? aadharCard;
  final String? mobileNumber;
  final Shift? shift;
  final String? faceData;

  const Employee(
      {this.id,
      this.name,
      this.empId,
      this.address,
      this.token,
      this.accountNumber,
      this.siteName,
      this.location,
      this.clockInTime,
      this.clockOutTime,
      this.aadharCard,
      this.mobileNumber,
      this.faceData,
      this.shift});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name'],
      empId: json['emp_id'],
      aadharCard: json['aadhar_card'],
      address: json['address'],
      clockInTime:
          json['clock_in'] != null ? DateTime.tryParse(json['clock_in']) : null,
      clockOutTime: json['clock_out'] != null
          ? DateTime.tryParse(json['clock_out'])
          : null,
      location: json['location'] as Map<String, dynamic>?,
      mobileNumber: json['mobile_number'],
      accountNumber: json['salary'],
      siteName: json['site_name'],
      token: json['token'],
      faceData: json["face_metadata"],
      shift: json['shift'] != null ? Shift.fromJson(json['shift']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id.toString(),
    "name": name,
    "emp_id": empId,
    "address": address,
    "account_number": accountNumber,
    "token": token,
    "site_name": siteName,
    "location": location,
    "face_metadata": faceData,
    "clock_in": clockInTime?.toIso8601String(),
    "clock_out": clockOutTime?.toIso8601String(),
    "aadhar_card": aadharCard,
    "mobile_number": mobileNumber,
    "shift": shift?.toJson(),
  };

  Employee copyWith({
    int? id,
    String? name,
    String? empId,
    String? address,
    String? token,
    String? accountNumber,
    String? siteName,
    Map<String, dynamic>? location,
    DateTime? clockInTime,
    DateTime? clockOutTime,
    String? aadharCard,
    String? mobileNumber,
    Shift? shift,
    String? faceData,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      empId: empId ?? this.empId,
      address: address ?? this.address,
      token: token ?? this.token,
      accountNumber: accountNumber ?? this.accountNumber,
      siteName: siteName ?? this.siteName,
      location: location ?? this.location,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      aadharCard: aadharCard ?? this.aadharCard,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      shift: shift ?? this.shift,
      faceData: faceData ?? this.faceData,
    );
  }
}
