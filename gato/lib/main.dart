import 'package:flutter/material.dart';

void main() {
  runApp(const GatoApp());
}

class GatoApp extends StatelessWidget {
  const GatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gato',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.mauve),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const GameFlow(),
    );
  }
}

class MyApp extends GatoApp {
  const MyApp({super.key});
}

class GameFlow extends StatefulWidget {
  const GameFlow({super.key});

  @override
  State<GameFlow> createState() => _GameFlowState();
}

class _GameFlowState extends State<GameFlow> {
  AppScreen _screen = AppScreen.home;
  Mark? _playerMark;

  void _showMarkPicker() {
    setState(() => _screen = AppScreen.markPicker);
  }

  void _selectMark(Mark mark) {
    setState(() {
      _playerMark = mark;
      _screen = AppScreen.board;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: switch (_screen) {
          AppScreen.home => HomeScreen(onStart: _showMarkPicker),
          AppScreen.markPicker => MarkPickerScreen(onSelected: _selectMark),
          AppScreen.board => BoardScreen(playerMark: _playerMark ?? Mark.x),
        },
      ),
    );
  }
}

enum AppScreen { home, markPicker, board }

enum Mark { x, o }

extension MarkText on Mark {
  String get label => this == Mark.x ? 'X' : 'O';
}

abstract final class WinningRules {
  static const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final markSize = (width / 9).clamp(56.0, 92.0);

            return Column(
              children: [
                SizedBox(
                  height: markSize * 1.25,
                  child: DecorativeMarkRow(
                    startWith: Mark.x,
                    markSize: markSize,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Gato',
                          style: TextStyle(
                            color: AppColors.mauve,
                            fontFamily: 'Georgia',
                            fontSize: 74,
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 64),
                        const Text(
                          '¡Domina el tablero!',
                          style: TextStyle(
                            color: AppColors.mauve,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 54),
                        FilledButton(
                          onPressed: onStart,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.mauve,
                            fixedSize: const Size(178, 39),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                            elevation: 0,
                          ),
                          child: const Text('INICIAR'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: markSize * 1.4,
                  child: DecorativeMarkRow(
                    startWith: Mark.o,
                    markSize: markSize,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MarkPickerScreen extends StatelessWidget {
  const MarkPickerScreen({super.key, required this.onSelected});

  final ValueChanged<Mark> onSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = (constraints.maxWidth * 0.22).clamp(130.0, 235.0);

            return Column(
              children: [
                const SizedBox(height: 88),
                const Text(
                  'Elige tu ficha',
                  style: TextStyle(
                    color: AppColors.mauve,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MarkButton(
                        mark: Mark.x,
                        size: iconSize,
                        onTap: () => onSelected(Mark.x),
                      ),
                      SizedBox(
                        width: (constraints.maxWidth * 0.14).clamp(56.0, 150.0),
                      ),
                      MarkButton(
                        mark: Mark.o,
                        size: iconSize,
                        onTap: () => onSelected(Mark.o),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.playerMark});

  final Mark playerMark;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  late final List<Mark?> _cells = List<Mark?>.filled(9, null);
  late final Mark _appMark = widget.playerMark == Mark.x ? Mark.o : Mark.x;
  Mark? _winner;
  List<int>? _winningLine;
  bool _isAppTurn = false;
  bool _isDraw = false;
  bool _isResetting = false;

  void _play(int index) {
    if (_cells[index] != null || _winner != null || _isAppTurn || _isDraw) {
      return;
    }

    setState(() {
      _cells[index] = widget.playerMark;
      _updateWinner();
    });

    if (_winner == null && _hasEmptyCells) {
      _scheduleAppMove();
    } else if (_winner == null) {
      _markDrawAndReset();
    }
  }

  void _scheduleAppMove() {
    setState(() => _isAppTurn = true);

    Future<void>.delayed(const Duration(milliseconds: 360), () {
      if (!mounted || _winner != null) return;

      final index = _chooseAppMove();
      if (index == null) {
        setState(() => _isAppTurn = false);
        return;
      }

      setState(() {
        _cells[index] = _appMark;
        _isAppTurn = false;
        _updateWinner();
      });

      if (_winner == null && !_hasEmptyCells) {
        _markDrawAndReset();
      }
    });
  }

  bool get _hasEmptyCells => _cells.any((cell) => cell == null);

  int? _chooseAppMove() {
    return _findFinishingMove(_appMark) ??
        _findFinishingMove(widget.playerMark) ??
        _firstEmptyFrom([4, 0, 2, 6, 8, 1, 3, 5, 7]);
  }

  int? _findFinishingMove(Mark mark) {
    for (final line in WinningRules.lines) {
      final marks = line.map((index) => _cells[index]).toList();
      final matchingMarks = marks.where((cell) => cell == mark).length;
      final emptyMarks = marks.where((cell) => cell == null).length;

      if (matchingMarks == 2 && emptyMarks == 1) {
        return line.firstWhere((index) => _cells[index] == null);
      }
    }

    return null;
  }

  int? _firstEmptyFrom(List<int> indexes) {
    for (final index in indexes) {
      if (_cells[index] == null) return index;
    }

    return null;
  }

  void _updateWinner() {
    for (final line in WinningRules.lines) {
      final first = _cells[line.first];

      if (first != null && line.every((index) => _cells[index] == first)) {
        _winner = first;
        _winningLine = line;
        return;
      }
    }
  }

  void _markDrawAndReset() {
    if (_isResetting) return;

    setState(() {
      _isDraw = true;
      _isResetting = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;

      setState(() {
        for (var index = 0; index < _cells.length; index++) {
          _cells[index] = null;
        }
        _winner = null;
        _winningLine = null;
        _isAppTurn = false;
        _isDraw = false;
        _isResetting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = constraints.biggest.shortestSide;
            final boardSize = shortestSide.clamp(300.0, 575.0);

            return Stack(
              alignment: Alignment.center,
              children: [
                if (_winner != null)
                  Positioned(
                    top: 12,
                    child: Text(
                      'Ganador ${_winner!.label}',
                      style: const TextStyle(
                        color: AppColors.mauve,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (_isDraw)
                  const Positioned(
                    top: 12,
                    child: Text(
                      'Empate',
                      style: TextStyle(
                        color: AppColors.mauve,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                SizedBox(
                  width: boardSize,
                  height: boardSize,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.square(boardSize),
                        painter: BoardGridPainter(),
                      ),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 9,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                        itemBuilder: (context, index) {
                          final mark = _cells[index];

                          return InkWell(
                            key: Key('board-cell-$index'),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () => _play(index),
                            child: Center(
                              child: mark == null
                                  ? const SizedBox.shrink()
                                  : SizedBox.square(
                                      dimension: boardSize * 0.2,
                                      child: MarkShape(
                                        mark: mark,
                                        color: mark == Mark.x
                                            ? AppColors.lavender
                                            : AppColors.mauve,
                                        strokeWidth: boardSize * 0.035,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      if (_winningLine != null)
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size.square(boardSize),
                            painter: WinningLinePainter(
                              winningLine: _winningLine!,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DecorativeMarkRow extends StatelessWidget {
  const DecorativeMarkRow({
    super.key,
    required this.startWith,
    required this.markSize,
  });

  final Mark startWith;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / (markSize * 1.12)).floor().clamp(
          1,
          24,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(count, (index) {
            final mark = index.isEven
                ? startWith
                : startWith == Mark.x
                ? Mark.o
                : Mark.x;

            return SizedBox.square(
              dimension: markSize,
              child: MarkShape(
                mark: mark,
                color: mark == Mark.x ? AppColors.lavender : AppColors.mauve,
                strokeWidth: markSize * 0.18,
              ),
            );
          }),
        );
      },
    );
  }
}

class SideMarkColumn extends StatelessWidget {
  const SideMarkColumn({
    super.key,
    required this.mark,
    required this.size,
    required this.color,
  });

  final Mark mark;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        4,
        (_) => SizedBox.square(
          dimension: size,
          child: MarkShape(mark: mark, color: color, strokeWidth: size * 0.18),
        ),
      ),
    );
  }
}

class MarkButton extends StatelessWidget {
  const MarkButton({
    super.key,
    required this.mark,
    required this.size,
    required this.onTap,
  });

  final Mark mark;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: mark == Mark.x ? 'Elegir X' : 'Elegir O',
      child: InkResponse(
        onTap: onTap,
        radius: size * 0.7,
        splashColor: AppColors.mauve.withValues(alpha: 0.08),
        highlightColor: AppColors.mauve.withValues(alpha: 0.04),
        child: SizedBox.square(
          dimension: size,
          child: MarkShape(
            mark: mark,
            color: mark == Mark.x ? AppColors.lavender : AppColors.mauve,
            strokeWidth: mark == Mark.x ? size * 0.18 : size * 0.075,
          ),
        ),
      ),
    );
  }
}

class MarkShape extends StatelessWidget {
  const MarkShape({
    super.key,
    required this.mark,
    required this.color,
    required this.strokeWidth,
  });

  final Mark mark;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MarkPainter(mark: mark, color: color, strokeWidth: strokeWidth),
    );
  }
}

class MarkPainter extends CustomPainter {
  MarkPainter({
    required this.mark,
    required this.color,
    required this.strokeWidth,
  });

  final Mark mark;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    if (mark == Mark.x) {
      final inset = strokeWidth * 0.65;
      canvas
        ..drawLine(
          Offset(inset, inset),
          Offset(size.width - inset, size.height - inset),
          paint,
        )
        ..drawLine(
          Offset(size.width - inset, inset),
          Offset(inset, size.height - inset),
          paint,
        );
    } else {
      canvas.drawCircle(
        size.center(Offset.zero),
        (size.shortestSide - strokeWidth) / 2,
        paint..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MarkPainter oldDelegate) {
    return oldDelegate.mark != mark ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class BoardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.02
      ..strokeCap = StrokeCap.square;

    final third = size.width / 3;

    canvas
      ..drawLine(Offset(third, 0), Offset(third, size.height), paint)
      ..drawLine(Offset(third * 2, 0), Offset(third * 2, size.height), paint)
      ..drawLine(Offset(0, third), Offset(size.width, third), paint)
      ..drawLine(Offset(0, third * 2), Offset(size.width, third * 2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WinningLinePainter extends CustomPainter {
  WinningLinePainter({required this.winningLine});

  final List<int> winningLine;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      _cellCenter(winningLine.first, size),
      _cellCenter(winningLine.last, size),
      paint,
    );
  }

  Offset _cellCenter(int index, Size size) {
    final cellSize = size.width / 3;
    final row = index ~/ 3;
    final column = index % 3;

    return Offset(
      column * cellSize + cellSize / 2,
      row * cellSize + cellSize / 2,
    );
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) {
    return oldDelegate.winningLine != winningLine;
  }
}

abstract final class AppColors {
  static const background = Color(0xFFF6E8F8);
  static const mauve = Color(0xFF9B5E7F);
  static const lavender = Color(0xFFC39BD3);
}
