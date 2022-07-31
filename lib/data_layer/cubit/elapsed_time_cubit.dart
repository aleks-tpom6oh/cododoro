import 'package:bloc/bloc.dart';
import 'package:cododoro/data_layer/cubit/elapsed_time_state.dart';

class ElapsedTimeCubit extends Cubit<ElapsedTimeState> {
  ElapsedTimeCubit()
      : super(ElapsedTimeState(
            lastTickDateTime: null, elapsedTime: Duration(seconds: 0)));

  void reset() {
    emit(ElapsedTimeState(lastTickDateTime: DateTime.now(), elapsedTime: Duration(seconds: 0)));
  }

  void onTick({required bool addTime}) {
    int additionalTime = state.lastTickDateTime == null
        ? 100
        : (DateTime.now().subtract(Duration(
                milliseconds: state.lastTickDateTime!.millisecondsSinceEpoch)))
            .millisecondsSinceEpoch;

    emit(ElapsedTimeState(
        lastTickDateTime: DateTime.now(),
        elapsedTime: addTime
            ? state.elapsedTime + Duration(milliseconds: additionalTime)
            : state.elapsedTime));
  }
}
