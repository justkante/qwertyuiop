library overlay_loader_with_app_icon;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:creatify_mobile/view/theme/app_colors.dart';
import 'package:creatify_mobile/view/utils/extensions.dart';

class OverlayLoadingIndicator extends StatelessWidget {
  final String? text;
  final bool isLoading;
  final Widget child;
  final Widget? appIcon;
  final double appIconSize;
  final double borderRadius;
  final double overlayOpacity;
  final Color? overlayBackgroundColor;
  final Color? circularProgressColor;
  final Color? backgroundColor;

  const OverlayLoadingIndicator(
      {super.key,
      required this.isLoading,
      required this.child,
      this.appIcon,
      this.appIconSize = 15,
      this.borderRadius = 15,
      this.text,
      this.overlayOpacity = 0.5,
      this.backgroundColor,
      this.circularProgressColor,
      this.overlayBackgroundColor});
  @override
  Widget build(BuildContext context) {
    return OverLayAnimation(
      isLoading: isLoading,
      opacity: overlayOpacity,
      color: overlayBackgroundColor ?? Theme.of(context).colorScheme.surface,
      progressIndicator: Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Stack(
              children: [
                // Positioned(
                //   top: 0,
                //   bottom: 0,
                //   left: 0,
                //   right: 0,
                //   child: CircularProgressIndicator(
                //     color: circularProgressColor ??
                //         Theme.of(context).colorScheme.background,
                //     strokeWidth: 2,
                //   ),
                // ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: backgroundColor ?? AppColors.primary,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      5.0.width,
                      SizedBox(
                        width: appIconSize,
                        height: appIconSize,
                        child: appIcon ??
                            const SpinKitRing(
                              color: Colors.white,
                              size: 20,
                              lineWidth: 3,
                            ),
                      ),
                      15.0.width,
                      Flexible(
                        child: Text(
                          text ?? "Processing...",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      5.0.width,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ), //Change this loading overlay
      child: child,
    );
  }
}

//OverLayAnimation class for ModalBarrier
class OverLayAnimation extends StatefulWidget {
  final bool isLoading;
  final double opacity;
  final Color? color;
  final Widget progressIndicator;
  final Widget child;

  const OverLayAnimation({
    super.key,
    required this.isLoading,
    required this.child,
    this.opacity = 0.5,
    this.progressIndicator = const CircularProgressIndicator(),
    this.color,
  });

  @override
  State<OverLayAnimation> createState() => _OverLayAnimationState();
}

class _OverLayAnimationState extends State<OverLayAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool? _overlayVisible;

  _OverLayAnimationState();

  @override
  void initState() {
    super.initState();
    _overlayVisible = false;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _animation.addStatusListener((status) {
      status == AnimationStatus.forward ? setState(() => _overlayVisible = true) : null;
      status == AnimationStatus.dismissed ? setState(() => _overlayVisible = false) : null;
    });
    if (widget.isLoading) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(OverLayAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLoading && widget.isLoading) {
      _controller.forward();
    }

    if (oldWidget.isLoading && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];
    widgets.add(widget.child);

    if (_overlayVisible == true) {
      final modal = FadeTransition(
        opacity: _animation,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1.1, sigmaY: 1.1),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: widget.opacity,
                child: ModalBarrier(
                  dismissible: false,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
              Center(child: widget.progressIndicator),
            ],
          ),
        ),
      );
      widgets.add(modal);
    }

    return Stack(children: widgets);
  }
}
