import 'dart:async';
import 'package:flutter/material.dart';

class AdLoadingDialog extends StatefulWidget {
  final VoidCallback onTimeout;

  const AdLoadingDialog({super.key, required this.onTimeout});

  @override
  State<AdLoadingDialog> createState() => _AdLoadingDialogState();
}

class _AdLoadingDialogState extends State<AdLoadingDialog> {
  bool showClose = false;
  Timer? closeBtnTimer;
  Timer? autoCloseTimer;

  @override
  void initState() {
    super.initState();

    closeBtnTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showClose = true;
        });
      }
    });

    autoCloseTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        widget.onTimeout();
      }
    });
  }

  @override
  void dispose() {
    closeBtnTimer?.cancel();
    autoCloseTimer?.cancel();
    super.dispose();
  }

  void _handleClose() {
    widget.onTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              if (showClose)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _handleClose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      "Showing test ads...",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This is a test ad for development purposes",
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
