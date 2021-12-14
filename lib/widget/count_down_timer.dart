import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:votie/common/style.dart';
import 'package:votie/data/model/poll_model.dart';
import 'package:votie/utils/date_time_helper.dart';
import 'package:ntp/ntp.dart';

class CountDownTimer extends StatefulWidget {
  final PollModel poll;

  const CountDownTimer({Key? key, required this.poll}) : super(key: key);

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer> {
  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countDown);

  var _dateNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadNTPTime();
  }

  void _loadNTPTime() async {
    var ntpDateNow = await NTP.now();
    setState(() {
      _dateNow = ntpDateNow;
    });
  }

  @override
  Widget build(BuildContext context) {
    var endDate = widget.poll.end ?? _dateNow;
    var difference = endDate.difference(_dateNow).inMilliseconds;
    _stopWatchTimer.clearPresetTime();
    _stopWatchTimer.setPresetTime(mSec: difference);
    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    return StreamBuilder<int>(
      stream: _stopWatchTimer.rawTime,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        return Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
          alignment: Alignment.center,
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: SvgPicture.asset(
                  getOptionBg(widget.poll.title.toString().codeUnitAt(0)),
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 30.0),
                alignment: Alignment.center,
                child: SizedBox(
                  child: Column(
                    children: [
                      Text(
                        'End on ${DateTimeHelper.formatDateTime(endDate, "dd MMM yyy, HH':'mm'")}',
                        style: textRegular.apply(color: colorDarkBlue),
                      ),
                      Text(
                        '${(StopWatchTimer.getRawHours(value) / 24).floor()} : ${StopWatchTimer.getRawHours(value) % 24} : ${StopWatchTimer.getRawMinute(value) % 60} : ${StopWatchTimer.getDisplayTimeSecond(value)} ',
                        style: GoogleFonts.poppins(
                            fontSize: 35.0,
                            fontWeight: FontWeight.w600,
                            color: colorDarkBlue),
                      ),
                      Text(
                        '   days        Hours       Minutes       Second    ',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: colorDarkBlue),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
