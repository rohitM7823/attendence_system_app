import 'dart:async';
import 'dart:developer';
import 'package:attendance_system/data/apis.dart';
import 'package:attendance_system/features/attendance/domain/models/employee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/utils/time_utils.dart';

class ClockPage extends StatefulWidget {
  ClockPage({super.key, this.employee});

  Employee? employee;

  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  String status = '';
  late TimeOfDay _currentTime;
  bool hasClockedIn = false;
  bool hasClockedOut = false;

  Duration _workedDuration = Duration.zero;
  late Stopwatch _stopwatch;
  late Ticker _ticker;
  late Timer _timer;

  bool isMissedClockOutShown = false;

  @override
  void initState() {
    super.initState();
    _currentTime = TimeOfDay.now();
    _stopwatch = Stopwatch();
    _ticker = Ticker((_) {
      if (_stopwatch.isRunning) {
        setState(() {
          _workedDuration = _stopwatch.elapsed;
        });
      }
    });
    _ticker.start();

    _startClock();
    _loadClockInStatus();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (isMissedClockOutShown) {
        isMissedClockOutShown = true;
        _checkForAutoClockOut();
      }
    });
  }

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentTime = TimeOfDay.now();
      });
      _startClock();
    });
  }

  Future<void> _loadClockInStatus() async {
    final clockIn = widget.employee?.clockInTime;
    final clockOut = widget.employee?.clockOutTime;

    if (clockIn != null) {
      hasClockedIn = true;

      if (clockOut == null) {
        // Still working, calculate live duration
        _stopwatch
          ..reset()
          ..start();
        _workedDuration = DateTime.now().difference(clockIn);
      } else {
        // Already clocked out — show total duration only
        hasClockedOut = true;
        _workedDuration = clockOut.difference(clockIn);
      }
    }

    setState(() {});
  }


  void _checkForAutoClockOut() async {
    final now = TimeOfDay.now();
    var latestAllowed = widget.employee?.shift?.clockOutWindow?.end != null
        ? TimeOfDay(
            hour: widget.employee!.shift!.clockOutWindow!.end!.hour,
            minute: widget.employee!.shift!.clockOutWindow!.end!.minute)
        : TimeOfDay.now();

    if (hasClockedIn &&
        !hasClockedOut &&
        TimeUtils.isAfter(now, latestAllowed)) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Missed Clock-Out?"),
          content: Text(
              "It's past ${latestAllowed.format(context)}. You may have forgotten to clock out."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Dismiss"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                clockOut();
              },
              child: Text("Clock Out Now"),
            ),
          ],
        ),
      );
      isMissedClockOutShown = false;
    }
  }

  void clockIn() async {
    if (widget.employee?.id != null) {
      await Apis.takeAttendance(
          _currentTime.toDateTime, null, widget.employee!.id!);
    }

    setState(() {
      status = "✅ Clocked in at ${_currentTime.format(context)}";
      hasClockedIn = true;
      widget.employee = widget.employee?.copyWith(
        clockInTime: _currentTime.toDateTime,
      );
      _stopwatch.start();
    });
  }

  void clockOut() async {
    if (!hasClockedIn) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Clock-In Required"),
          content: const Text("Please clock in before trying to clock out."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.employee?.id != null) {
      await Apis.takeAttendance(
          null, _currentTime.toDateTime, widget.employee!.id!);
    }

    setState(() {
      status = "✅ Clocked out at ${_currentTime.format(context)}";
      hasClockedOut = true;
      widget.employee = widget.employee?.copyWith(
        clockOutTime: _currentTime.toDateTime,
      );
      _stopwatch.stop();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeDisplay = _currentTime.format(context);
    final clockInDisplay = widget.employee?.clockInTime != null
        ? TimeOfDay.fromDateTime(widget.employee!.clockInTime!).format(context)
        : null;
    final clockOutDisplay = widget.employee?.clockOutTime != null
        ? TimeOfDay.fromDateTime(widget.employee!.clockOutTime!).format(context)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Current Time",
                  style: TextStyle(fontSize: 18, color: Colors.grey[700])),
              const SizedBox(height: 8),
              Text(timeDisplay,
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold)),
              if (hasClockedIn) ...[
                const SizedBox(height: 24),
                Text("🕒 Clocked In: $clockInDisplay",
                    style: const TextStyle(fontSize: 16)),
              ],
              if (hasClockedOut) ...[
                const SizedBox(height: 8),
                Text("🕓 Clocked Out: $clockOutDisplay",
                    style: const TextStyle(fontSize: 16)),
              ],
              if (hasClockedIn) ...[
                const SizedBox(height: 16),
                Text("⏱️ Working Duration",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 6),
                Text(_formatDuration(_workedDuration),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 40),
              hasClockedIn
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade300,
                            Colors.green.shade600
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "✅ Clocked In",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: clockIn,
                      icon:
                          const Icon(Icons.login_rounded, color: Colors.white),
                      label: const Text("Clock In"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
              const SizedBox(height: 16),
              hasClockedOut
                  ? Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade300, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "✅ Clocked Out",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: clockOut,
                      icon:
                          const Icon(Icons.logout_rounded, color: Colors.white),
                      label: const Text("Clock Out"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
              const SizedBox(height: 40),
              Text(
                status,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  child: const Text(
                    'Took Another Attendance',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
