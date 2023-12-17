import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Animations Demo',
      debugShowCheckedModeBanner: false,
      home: AnimatedBuilderPage(),
    );
  }
}

class AnimatedBuilderPage extends StatefulWidget {
  const AnimatedBuilderPage({super.key});

  @override
  State<AnimatedBuilderPage> createState() => _AnimatedBuilderPageState();
}

class _AnimatedBuilderPageState extends State<AnimatedBuilderPage> with TickerProviderStateMixin {
  late AnimationController _counterClockWiseRotationController;
  late Animation<double> _counterClockWiseRotationAnimation;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  double containerSize = 50.0;
  final dataStreamController = StreamController<String>();

  @override
  void initState() {
    super.initState();

    _counterClockWiseRotationController = AnimationController(
        vsync: this,
        duration: const Duration(
          microseconds: 1,
        ));

    _counterClockWiseRotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2.0),
    ).animate(
      CurvedAnimation(
        parent: _counterClockWiseRotationController,
        curve: Curves.bounceOut,
      ),
    );

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(
        microseconds: 1,
      ),
    );

    _flipAnimation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.bounceOut,
    ));

    _counterClockWiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.bounceOut,
          ),
        );
        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockWiseRotationAnimation = Tween<double>(
          begin: _counterClockWiseRotationAnimation.value,
          end: _counterClockWiseRotationAnimation.value + -(pi / 2),
        ).animate(CurvedAnimation(
          parent: _counterClockWiseRotationController,
          curve: Curves.bounceOut,
        ));
        _counterClockWiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _counterClockWiseRotationController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockWiseRotationController
      ..reset()
      ..forward.delayed(
        const Duration(
          microseconds: 1,
        ),
      );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(52, 50, 50, 1.0),
      body: Center(
          child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<String>(
                  stream: dataStreamController.stream,
                  builder: (context, s) {
                    return Text(
                      s.data ?? '',
                      style: const TextStyle(fontSize: 18.0, color: Colors.yellow),
                    );
                  })),
          SizedBox(
            height: 100.0,
          ),
          AnimatedBuilder(
              animation: _counterClockWiseRotationAnimation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()..rotateZ(_counterClockWiseRotationAnimation.value),
                  alignment: Alignment.center,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                            alignment: Alignment.centerRight,
                            child: ClipPath(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              clipper: const HalfCircleClipper(side: CircleSide.left),
                              child: Container(
                                width: containerSize,
                                height: containerSize,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          );
                        }),
                    AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          dataStreamController.add(
                              'flipAnimation:\n${_flipAnimation.value.toStringAsFixed(4)}.\ncounterClockWiseRotationAnimation:\n${_counterClockWiseRotationAnimation.value.toStringAsFixed(4)}');
                          return Transform(
                            transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                            alignment: Alignment.centerLeft,
                            child: ClipPath(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              clipper: const HalfCircleClipper(side: CircleSide.right),
                              child: Container(
                                width: containerSize,
                                height: containerSize,
                                color: Colors.blueAccent,
                              ),
                            ),
                          );
                        }),
                  ]),
                );
              }),
        ],
      )),
    );
  }
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) => Future.delayed(duration, this);
}

class HalfCircleClipper extends CustomClipper<Path> {
  const HalfCircleClipper({required this.side});

  final CircleSide side;

  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

enum CircleSide {
  left,
  right,
}

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();

    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(offset, radius: Radius.elliptical(size.width / 2, size.height / 2), clockwise: clockwise);
    path.close();
    return path;
  }
}
