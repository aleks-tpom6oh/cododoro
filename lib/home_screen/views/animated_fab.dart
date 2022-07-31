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
    required this.onExpand,
    required this.onCollapse,
    required this.initiallyExpended,
  }) : super(key: key);

  final double distance;
  final List<Widget> children;
  final Icon expendIcon;
  final Icon collapsedIcon;

  final Function onExpand;
  final Function onCollapse;

  final bool initiallyExpended;

  @override
  _FloatingActionButtonsState createState() => _FloatingActionButtonsState();
}

final animationDuration = const Duration(milliseconds: 500);

class _FloatingActionButtonsState extends State<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _expandAnimation;

  bool _initialOpen = false;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _initialOpen = widget.initiallyExpended;
    _open = widget.initiallyExpended;
    _controller = AnimationController(
      value: 0.0,
      duration: animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandAnimation.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward().then((_) {
          if (_expandAnimation.value == 1.0) {
            widget.onExpand();
          }
        });
      } else {
        _controller.reverse().then((value) {
          if (_expandAnimation.value == 0.0) {
            widget.onCollapse();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialOpen != widget.initiallyExpended) {
      _initialOpen = widget.initiallyExpended;
      if (_open != _initialOpen) {
        Future.delayed(Duration(milliseconds: 550), () {
          _toggle();
        });
      }
    }

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
      _ExpandingActionButtonTransition(
        offset: count * step,
        progress: _expandAnimation,
        child: _buildTapToCloseFab(),
      )
    ];

    for (var i = 0, offset = 0.0; i < count; i++, offset += step) {
      children.add(
        _ExpandingActionButtonTransition(
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
        duration: animationDuration,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
            opacity: 1.0,
            curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
            duration: animationDuration,
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
        duration: animationDuration,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: animationDuration,
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
class _ExpandingActionButtonTransition extends AnimatedWidget {
  const _ExpandingActionButtonTransition({
    Key? key,
    required Animation<double> progress,
    required this.offset,
    required this.child,
  }) : super(key: key, listenable: progress);

  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Animation<double> progress = listenable as Animation<double>;

    final offset = Offset.fromDirection(
      90 * (pi / 180.0),
      progress.value * this.offset,
    );

    return Positioned(
      right: 0,
      bottom: offset.dy,
      child: Transform.rotate(
        angle: (1.0 - progress.value) * pi / 2,
        child: Opacity(opacity: progress.value, child: child),
      ),
    );
  }
}
