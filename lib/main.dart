import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

void main() {
  final myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
    ),
  );
}

class MyGame extends Game with TapDetector {
  late SpriteAnimationComponent runningRobot;

  // Vector2 is a class from `package:vector_math/vector_math_64.dart` and is widely used
  // in Flame to represent vectors. Here we need two vectors, one to define where we are
  // going to draw our robot and another one to define its size
  final robotPosition = Vector2(0, 0);
  final robotSize = Vector2(48, 60);

  // BasicPalette is a help class from Flame, which provides default, pre-built instances
  // of Paint that can be used by your game
  static final squarePaint = BasicPalette.white.paint();

  // A constant speed, represented in logical pixels per second
  static const int squareSpeed = 60;

  // To represent our direction, we will be using an int value, where 1 means
  // going to the right, and -1 going to the left, this may seems like a too much
  // simple way of representing a direction, and indeed it is, but this will
  // will work fine for our small example and will make more sense when we implement
  // the update method
  int squareDirectionHorizontal = 1;
  int squareDirectionVertical = 1;

  @override
  void onTapDown(TapDownInfo event) {
    if (event.eventPosition.widget.x - runningRobot.width/2 > runningRobot.x) {
      squareDirectionHorizontal = 1;
    } else {
      squareDirectionHorizontal = -1;
    }
    if (event.eventPosition.widget.y - runningRobot.height/2 > runningRobot.y) {
      squareDirectionVertical = 1;
    } else {
      squareDirectionVertical = -1;
    }
  }

  // The onLoad method is where all of the game initialization is supposed to go
  // For this example, you may think that this square could just be initialized on the field
  // declaration, and you are right, but for learning purposes and to present the life cycle method
  // for this example we will be initializing this field here.
  @override
  Future<void> onLoad() async {
    runningRobot = SpriteAnimationComponent.fromFrameData(
        await images.load('robot.png'),
      // `SpriteAnimationData` is a class used to tell Flame how the animation Sprite Sheet
      // is organized. In this case we are describing that our frames are laid out in a horizontal
      // sequence on the image, that there are 8 frames, that each frame is a sprite of 16x18 pixels,
      // and, finally, that each frame should appear for 0.1 seconds when the animation is running.
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(16, 18),
        stepTime: 0.1,
      ),
    );
    runningRobot.height = 60;
    runningRobot.width = 48;
  }

  @override
  void update(double dt) {
    // Here we just need to "hook" our animation into the game loop update method so the current frame is updated with the specified frequency
    runningRobot.update(dt);
    runningRobot.x = runningRobot.x + squareSpeed * squareDirectionHorizontal * dt;
    runningRobot.y = runningRobot.y + squareSpeed * squareDirectionVertical * dt;

    // This simple condition verifies if the square is going right, and has reached the end of the
    // screen and if so, we invert the direction.
    //
    // Note here that we have used the variable size, which is a variable provided
    // by the Game class which contains the size in logical pixels that the game is currently using.
    if (squareDirectionHorizontal == 1 && runningRobot.x + runningRobot.width > size.x) {
      squareDirectionHorizontal = -1;
      // This does the same, but now checking the left direction
    } else if (squareDirectionHorizontal == -1 && runningRobot.x < 0) {
      squareDirectionHorizontal = 1;
    }
    // Vertical
    if (squareDirectionVertical == 1 && runningRobot.y + runningRobot.height > size.y) {
      squareDirectionVertical = -1;
      // This does the same, but now checking the left direction
    } else if (squareDirectionVertical == -1 && runningRobot.y < 0) {
      squareDirectionVertical = 1;
    }
  }

  @override
  void render(Canvas canvas) {
    // Since an animation is basically a list of sprites, to render it, we just need to get its
    // current sprite and render it on our canvas. Which frame is the current sprite is updated on the `update` method.
    canvas.save();
    runningRobot.renderFlipX = squareDirectionHorizontal == -1;
    runningRobot
        .render(canvas);
    canvas.restore();
  }

  @override
  Color backgroundColor() => const Color(0xFF222222);
}
