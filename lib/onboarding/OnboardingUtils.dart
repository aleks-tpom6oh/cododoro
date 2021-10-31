import 'package:flutter/material.dart';

class RightTriangleShape extends CustomPainter {
  late Paint painter;
  RightTriangleShape() {
    painter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width, size.height / 2);
    path.lineTo(0, 0);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class LeftTriangleShape extends CustomPainter {
  late Paint painter;
  LeftTriangleShape() {
    painter = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, painter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum TooltipDirection { left, right }

enum TooltipOffsetFrom { top, bottom }

OverlayEntry overlayEntryCreate(
    {double? right,
    double? bottom,
    double? left,
    double? top,
    TooltipDirection tooltipDirection = TooltipDirection.right,
    TooltipOffsetFrom? tooltipOffsetFrom,
    double? tooltipOffset,
    required child}) {
  return OverlayEntry(builder: (context) {
    double width = MediaQuery.of(context).size.width;

    return Positioned(
      right: right,
      bottom: bottom,
      left: left,
      top: top,
      child: Row(
        crossAxisAlignment: tooltipOffsetFrom == TooltipOffsetFrom.top
            ? CrossAxisAlignment.start
            : tooltipOffsetFrom == TooltipOffsetFrom.bottom
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
        children: [
          tooltipDirection == TooltipDirection.left
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 0, vertical: tooltipOffset ?? 0),
                  child: CustomPaint(
                      size: Size(10, 10), painter: LeftTriangleShape()),
                )
              : SizedBox(),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: BoxConstraints(maxWidth: (width - width * 0.3)),
              color: Colors.black,
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: child,
                ),
              ),
            ),
          ),
          tooltipDirection == TooltipDirection.right
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 0, vertical: tooltipOffset ?? 0),
                  child: CustomPaint(
                      size: Size(10, 10), painter: RightTriangleShape()),
                )
              : SizedBox(),
        ],
      ),
    );
  });
}
