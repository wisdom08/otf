import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ConfettiAnimation extends StatefulWidget {
  final VoidCallback? onAnimationFinished;
  final Duration duration;

  const ConfettiAnimation({
    super.key,
    this.onAnimationFinished,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: widget.duration);
    _startConfetti();
  }

  void _startConfetti() {
    _confettiController.play();
    
    // 애니메이션 완료 후 콜백 호출
    Future.delayed(widget.duration, () {
      if (widget.onAnimationFinished != null) {
        widget.onAnimationFinished!();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirection: 1.57, // 아래쪽으로 (π/2)
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.red,
          Colors.yellow,
        ],
        emissionFrequency: 0.05,
        numberOfParticles: 50,
        gravity: 0.3,
        maxBlastForce: 20,
        minBlastForce: 10,
      ),
    );
  }
}

// 목표 완료 시 폭죽 애니메이션을 표시하는 오버레이 위젯
class GoalCompletionOverlay extends StatefulWidget {
  final Widget child;
  final bool showConfetti;
  final VoidCallback? onConfettiFinished;

  const GoalCompletionOverlay({
    super.key,
    required this.child,
    this.showConfetti = false,
    this.onConfettiFinished,
  });

  @override
  State<GoalCompletionOverlay> createState() => _GoalCompletionOverlayState();
}

class _GoalCompletionOverlayState extends State<GoalCompletionOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(GoalCompletionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showConfetti && !oldWidget.showConfetti) {
      _confettiController.play();
      
      // 애니메이션 완료 후 콜백 호출
      Future.delayed(const Duration(seconds: 3), () {
        if (widget.onConfettiFinished != null) {
          widget.onConfettiFinished!();
        }
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showConfetti)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // 아래쪽으로 (π/2)
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.red,
                Colors.yellow,
              ],
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.3,
              maxBlastForce: 20,
              minBlastForce: 10,
            ),
          ),
      ],
    );
  }
}