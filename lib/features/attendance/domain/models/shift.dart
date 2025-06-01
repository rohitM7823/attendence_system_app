import 'dart:convert';

class Shift {
  final int? id;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final ClockWindow? clockInWindow;
  final ClockWindow? clockOutWindow;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Shift({
    this.id,
    this.clockIn,
    this.clockOut,
    this.clockInWindow,
    this.clockOutWindow,
    this.createdAt,
    this.updatedAt,
  });

  Shift copyWith({
    int? id,
    DateTime? clockIn,
    DateTime? clockOut,
    ClockWindow? clockInWindow,
    ClockWindow? clockOutWindow,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Shift(
        id: id ?? this.id,
        clockIn: clockIn ?? this.clockIn,
        clockOut: clockOut ?? this.clockOut,
        clockInWindow: clockInWindow ?? this.clockInWindow,
        clockOutWindow: clockOutWindow ?? this.clockOutWindow,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory Shift.fromRawJson(String str) => Shift.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        id: json["id"],
        clockIn:
            json["clock_in"] == null ? null : DateTime.parse(json["clock_in"]),
        clockOut: json["clock_out"] == null
            ? null
            : DateTime.parse(json["clock_out"]),
        clockInWindow: json["clock_in_window"] == null
            ? null
            : ClockWindow.fromJson(json["clock_in_window"]),
        clockOutWindow: json["clock_out_window"] == null
            ? null
            : ClockWindow.fromJson(json["clock_out_window"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "clock_in": clockIn?.toIso8601String(),
        "clock_out": clockOut?.toIso8601String(),
        "clock_in_window": clockInWindow?.toJson(),
        "clock_out_window": clockOutWindow?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class ClockWindow {
  final DateTime? start;
  final DateTime? end;

  ClockWindow({
    this.start,
    this.end,
  });

  ClockWindow copyWith({
    DateTime? start,
    DateTime? end,
  }) =>
      ClockWindow(
        start: start ?? this.start,
        end: end ?? this.end,
      );

  factory ClockWindow.fromRawJson(String str) =>
      ClockWindow.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClockWindow.fromJson(Map<String, dynamic> json) => ClockWindow(
        start: json["start"] == null ? null : DateTime.parse(json["start"]),
        end: json["end"] == null ? null : DateTime.parse(json["end"]),
      );

  Map<String, dynamic> toJson() => {
        "start": start?.toIso8601String(),
        "end": end?.toIso8601String(),
      };
}
