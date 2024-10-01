import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _gateController;
  late Animation<double> _leftGateAnimation;
  late Animation<double> _rightGateAnimation;

  late AnimationController _carController;
  late Animation<Offset> _carMovement;
  late CurvedAnimation _carCurve;

  late bool isAnimationActive = false;

  @override
  void initState() {
    super.initState();

    // Gate animations (increased duration)
    _gateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Slower gate animation
    );
    _leftGateAnimation =
        Tween<double>(begin: 0, end: -pi / 2).animate(_gateController);
    _rightGateAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(_gateController);

    // Car animations (increased duration)
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slower car animation
    );

    // Apply a custom Bezier curve for smoother movement
    _carCurve = CurvedAnimation(
      parent: _carController,
      curve: Curves.easeInOutCubic, // Smooth cubic Bezier curve
    );

    _carMovement = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -1.5), // Move the car upwards
    ).animate(_carCurve);

    // Start car animation when the gates are fully open
    _gateController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _carController.forward();
      } else if (status == AnimationStatus.dismissed) {
        _carController.reset(); // Reset car animation when gates close
      }
    });
  }

  @override
  void dispose() {
    _gateController.dispose();
    _carController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 167, 23, 167),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Car app'),
      ),
      body: Stack(
        children: [
          // Gates animation
          Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const LeftGateStatic(),
                    AnimatedBuilder(
                      animation: _leftGateAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_leftGateAnimation.value),
                          child: child!,
                        );
                      },
                      child: const LeftGateAnimated(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _rightGateAnimation,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerRight,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_rightGateAnimation.value),
                          child: child!,
                        );
                      },
                      child: const RightGateAnimated(),
                    ),
                    const RightGateStatic(),
                  ],
                ),
              ],
            ),
          ),

          // Car animation - Only show the car while it's moving
          AnimatedBuilder(
            animation: _carController,
            builder: (context, child) {
              if (_carController.value < 1.0) {
                return Transform.translate(
                  offset:
                      _carMovement.value * MediaQuery.of(context).size.height,
                  child: child!,
                );
              } else {
                return const SizedBox.shrink(); // Hide the car after it exits
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(
              top: 350.0,
              left: 200,),
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.asset('assets/images/car_classic.png'),
                ),
            ),
            // child: Padding(
            //   padding: EdgeInsets.only(
            //     top: 350.0,
            //     left: !isAnimationActive ? 300 : 150,
            //   ),
            //   child: Transform.rotate(
            //     angle: !isAnimationActive ? 0 : pi / 2,
            //     child: SizedBox(
            //       width: 120,
            //       height: 120,
            //       child: Image.asset('assets/images/car.png'),
            //     ),
            //   ),
            // ),
          ),

          // Button to open/close the gate
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                if (_gateController.isCompleted) {
                  _gateController.reverse();
                } else {
                  _gateController.forward();
                }
                setState(() {
                  isAnimationActive = !isAnimationActive;
                });
              },
              child: const Text('Open/Close Gate'),
            ),
          ),
        ],
      ),
    );
  }
}

// Static part of the left gate (gate_left.png)
class LeftGateStatic extends StatelessWidget {
  const LeftGateStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/gate_left.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

// Animated part of the left gate (gate_left_l.png)
class LeftGateAnimated extends StatelessWidget {
  const LeftGateAnimated({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/gate_left_l.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

// Static part of the right gate (gate_right.png)
class RightGateStatic extends StatelessWidget {
  const RightGateStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/gate_right.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

// Animated part of the right gate (gate_right_r.png)
class RightGateAnimated extends StatelessWidget {
  const RightGateAnimated({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 120,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/gate_right_r.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}
