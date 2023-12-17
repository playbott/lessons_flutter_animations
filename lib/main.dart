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

class _AnimatedBuilderPageState extends State<AnimatedBuilderPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 2 * pi).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(52, 50, 50, 1.0),
      body: Center(
          child: AnimatedBuilder(
            builder: (context, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(_animation.value),
                child: Container(
                        decoration: const BoxDecoration(
                  color: Colors.orange,
                  boxShadow: [BoxShadow(color: Colors.white, spreadRadius: 0, blurRadius: 15, blurStyle: BlurStyle.outer, offset: Offset(0, 0))],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(81),
                    topRight: Radius.circular(20),
                  )),
                        width: 200,
                        height: 200,
                      ),
              );
            }, animation: _animation,
          )),
    );
  }
}
