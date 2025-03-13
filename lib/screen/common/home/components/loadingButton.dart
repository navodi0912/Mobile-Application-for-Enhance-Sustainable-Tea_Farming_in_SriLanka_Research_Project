// Add this controller class at the top of your file
import 'package:flutter/material.dart';

class LoadingButtonController {
  late VoidCallback _startLoading;
  late VoidCallback _stopLoading;

  void startLoading() => _startLoading();
  void stopLoading() => _stopLoading();
}

// Custom loading button widget
class CustomLoadingButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final LoadingButtonController? controller;
  final double width;
  final double borderRadius;
  final Color color;
  final Widget child;

  const CustomLoadingButton({
    super.key,
    this.onPressed,
    this.controller,
    required this.width,
    this.borderRadius = 25,
    required this.color,
    required this.child,
  });

  @override
  State<CustomLoadingButton> createState() => _CustomLoadingButtonState();
}

class _CustomLoadingButtonState extends State<CustomLoadingButton> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._startLoading = () {
      if (mounted) setState(() => _isLoading = true);
    };
    widget.controller?._stopLoading = () {
      if (mounted) setState(() => _isLoading = false);
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: ElevatedButton(
        onPressed: _isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : widget.child,
      ),
    );
  }
}
