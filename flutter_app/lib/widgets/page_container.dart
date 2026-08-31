import "package:flutter/material.dart";

const double kDesktopBreakpoint = 768;

int gridColumnsForWidth(double width) {
  if (width >= 1200) return 5;
  if (width >= 900) return 4;
  if (width >= 600) return 3;
  return 2;
}

class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const PageContainer({super.key, required this.child, this.maxWidth = 1200});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= kDesktopBreakpoint;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
              : const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
