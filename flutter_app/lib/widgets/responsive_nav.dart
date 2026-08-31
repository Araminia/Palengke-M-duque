import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../state/cart_provider.dart";
import "../theme.dart";

class ResponsiveNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String currentRoute;
  final ScreenBuilder homeBuilder;
  final ScreenBuilder categoriesBuilder;
  final ScreenBuilder vendorsBuilder;
  final ScreenBuilder cartBuilder;

  const ResponsiveNav({
    super.key,
    this.title = "",
    required this.currentRoute,
    required this.homeBuilder,
    required this.categoriesBuilder,
    required this.vendorsBuilder,
    required this.cartBuilder,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  void _replaceStack(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  Widget _logo({double size = 30, double fontSize = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: Icon(Icons.shopping_basket, color: AppColors.primaryForeground, size: size * 0.5),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: AppColors.foreground),
            children: const [
              TextSpan(text: "Palengke"),
              TextSpan(text: ".ph", style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().count;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (!isDesktop) {
      return AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        toolbarHeight: 64,
        title: GestureDetector(
          onTap: () => _replaceStack(context, homeBuilder()),
          child: _logo(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppColors.foreground),
            onPressed: () {},
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => cartBuilder())),
            icon: Badge(
              label: Text("$cartCount"),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_basket_outlined, size: 18),
            ),
            label: const Text("Basket"),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.foreground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sign in — coming soon")),
              );
            },
            icon: const Icon(Icons.person_outline, size: 16),
            label: const Text("Sign in"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
        ],
      );
    }

    final logo = GestureDetector(
      onTap: () => _replaceStack(context, homeBuilder()),
      child: _logo(),
    );

    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              logo,
              const SizedBox(width: 32),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _NavLink(label: "Home", active: currentRoute == "home", onTap: () => _replaceStack(context, homeBuilder())),
                    _NavLink(label: "Categories", active: currentRoute == "categories", onTap: () => _replaceStack(context, categoriesBuilder())),
                    _NavLink(label: "Vendors", active: currentRoute == "vendors", onTap: () => _replaceStack(context, vendorsBuilder())),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => cartBuilder())),
                icon: Badge(
                  label: Text("$cartCount"),
                  isLabelVisible: cartCount > 0,
                  child: const Icon(Icons.shopping_basket_outlined),
                ),
                label: const Text("Basket"),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.foreground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_outline, size: 16),
                label: const Text("Sign in"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: active ? AppColors.secondary : Colors.transparent,
          foregroundColor: active ? AppColors.foreground : AppColors.mutedForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}
