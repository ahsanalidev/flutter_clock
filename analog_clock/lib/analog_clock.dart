import 'dart:async';

import 'package:analog_clock/tickers.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;
import 'package:analog_clock/clock_raimbow.dart';
import 'package:analog_clock/background.dart';
import 'container_hand.dart';
import 'drawn_hand.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // There are many ways to apply themes to your clock. Some are:
    //  - Inherit the parent Theme (see ClockCustomizer in the
    //    flutter_clock_helper package).
    //  - Override the Theme.of(context).colorScheme.
    //  - Create your own [ThemeData], demonstrated in [AnalogClock].
    //  - Create a map of [Color]s to custom keys, demonstrated in
    //    [DigitalClock].
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Colors.white,
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Colors.white.withOpacity(0.80),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_condition,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 42,
                fontWeight: FontWeight.w900,
              )),
          Text(_temperature,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 38,
                fontWeight: FontWeight.w900,
              )),
          Text(_temperatureRange,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 28,
                fontWeight: FontWeight.w900,
              )),
        ],
      ),
    );
    final location = Text(_location,
        style: TextStyle(
          fontSize: 30,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w900,
          color: customTheme.primaryColor,
        ));

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Stack(
        children: <Widget>[
          FancyBackgroundApp(
            Circle(
              Stack(
                children: [
                  // Example of a hand drawn with [CustomPainter].
                  DrawnHand(
                    color: customTheme.primaryColor,
                    thickness: 4,
                    size: 0.7,
                    angleRadians: _now.second * radiansPerTick,
                  ),
                  DrawnHand(
                    color: customTheme.primaryColor,
                    thickness: 8,
                    size: 0.7,
                    angleRadians: _now.minute * radiansPerTick,
                  ),
                  // Example of a hand drawn with [Container].
                  ContainerHand(
                    color: Colors.transparent,
                    size: 0.3,
                    angleRadians: _now.hour * radiansPerHour +
                        (_now.minute / 60) * radiansPerHour,
                    child: Transform.translate(
                      offset: Offset(0.0, -60.0),
                      child: Container(
                        width: 32,
                        height: 150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 8,
                    height: MediaQuery.of(context).size.width - 8,
                    child: CustomPaint(
                      painter: TickerPainter(
                          datetime: _now, tickColor: customTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            weather: weatherInfo,
            location: location,
          ),
        ],
      ),
    );
  }
}
