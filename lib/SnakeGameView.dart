import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeGameView extends StatefulWidget {
  const SnakeGameView({super.key});

  @override
  State<SnakeGameView> createState() => _SnakeGameViewState();
}

enum Direction { up, down, left, right }

class _SnakeGameViewState extends State<SnakeGameView> {
  int rows = 20;
  int columns = 20;
  static const int initialSpeed = 300;
  int speed = initialSpeed;
  List<Offset> snakePositions = [const Offset(10, 10)];
  Offset foodPosition = const Offset(5, 5);
  String direction = 'up';
  Timer? timer;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    generateNewFood();
    //startGame();
  }

  void startGame() {
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      setState(() {
        isPlay = true;
        moveSnake();
        checkGameOver();
      });
    });
  }

  void generateNewFood() {
    foodPosition = Offset(
      Random().nextInt(columns).toDouble(),
      Random().nextInt(rows).toDouble(),
    );
  }

  void moveSnake() {
    Offset newHeadPosition;
    switch (direction) {
      case 'up':
        newHeadPosition = snakePositions.first + const Offset(0, -1);
        break;
      case 'down':
        newHeadPosition = snakePositions.first + const Offset(0, 1);
        break;
      case 'left':
        newHeadPosition = snakePositions.first + const Offset(-1, 0);
        break;
      case 'right':
        newHeadPosition = snakePositions.first + const Offset(1, 0);
        break;
      default:
        return;
    }

    if (newHeadPosition == foodPosition) {
      snakePositions.insert(0, newHeadPosition);
      generateNewFood();
      increaseSpeed();
    } else {
      snakePositions.insert(0, newHeadPosition);
      snakePositions.removeLast();
    }
  }

  void increaseSpeed() {
    if (speed > 50) {
      speed -= 10;
      timer?.cancel();
      startGame();
    }
  }

  void checkGameOver() {
    Offset head = snakePositions.first;
    if (head.dx < 0 ||
        head.dx >= columns ||
        head.dy < 0 ||
        head.dy >= rows ||
        snakePositions.skip(1).contains(head)) {
      timer?.cancel();
      showGameOverDialog();
      setState(() {
        isPlay = false;
      });
    }
  }

  void showGameOverDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Score: ${snakePositions.length - 1}'),
          actions: [
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
                exit(1);
              },
            ),
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      snakePositions = [const Offset(10, 10)];
      direction = 'up';
      speed = initialSpeed;
      generateNewFood();
      startGame();
    });
  }

  void updateDirection(String newDirection) {
    if (direction == 'up' && newDirection != 'down' ||
        direction == 'down' && newDirection != 'up' ||
        direction == 'left' && newDirection != 'right' ||
        direction == 'right' && newDirection != 'left') {
      direction = newDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cellSize = min(size.width / columns, size.height / rows);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text(
            'Score: ${snakePositions.length - 1}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 12.0,
          ),
        ],
        title: const Text('Snake Game'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double aspectRatio = rows / columns;
          double gameHeight = constraints.maxWidth * aspectRatio;

          return Stack(
            children: [
              Column(
                children: [
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final x = index % columns;
                        final y = (index / columns).floor();
                        final cell = Offset(x.toDouble(), y.toDouble());
                        final isSnakeBody = snakePositions.contains(cell);
                        final isFood = cell == foodPosition;

                        return Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isSnakeBody
                                ? Colors.green
                                : isFood
                                ? Colors.red
                                : Colors.grey[300],
                            borderRadius: isSnakeBody || isFood
                                ? BorderRadius.circular(5)
                                : BorderRadius.circular(0),
                          ),
                        );
                      },
                      itemCount: rows * columns,
                    ),
                  ),
                ],
              ),
              if (isPlay)
                Positioned(
                  top: gameHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < 0) {
                        updateDirection('up');
                      } else if (details.primaryDelta! > 0) {
                        updateDirection('down');
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      if (details.primaryDelta! < 0) {
                        updateDirection('left');
                      } else if (details.primaryDelta! > 0) {
                        updateDirection('right');
                      }
                    },
                    child: Container(
                      color: Colors.black54,
                    ),
                  ),
                )
              else
                Positioned(
                  top: gameHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        startGame();
                      },
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
