import 'package:cododoro/common/cubit/elapsed_time_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils.dart';

class TimerCounter extends StatelessWidget {
  const TimerCounter({Key? key, this.elapsedTime: 0}) : super(key: key);

  final int elapsedTime;

  @override
  Widget build(BuildContext context) {
    var watchElapsedTimeCubit = context.watch<ElapsedTimeCubit>();

    return Text(
        stopwatchTime(Duration(
            seconds: watchElapsedTimeCubit.state.elapsedTime.inSeconds)),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ));
  }
}
