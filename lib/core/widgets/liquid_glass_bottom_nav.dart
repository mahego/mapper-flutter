import 'dart:ui';
import 'package:flutter/material.dart';

/// Bottom navigation item configuration
class BottomNavItem {
  final String label;
  final IconData icon;
  final String route;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Bottom navigation bar with Liquid Glass design
/// Matches Angular's dashboard-bottom-nav component
class LiquidGlassBottomNav extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool mobileOnly;

  const LiquidGlassBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.mobileOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    // Hide on desktop if mobileOnly is true
    if (mobileOnly && MediaQuery.of(context).size.width >= 768) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0f172a).withOpacity(0.92),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  items.length,
                  (index) => Expanded(
                    child: _BottomNavButton(
                      item: items[index],
                      isActive: currentIndex == index,
                      onTap: () => onTap?.call(index),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final VoidCallback? onTap;

  const _BottomNavButton({
    required this.item,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFF22d3ee) // cyan-400
        : Colors.white.withOpacity(0.65);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Active indicator line
              Container(
                height: 3,
                width: 28,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon
              Transform.scale(
                scale: isActive ? 1.05 : 1.0,
                child: Icon(
                  item.icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),

              // Label
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
