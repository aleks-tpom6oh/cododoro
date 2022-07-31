import 'package:flutter/material.dart';

import 'stats_screen.dart';

class StatsListToggleButton extends StatefulWidget {
  final Function(ListState) onToggle;

  StatsListToggleButton({Key? key, required this.onToggle}) : super(key: key);

  @override
  _StatsListToggleButton createState() => _StatsListToggleButton();
}

class ButtonAlign {
  static double get pomodoro => -1;
  static double get standing => 1;
}

const double width = 300.0;
const double height = 60.0;
const Color selectedColor = Colors.white;
const Color normalColor = Colors.black54;

class _StatsListToggleButton extends State<StatsListToggleButton> {
  late double xAlign;
  late Color loginColor;
  late Color signInColor;

  @override
  void initState() {
    super.initState();
    xAlign = ButtonAlign.pomodoro;
    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlign, -1),
            duration: Duration(milliseconds: 300),
            child: Container(
              width: width * 0.5,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = ButtonAlign.pomodoro;
                loginColor = selectedColor;

                signInColor = normalColor;
              });
              widget.onToggle(ListState.pomodoro);
            },
            child: Align(
              alignment: Alignment(-1, 0),
              child: Container(
                width: width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Pomodoro',
                  style: TextStyle(
                    color: loginColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                xAlign = ButtonAlign.standing;
                signInColor = selectedColor;

                loginColor = normalColor;
              });
              widget.onToggle(ListState.standing);
            },
            child: Align(
              alignment: Alignment(1, 0),
              child: Container(
                width: width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Text(
                  'Standing',
                  style: TextStyle(
                    color: signInColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
