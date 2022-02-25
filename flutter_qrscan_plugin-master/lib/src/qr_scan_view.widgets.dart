part of 'qr_scan_view.dart';

/// 相册按钮
class _GalleryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GalleryButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
        padding: const EdgeInsets.all(10.0),
        child: SvgPicture.asset(
          'packages/flutter_qrscan_plugin/assets/svgs/album.svg',
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 手电筒开关
class _TorchSwitch extends StatelessWidget {
  final bool state;

  const _TorchSwitch({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            state
                ? 'packages/flutter_qrscan_plugin/assets/svgs/torch_on.svg'
                : 'packages/flutter_qrscan_plugin/assets/svgs/torch_off.svg',
            width: 28,
            height: 28,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            state ? '轻触关闭' : '轻触照亮',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    );
  }
}

/// 扫描条
class _AnimatedScanBar extends StatefulWidget {
  final Color color;

  const _AnimatedScanBar({Key? key, required this.color}) : super(key: key);

  @override
  _AnimatedScanBarState createState() => _AnimatedScanBarState();
}

class _AnimatedScanBarState extends State<_AnimatedScanBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = Tween(begin: 0.6, end: 0.1)
        .chain(CurveTween(curve: const Interval(0.5, 1.0)));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment:
              Alignment(0, Tween(begin: -0.8, end: 0.5).evaluate(_controller)),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  widget.color.withOpacity(opacity.evaluate(_controller))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 扫描成功指示器
class _AnimatedIndicator extends StatefulWidget {
  final VoidCallback onTap;
  final double dimension;
  final Color color;
  final bool arrow;

  const _AnimatedIndicator({
    Key? key,
    required this.onTap,
    required this.dimension,
    required this.color,
    this.arrow = false,
  }) : super(key: key);

  @override
  _AnimatedIndicatorState createState() => _AnimatedIndicatorState();
}

class _AnimatedIndicatorState extends State<_AnimatedIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.dimension,
        height: widget.dimension,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.all(
                  Tween(begin: 4.0, end: 7.0).evaluate(_controller)),
              child: child,
            );
          },
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.9),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              widget.arrow
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        'packages/flutter_qrscan_plugin/assets/svgs/arrow_right.svg',
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.all(widget.dimension / 4.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
