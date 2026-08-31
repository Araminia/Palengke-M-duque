import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../state/cart_provider.dart";
import "../theme.dart";

class AppBottomNav extends StatelessWidget {
  final String currentRoute; // "home" | "browse" | "vendors" | "basket" | "profile"
  final ScreenBuilder homeBuilder;
  final ScreenBuilder browseBuilder;
  final ScreenBuilder vendorsBuilder;
  final ScreenBuilder basketBuilder;

  const AppBottomNav({
    super.key,
    required this.currentRoute,
    required this.homeBuilder,
    required this.browseBuilder,
    required this.vendorsBuilder,
    required this.basketBuilder,
  });

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.marketCream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: "Home",
                active: currentRoute == "home",
                onTap: () => _go(context, homeBuilder()),
              ),
              _NavItem(
                icon: Icons.search,
                label: "Browse",
                active: currentRoute == "browse",
                onTap: () => _go(context, browseBuilder()),
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                label: "Vendors",
                active: currentRoute == "vendors",
                onTap: () => _go(context, vendorsBuilder()),
              ),
              _NavItem(
                icon: Icons.shopping_basket_outlined,
                label: "Basket",
                active: currentRoute == "basket",
                badgeCount: cartCount,
                onTap: () => _go(context, basketBuilder()),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: "Profile",
                active: currentRoute == "profile",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile — coming soon")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool active;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.active,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.mutedForeground;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              label: Text("$badgeCount"),
              isLabelVisible: badgeCount > 0,
              child: Icon(active && activeIcon != null ? activeIcon : icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
