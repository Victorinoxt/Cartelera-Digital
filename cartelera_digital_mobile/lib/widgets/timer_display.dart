import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class TimerDisplay extends StatefulWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final bool showSeconds;

  const TimerDisplay({
    super.key,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.showSeconds = true,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  late Timer _timer;
  late DateTime _currentTime;
  final DateFormat _timeFormat = DateFormat('HH:mm:ss');
  final DateFormat _timeFormatNoSeconds = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    // Actualizar cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.showSeconds 
            ? _timeFormat.format(_currentTime)
            : _timeFormatNoSeconds.format(_currentTime),
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: widget.fontSize ?? 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
} 