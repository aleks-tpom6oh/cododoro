import 'package:flutter/material.dart';
import 'dart:math';

@immutable
class FloatingActionButtons extends StatefulWidget {
  const FloatingActionButtons({
    Key? key,
    required this.distance,
    required this.children,
    required this.expendIcon,
    required this.collapsedIcon,
    required this.onExpend,
    required this.onCollapse,
  }) : super(key: key);

  final double distance;
  final List<Widget> children;
  final Icon expendIcon;
  final Icon collapsedIcon;

  final Function onExpend;
  final Function onCollapse;

  @override
  _FloatingActionButtonsState createState() => _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends State<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
        widget.onExpend();
      } else {
        _controller.reverse();
        widget.onCollapse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,
          children: _buildExpandingActionButtons() +
              [
                _buildTapToOpenFab(),
              ]),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final count = widget.children.length;
    final step = 70.0;

    final children = <Widget>[
      _ExpandingActionButton(
        delay: 0.0,
        offset: count * step,
        progress: _expandAnimation,
        child: _buildTapToCloseFab(),
      )
    ];

    for (var i = 0, offset = 0.0; i < count; i++, offset += step) {
      children.add(
        _ExpandingActionButton(
          delay: 0.3 * i,
          offset: offset,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToCloseFab() {
    return AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(0.7, 0.7, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
            opacity: 1.0,
            curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
            duration: const Duration(milliseconds: 250),
            child: FloatingActionButton(
              heroTag: "collapse-fab",
              onPressed: _toggle,
              child: widget.collapsedIcon,
            )));
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(0.7, 0.7, 1.0),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: "expand-fab",
            onPressed: _toggle,
            child: widget.expendIcon,
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  _ExpandingActionButton({
    Key? key,
    required this.delay,
    required this.offset,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double delay;
  final double offset;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, Widget? child) {
        final offset = Offset.fromDirection(
          90 * (pi / 180.0),
          progress.value * this.offset,
        );
        return Positioned(
          right: 0,
          bottom: offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: progress,
            curve: Interval(delay, 1.0),
          ),
        ),
        child: child,
      ),
    );
  }
}
