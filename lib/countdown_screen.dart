import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParsedTime {
  final int months;
  final int weeks;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  ParsedTime({
    required this.months,
    required this.weeks,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });
}

MethodChannel getMethodChannelInstance(String name) {
  return MethodChannel(name);
}

EventChannel getEventChannel(String name) {
  return EventChannel(name);
}

class CountdownPage extends StatefulWidget {
  const CountdownPage({super.key});

  @override
  State<CountdownPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<CountdownPage> {
  final MethodChannel countdown =
      getMethodChannelInstance("com.chidumennamdi.year_end/countdown");
  final EventChannel eventChannel =
      getEventChannel("com.chidumennamdi.year_end/stream_channel");
  final MethodChannel background =
      getMethodChannelInstance("com.chidumennamdi.year_end/background_service");

  late ParsedTime currentTime;
  bool isCurrentTimeInitialized = false;

  ParsedTime parseMillisToTime(int millis) {
    // Calculate days, hours, minutes, and seconds
    int seconds = (millis / 1000).floor();
    int minutes = (seconds / 60).floor();
    int hours = (minutes / 60).floor();
    int days = (hours / 24).floor();

    // Calculate remaining hours, minutes, and seconds
    int remainingHours = hours % 24;
    int remainingMinutes = minutes % 60;
    int remainingSeconds = seconds % 60;

    // Calculate remaining days, weeks, and months
    int remainingDays = days % 30; // Assuming a month has 30 days
    int remainingWeeks = (days / 7).floor();
    int remainingMonths = (days / 30).floor();

    // Create and return an instance of ParsedTime
    return ParsedTime(
      months: remainingMonths,
      weeks: remainingWeeks,
      days: remainingDays,
      hours: remainingHours,
      minutes: remainingMinutes,
      seconds: remainingSeconds,
    );
  }

  @override
  void initState() {
    background.invokeMethod("startBackgroundService").then((value) {
      eventChannel.receiveBroadcastStream().listen((dynamic data) {
        ParsedTime parsedTime = parseMillisToTime(int.parse(data));

        print(parsedTime);
        setState(() {
          currentTime = parsedTime;
          isCurrentTimeInitialized = true;
        });
      });
      countdown.invokeMethod("startCountdown");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          DateTime.now().year.toString() + " Year Countdown",
          style: TextStyle(fontFamily: "BlackOpsOne-Regular"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[checkTimeElapsed()],
        ),
      ),
    );
  }

  Widget checkTimeElapsed() {
    if (!isCurrentTimeInitialized) {
      return const CircularProgressIndicator();
    }

    int months = currentTime.months;
    int weeks = currentTime.weeks;
    int days = currentTime.days;
    int hours = currentTime.hours;
    int mins = currentTime.minutes;
    int secs = currentTime.seconds;

    int elapsed = months + weeks + days + hours + mins + secs;

    return elapsed <= 0
        ? Center(
            child: Column(children: [
            const Text(
              "🎉🎉🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
              ),
            ),
            const Text(
              "Hooray!!, It's New Year.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                // style: const ButtonStyle(
                //     backgroundColor: Colors.white),
                onPressed: () {
                  // _showConfirmationDialog(context);

                  countdown.invokeMethod("reset");
                },
                child: const Text(
                  "Restart",
                  style: TextStyle(
                      color: Colors.black, fontFamily: "BlackOpsOne-Regular"),
                ))
          ]))
        : displayTime(currentTime);
  }

  Widget displayTime(ParsedTime _currentTime) {
    int months = _currentTime.months;
    int weeks = _currentTime.weeks;
    int days = _currentTime.days;
    int hours = _currentTime.hours;
    int mins = _currentTime.minutes;
    int secs = _currentTime.seconds;

    return Table(
      children: [
        _buildTimeTableRow(months, "MONTHS"),
        _buildTimeTableRow(weeks, "WEEKS"),
        _buildTimeTableRow(days, "DAYS"),
        _buildTimeTableRow(hours, "HOURS"),
        _buildTimeTableRow(mins, "MINS"),
        _buildTimeTableRow(secs, "SECS"),
      ],
    );
  }

  TableRow _buildTimeTableRow(int timeValue, String unit) {
    return TableRow(children: [
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.bottom, // Align bottom
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0), // Add space between cells
          child: Text(
            '$timeValue',
            style: const TextStyle(
                fontSize: 70,
                color: Colors.white,
                decoration: TextDecoration.none,
                fontFamily: "BlackOpsOne-Regular"),
            textAlign: TextAlign.end,
          ),
        ),
      ),
      TableCell(
        verticalAlignment: TableCellVerticalAlignment.bottom, // Align bottom
        child: Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0), // Add space between cells
            child: Text(
              unit,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontFamily: "BlackOpsOne-Regular"),
            )),
      ),
    ]);
  }
}
